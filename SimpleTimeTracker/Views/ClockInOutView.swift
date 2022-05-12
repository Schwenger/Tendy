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
  
  var body: some View {
    NavigationView {
      VStack {
        Spacer()
        HStack() {
          Spacer()
          StackedHighlight(caption: "Overtime", highlight: "16h 12m", additionalHighlight: ViewForegroundColor(.green))
          Spacer()
          StackedHighlight(caption: "Worked Today", highlight: (past.cwd?.timeWorked ?? TimeInterval(0)).defaultFormatted)
          Spacer()
        }
        
        Spacer()
        
        StackedHighlight(caption: "Estimated quitting time", highlight: "\(past.expectedQuittingTime.defaultFormatted)")
        .padding(.horizontal)

        Spacer()
        
        Button(action: { past.triggerWork() }) {
          HStack {
            past.clockInOutButtonLabel
              .labelStyle(.iconOnly)
              .font(.largeTitle)
            VStack {
              past.clockInOutButtonLabel
                .labelStyle(.titleOnly)
                .font(.largeTitle)
              if let startTime = past.cwd?.date, past.clockedIn {
                Text(startTime.defaultFormatted)
                  .font(.title2)
              }
            }
          }
        }
        .disabled(!past.canTriggerWork)
        .frame(maxWidth: .infinity, maxHeight: 75)
        .padding()
        .padding()
        .background(past.canTriggerWork ? Color.blue : Color.gray)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .foregroundColor(.white)
        .padding(.horizontal)
        
        Button(action: { past.triggerBreak() }) {
          HStack {
            past.breakInOutButtonLabel
              .labelStyle(.iconOnly)
              .font(.largeTitle)
            VStack {
              past.breakInOutButtonLabel
                .labelStyle(.titleOnly)
                .font(.largeTitle)
              if let startTime = past.cwd?.breaks, past.inBreak {
                Text(startTime.defaultFormatted)
                  .font(.title2)
              }
            }
          }
        }
        .disabled(!past.canTriggerBreak)
        .frame(maxWidth: .infinity, maxHeight: 75)
        .padding()
        .padding()
        .background(past.canTriggerBreak ? Color.green : Color.gray)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .foregroundColor(.white)
        .padding()
        
        Spacer()
      }
      .navigationTitle(self.greeting)
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
    let quota = settings.quota(Date.now).asTimeInterval
    let worked = (past.cwd?.timeWorked ?? TimeInterval(0))
    return (quota - worked).defaultFormatted
  }
  
}

struct ClockInOutView_Previews: PreviewProvider {
    static var previews: some View {
      ClockInOutView()
        .environment(\.managedObjectContext, DataController().container.viewContext)
        .environmentObject(UserSettings.preview)
        .environmentObject(Past.preview)
    }
}
