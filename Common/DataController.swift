//
//  DataController.swift
//  SimpleTimeTracker
//
//  Created by Maximilian Schwenger on 31.03.22.
//

import CoreData

class DataController: ObservableObject {
  let container = NSPersistentContainer(name: "WorkRecord")
  
  init() {
    container.loadPersistentStores { description, error in
      if let error = error {
        print("Damn, son, retrieving work records failed.")
        print(error.localizedDescription)
      }
    }
  }
}
