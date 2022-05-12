//
//  SettingsView.swift
//  SimpleTimeTracker
//
//  Created by Maximilian Schwenger on 08.03.22.
//

import SwiftUI

struct SettingsView: View {
  @EnvironmentObject var settings: UserSettings
  @ObservedObject var model: SettingsViewModel
  @State var showConfirmationDialog = false
  @State var confirmationData: ConfirmationData? = nil
  @State var showWorkDaySelection: Bool = false
  
  var orderedWorkDays: [Weekday] {
    get {
      model.workDays.sorted(by: { $0.displayIndex < $1.displayIndex })
    }
  }
  init(_ settings: UserSettings) {
    self.model = SettingsViewModel(settings)
  }

  var body: some View {
    NavigationView {
      Form {
        Section("Work Days") {
          HStack {
            HStack(alignment: .bottom) {
              Text("Work Days")
              Text("[\(workDayDisplayString)]")
                .foregroundColor(.gray)
                .font(.footnote)
            }
            Spacer()
            Image(systemName: "chevron." + (showWorkDaySelection ? "down" : "right"))
              .padding(.trailing)
          }.onTapGesture { withAnimation { showWorkDaySelection.toggle() } }
          Toggle("Regular Work Week", isOn: $model.regularWorkWeek)
          if showWorkDaySelection  {
            ForEach(DateHelper.weekdays()) { day in
              Toggle(day.description, isOn: $model.isWorkDay[day.index])
            }
          }
        }
        Section("Hour Distribution") {
          Toggle("Distribute hours evenly", isOn: $model.distributeEvenlyToggle)
          if !model.distributeEvenlyToggle {
            ForEach(self.orderedWorkDays) { day in
              Stepper("\(settings.quota(day).defaultFormatted): \(day.description)",
                 onIncrement: {
                settings.setQuota(for: day, settings.quota(day) + 15)
              }, onDecrement: {
                settings.setQuota(for: day, settings.quota(day) - 15)
              })
            }
            HStack {
              Text("Total:")
              Spacer()
              Text("\(settings.weeklyQuota.defaultFormatted)")
            }
          }
          if model.distributeEvenlyToggle  {
            Stepper("Daily Quota: \(model.dailyQuota.defaultFormatted)", value: $model.dailyQuota, step: 15)
          }
        }
        Section("Data Storage") {
          Stepper("Detailed records: \(settings.recentWorkRecordStorageLimit)", value: $settings.recentWorkRecordStorageLimit)
        }
        Section("Reset Data") {
          Button(role: .destructive, action: {
            self.prepConfDialog(
              name: "reset user settings",
              warning: "This will not discard your work record and overtime.",
              action: self.reset)
          }) {
            Label("Reset Settings", systemImage: "arrowshape.turn.up.backward.2.fill")
              .foregroundColor(.orange)
          }
          Button(role: .destructive, action: {
            self.prepConfDialog(
              name: "reset work record",
              warning: "This cannot be undone.",
              action: settings.reset)
          }) {
            Label("Discard Work Record", systemImage: "flame.fill")
              .foregroundColor(.red)
          }
        }
      }
      .confirmationDialog(
        "Are you sure?",
        isPresented: $showConfirmationDialog,
        titleVisibility: .visible,
        presenting: confirmationData
      ) { data in
        Button("Yes, \(data.name)") {
          withAnimation {
            data.action()
          }
        }.keyboardShortcut(.defaultAction)
        
        Button("No", role: .cancel) {}
      } message: { data in
        Text(data.warning)
      }
      .navigationTitle("Settings")
    }
  }
  
  func prepConfDialog(name tbd: String, warning: String = "This cannot be undone", action: @escaping () -> ()) {
    self.confirmationData = ConfirmationData(name: tbd, warning: warning, action: action)
    self.showConfirmationDialog = true
  }
  
  var workDayDisplayString: String {
    let process: ([Weekday]) -> String = { (running) in
      assert(!running.isEmpty)
      if running.count == 1 {
        return DateHelper.shortDisplayStr(running.first!)
      } else if running.count == 2 {
        let fst = DateHelper.shortDisplayStr(running[0])
        let snd = DateHelper.shortDisplayStr(running[1])
        return "\(fst),\(snd)"
      } else {
        let fst = DateHelper.shortDisplayStr(running.first!)
        let lst = DateHelper.shortDisplayStr(running.last!)
        return "\(fst)-\(lst)"
      }
    }
    let days = self.orderedWorkDays
    guard let fst = days.first else {
      return ""
    }
    var running = [fst]
    var res: [String] = []
    for i in 1..<self.orderedWorkDays.count {
      let last = self.orderedWorkDays[i-1]
      let current = self.orderedWorkDays[i]
      if (last.index + 1) % 6 == current.index {
        running.append(current)
      } else {
        res.append(process(running))
        running = [current]
      }
    }
    res.append(process(running))
    assert(!res.isEmpty)
    return res.joined(separator: ",")
  }
  
  func reset() {
    self.settings.reset()
    self.model.reset()
  }
  
}

struct ConfirmationData {
  var name: String
  var warning: String
  var action: () -> ()
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
      let settings = UserSettings()
      SettingsView(settings)
        .environmentObject(settings)
    }
}

class SettingsViewModel: ObservableObject {
  var settings: UserSettings
  @Published var regularWorkWeek: Bool {
    didSet {
      // defer setting self.isWorkDay to avoid repeated didSet-calls.
      var workdays = [Bool](repeating: false, count: 7)
      for day in Weekday.regularWorkWeek {
        workdays[day.index] = true
      }
      self.isWorkDay = workdays
    }
  }
  @Published var isWorkDay: [Bool] {
    didSet {
      self.updateWorkdays()
    }
  }
  @Published var distributeEvenlyToggle: Bool {
    didSet {
      if distributeEvenlyToggle {
        self.distribute(settings.weeklyQuota, hoursEvenlyOnto: DateHelper.workDays(us: settings))
      }
    }
  }
  @Published var dailyQuota: Quota {
    didSet {
      if dailyQuota != dailyQuota.rounded {
        self.dailyQuota = dailyQuota.rounded
      }
      self.workDays.forEach { settings.setQuota(for: $0, dailyQuota) }
    }
  }
  @Published var workDays: Set<Weekday> {
    didSet {
      let old = oldValue
      let new = workDays
      for day in DateHelper.weekdays() {
        if old.contains(day) && !new.contains(day) {
          settings.setQuota(for: day, .zero)
        }
        if !old.contains(day) && new.contains(day) {
          settings.setQuota(for: day, UserSettings.defaultWorkdayQuota)
        }
      }
    }
  }
  
  init(_ settings: UserSettings) {
    let workDays = Set(DateHelper.workDays(us: settings))
    self.workDays = workDays
    let workDayQuotas = workDays.map(settings.quota)
    self.distributeEvenlyToggle = workDayQuotas.allSatisfy { $0 == workDayQuotas.first ?? Quota.zero }
    self.isWorkDay = Self.updateIsWorkDays(settings)
    self.dailyQuota = Self.updateDailyQuota(settings)
    self.regularWorkWeek = Self.updateRegularWorkWeek(settings)
    self.settings = settings
  }
  
  func reset() {
    self.workDays = Set(DateHelper.workDays(us: settings))
    let workDayQuotas = workDays.map(settings.quota)
    self.distributeEvenlyToggle = workDayQuotas.allSatisfy { $0 == workDayQuotas.first ?? Quota.zero }
    self.isWorkDay = Self.updateIsWorkDays(settings)
    self.dailyQuota = Self.updateDailyQuota(settings)
    self.regularWorkWeek = Self.updateRegularWorkWeek(settings)
  }
  
  func updateWorkdays(changeAt idx: Int? = nil) {
      self.workDays = Self.updateWorkdays(basedOn: self.isWorkDay)
  }
  
  static func updateRegularWorkWeek(_ settings: UserSettings) -> Bool {
    return Set(DateHelper.workDays(us: settings)) == Set(Weekday.regularWorkWeek)
  }
  
  static func updateWorkdays(basedOn isWorkDay: [Bool]) -> Set<Weekday> {
    Set(isWorkDay
      .enumerated()
      .filter { $0.element }
      .map { Weekday.from(index: $0.offset) })
  }
  
  static func updateIsWorkDays(_ settings: UserSettings) -> [Bool] {
    DateHelper
      .weekdays()
      .reduce(into: [Bool](repeating: false, count: 7)) {
        $0[$1.index] = settings.quota($1).notFree
      }
  }
  
  static func updateDailyQuota(_ settings: UserSettings) -> Quota {
    settings.weeklyQuota.divide(by: DateHelper.workDays(us: settings).count)
  }
  
  func distribute(_ quota: Quota, hoursEvenlyOnto days: [Weekday]) {
    let perDay = quota.divide(by: self.workDays.count)
    for day in days {
      settings.setQuota(for: day, perDay)
    }
  }
}
