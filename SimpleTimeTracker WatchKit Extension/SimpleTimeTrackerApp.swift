//
//  SimpleTimeTrackerApp.swift
//  SimpleTimeTracker WatchKit Extension
//
//  Created by Maximilian Schwenger on 06.03.22.
//

import SwiftUI

@main
struct SimpleTimeTrackerApp: App {
    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
            }
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}
