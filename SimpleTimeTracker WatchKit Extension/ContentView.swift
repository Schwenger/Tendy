//
//  ContentView.swift
//  SimpleTimeTracker WatchKit Extension
//
//  Created by Maximilian Schwenger on 06.03.22.
//

import SwiftUI

struct ContentView: View {
  @EnvironmentObject var past: Past
  @EnvironmentObject var settings: UserSettings
  @EnvironmentObject var cwd: CurrentWorkDay
  
  var body: some View {
    VStack {
      VStack {
        Text("\((cwd.timeWorked ?? TimeInterval(0)).defaultFormatted) / \(settings.quota(Date.now).defaultFormatted)")
          .font(.title)
      }
      .padding(.top)
      
      HStack {
        Button(action: { cwd.triggerWork() }) {
          VStack {
            cwd.clockInOutButtonLabel
              .labelStyle(.iconOnly)
              .font(.largeTitle)
            if let startTime = cwd.startTime, cwd.clockedIn {
              Text(startTime.defaultFormatted)
            }
          }
        }
        .disabled(!cwd.canTriggerWork)
        .padding(.vertical, 20)
        .background(cwd.canTriggerWork ? Color.blue : Color.gray)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .foregroundColor(.white)
        
        Button(action: { cwd.triggerBreak() }) {
          VStack {
            cwd.breakInOutButtonLabel
              .labelStyle(.iconOnly)
              .font(.largeTitle)
            if let startTime = cwd.breakStartTime, cwd.inBreak {
              Text(startTime.defaultFormatted)
            }
          }
        }
        .disabled(!cwd.canTriggerBreak)
        .padding(.vertical, 20)
        .background(cwd.canTriggerBreak ? Color.green : Color.gray)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .foregroundColor(.white)
      }
      .padding(.bottom)
        
      HStack {
        Text("Exp. Quit:")
        Spacer()
        Text("~\(cwd.expectedQuittingTime.defaultFormatted)")
      }
      .padding(.horizontal)
    }
  }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
      ContentView()
        .environment(\.managedObjectContext, DataController().container.viewContext)
        .environmentObject(Past.preview)
    }
}
