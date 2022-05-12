//
//  SimpleTimeTrackerApp.swift
//  SimpleTimeTracker WatchKit Extension
//
//  Created by Maximilian Schwenger on 06.03.22.
//

import SwiftUI

@main
struct SimpleTimeTrackerApp: App {
  
  @StateObject private var dc = DataController()
  @FetchRequest(sortDescriptors: []) var workRecords: FetchedResults<WorkRecord>
  
  @SceneBuilder var body: some Scene {
    let us = UserSettings()
    WindowGroup {
      NavigationView {
        ContentView()
          .environment(\.managedObjectContext, dc.container.viewContext)
          .environmentObject(Past(from: us, oldWorkRecords: Array(workRecords), moc: dc.container.viewContext))
          .environmentObject(us)
      }
    }

    WKNotificationScene(controller: NotificationController.self, category: "myCategory")
  }
}
