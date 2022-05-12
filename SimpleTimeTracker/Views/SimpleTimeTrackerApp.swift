//
//  SimpleTimeTrackerApp.swift
//  SimpleTimeTracker
//
//  Created by Maximilian Schwenger on 06.03.22.
//

import SwiftUI

@main
struct SimpleTimeTrackerApp: App {
  
  @StateObject private var dataController = DataController()
  
  var body: some Scene {
    WindowGroup {
      IntermediateView()
        .environment(\.managedObjectContext, dataController.container.viewContext)
        .environmentObject(UserSettings())
    }
  }
}

struct IntermediateView: View {
  @FetchRequest(sortDescriptors: []) var workRecords: FetchedResults<WorkRecord>
  @EnvironmentObject var settings: UserSettings
  @StateObject var past: Past = Past.preview // TODO:
  @Environment(\.managedObjectContext) var moc
  
  var body: some View {
    ContentView()
      .environmentObject(past)
  }
}
