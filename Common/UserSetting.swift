//
//  UserDefault.swift
//  SimpleTimeTracker
//
//  Created by Maximilian Schwenger on 18.03.22.
//

import Foundation

class UserSettings: ObservableObject {
  
  @Published private var workDays: [Quota] {
    didSet {
      UserDefaults.standard.set(workDays.map { $0.asTimeInterval }, forKey: Keys.workdays.key)
    }
  }
  
  @Published var mostRecentRecord: UUID {
    didSet {
      UserDefaults.standard.set(mostRecentRecord, forKey: Keys.mostRecentRecord.key)
    }
  }
  
  @Published var clockState: ClockState {
    didSet {
      UserDefaults.standard.set(clockState, forKey: Keys.clockState.key)
    }
  }
  
  @Published var lastClockTriggerTime: Date {
    didSet {
      UserDefaults.standard.set(lastClockTriggerTime, forKey: Keys.lastClockTriggerTime.key)
    }
  }
  
  init() {
    let timeIntervals = UserDefaults.standard.array(forKey: Keys.workdays.key) as? [TimeInterval]
    self.workDays = timeIntervals.map { $0.map { $0.asQuota } } ?? UserSettings.workdaysDefault
    self.mostRecentRecord = UserDefaults.standard.value(forKey: Keys.mostRecentRecord.key) as? UUID ?? UserSettings.mostRecentRecordDefault
    self.lastClockTriggerTime = UserDefaults.standard.object(forKey: Keys.lastClockTriggerTime.key) as? Date ?? UserSettings.lastClockTriggerTimeDefault
    self.clockState = UserDefaults.standard.object(forKey: Keys.clockState.key) as? ClockState ?? UserSettings.clockStateDefault
  }
  
}
  
extension UserSettings {
  var weeklyQuota: Quota {
    workDays.reduce(.zero, +)
  }
  func quota(_ day: Weekday) -> Quota {
    workDays[day.index]
  }
  func quota(_ date: Date) -> Quota {
    return workDays[DateHelper.weekday(from: date).index]
  }
  
  func reset() {
    self.workDays = Self.workdaysDefault
  }
  
  func setQuota(for day: Weekday, _ quota: Quota) {
    workDays[day.index] = quota
  }
  
  enum Keys: String {
    case workdays
    case mostRecentRecord
    case clockState
    case lastClockTriggerTime
    
    var key: String { self.rawValue }
  }
}

extension UserSettings {
  static let workdaysDefault: [Quota] = [
    Quota.zero,  // Sunday
    Quota.eight, // Monday
    Quota.eight, // Tuesday
    Quota.eight, // Wednesday
    Quota.eight, // Thursday
    Quota.eight, // Friday
    Quota.zero,  // Saturday
  ]
  static let defaultWorkdayQuota: Quota = .eight
  static let mostRecentRecordDefault: UUID = UUID()
  static let clockStateDefault: ClockState = .Fresh
  static let lastClockTriggerTimeDefault: Date = Date.now
}

extension UserSettings {
  static var preview: UserSettings {
    UserSettings()
  }
}
