//
//  ContentView.swift
//  SimpleTimeTracker
//
//  Created by Maximilian Schwenger on 06.03.22.
//

import SwiftUI

struct ContentView: View {
  @EnvironmentObject var settings: UserSettings
  @EnvironmentObject var past: Past
  @EnvironmentObject var cwd: CurrentWorkDay
  @State var tabSelection: Int = 0
  
  var body: some View {
    TabView(selection: $tabSelection) {
      ClockInOutView()
        .background(.red)
        .tabItem {
        if tabSelection == 0 {
          Label("Clocking", systemImage: "deskclock.fill")
        } else {
          Label("Clocking", systemImage: "deskclock")
        }
      }.tag(0)
        .navigationTitle("New Sign")
      PastView(month: Date.now.month)
        .tabItem {
          if tabSelection == 1 {
            Label("Overview", systemImage: "calendar")
          } else {
            Label("Overview", systemImage: "calendar")
          }
        }.tag(1)
      SettingsView(settings)
        .tabItem {
          if tabSelection == 2 {
            Label("Settings", systemImage: "gearshape.fill")
          } else {
            Label("Settings", systemImage: "gearshape")
          }
        }.tag(2)
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      ContentView().preferredColorScheme(.dark)
        .environment(\.managedObjectContext, DataController().container.viewContext)
        .environmentObject(UserSettings.preview)
        .environmentObject(Past.preview)
    }
  }
}

