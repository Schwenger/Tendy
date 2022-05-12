//
//  PhoneComm.swift
//  SimpleTimeTracker
//
//  Created by Maximilian Schwenger on 20.03.22.
//

import Foundation
import WatchConnectivity

extension Comm {
  
  func sessionDidDeactivate(_ session: WCSession) {
    // Begin the activation process for the new Apple Watch.
    WCSession.default.activate()
  }
  
  func sessionDidBecomeInactive(_ session: WCSession) {
  }
  
}
