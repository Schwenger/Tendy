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
    let past = Past(
      from: us,
      workRecords: WorkRecord.arbitraryConsecutive(n: 100, dc.container.viewContext),
      moc: dc.container.viewContext
    )
    WindowGroup {
      NavigationView {
        ContentView()
          .environment(\.managedObjectContext, dc.container.viewContext)
          .environmentObject(past)
          .environmentObject(us)
      }
    }

    WKNotificationScene(controller: NotificationController.self, category: "myCategory")
  }
}
