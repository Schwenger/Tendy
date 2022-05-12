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
  
  var cwd: WorkRecord? {
    past.cwd
  }
  
  var body: some View {
    VStack {
      VStack {
        Text("\((cwd?.timeWorked ?? TimeInterval(0)).defaultFormatted) / \(settings.quota(Date.now).defaultFormatted)")
          .font(.title)
      }
      .padding(.top)
      
      HStack {
        Button(action: { past.triggerWork() }) {
          VStack {
            past.clockInOutButtonLabel
              .labelStyle(.iconOnly)
              .font(.largeTitle)
            if let startTime = past.startTime, past.clockedIn {
              Text(startTime.defaultFormatted)
            }
          }
        }
        .disabled(!past.canTriggerWork)
        .padding(.vertical, 20)
        .background(past.canTriggerWork ? Color.blue : Color.gray)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .foregroundColor(.white)
        
        Button(action: { past.triggerBreak() }) {
          VStack {
            past.breakInOutButtonLabel
              .labelStyle(.iconOnly)
              .font(.largeTitle)
            if let startTime = past.breakStartTime, past.inBreak {
              Text(startTime.defaultFormatted)
            }
          }
        }
        .disabled(!past.canTriggerBreak)
        .padding(.vertical, 20)
        .background(past.canTriggerBreak ? Color.green : Color.gray)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .foregroundColor(.white)
      }
      .padding(.bottom)
        
      HStack {
        Text("Exp. Quit:")
        Spacer()
        Text("~\(past.expectedQuittingTime.defaultFormatted)")
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
