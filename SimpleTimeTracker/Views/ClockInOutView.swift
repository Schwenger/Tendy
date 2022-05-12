//
//  ClockInOutView.swift
//  SimpleTimeTracker
//
//  Created by Maximilian Schwenger on 06.03.22.
//

import SwiftUI

struct ClockInOutView: View {
  
  @EnvironmentObject var settings: UserSettings
  @EnvironmentObject var past: Past
  @EnvironmentObject var cwd: CurrentWorkDay
  
  var body: some View {
    NavigationView {
      VStack {
        Spacer()
        HStack() {
          Spacer()
          StackedHighlight(caption: "Overtime", highlight: "16h 12m", additionalHighlight: ViewForegroundColor(.green))
          Spacer()
          StackedHighlight(caption: "Worked Today", highlight: (cwd.timeWorked ?? TimeInterval(0)).defaultFormatted)
          Spacer()
        }
        
        Spacer()
        
        StackedHighlight(caption: "Estimated quitting time", highlight: "\(cwd.expectedQuittingTime.defaultFormatted)")
        .padding(.horizontal)

        Spacer()
        
        Button(action: { cwd.triggerWork() }) {
          HStack {
            cwd.clockInOutButtonLabel
              .labelStyle(.iconOnly)
              .font(.largeTitle)
            VStack {
              cwd.clockInOutButtonLabel
                .labelStyle(.titleOnly)
                .font(.largeTitle)
              if let startTime = cwd.startTime, cwd.clockedIn {
                Text(startTime.defaultFormatted)
                  .font(.title2)
              }
            }
          }
        }
        .disabled(!cwd.canTriggerWork)
        .frame(maxWidth: .infinity, maxHeight: 75)
        .padding()
        .padding()
        .background(cwd.canTriggerWork ? Color.blue : Color.gray)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .foregroundColor(.white)
        .padding(.horizontal)
        
        Button(action: { cwd.triggerBreak() }) {
          HStack {
            cwd.breakInOutButtonLabel
              .labelStyle(.iconOnly)
              .font(.largeTitle)
            VStack {
              cwd.breakInOutButtonLabel
                .labelStyle(.titleOnly)
                .font(.largeTitle)
              if let startTime = cwd.breakStartTime, cwd.inBreak {
                Text(startTime.defaultFormatted)
                  .font(.title2)
              }
            }
          }
        }
        .disabled(!cwd.canTriggerBreak)
        .frame(maxWidth: .infinity, maxHeight: 75)
        .padding()
        .padding()
        .background(cwd.canTriggerBreak ? Color.green : Color.gray)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .foregroundColor(.white)
        .padding()
        
        Spacer()
      }
      .navigationTitle(self.greeting)
      .onAppear(perform: {
        if cwd.shouldBeReplaced {
          past.accept(cwd.replace())
        }
      })
    }
  }
  
  var overtimeColor: Color {
    let overtime = TimeInterval.fromHAndMin(h: 16, min: 15)
    if overtime > TimeInterval.fromH(h: 1) {
      return .green
    } else if overtime < TimeInterval.fromHAndMinNeg(h: 1) {
      return .orange
    } else {
      return .primary
    }
  }
  
  var greeting: String {
    let hour = Calendar.current.component(.hour, from: Date.now)
    switch hour {
    case 0..<4, 22..<24: return "Good Night!"
    case 4..<11: return "Good Morning!"
    case 11..<14: return "Good Day!"
    case 14..<17: return "Good Afternoon!"
    case 17..<22: return "Good Evening!"
    default: return "Heyho!"
    }
  }
  
  var timeLeft: String {
    (settings.quota(Date.now).asTimeInterval - (cwd.timeWorked ?? TimeInterval(0))).defaultFormatted
  }
  
}

struct ClockInOutView_Previews: PreviewProvider {
    static var previews: some View {
      ClockInOutView()
        .environment(\.managedObjectContext, DataController().container.viewContext)
        .environmentObject(UserSettings.preview)
        .environmentObject(Past.preview)
        .environmentObject(CurrentWorkDay.preview)
    }
}
