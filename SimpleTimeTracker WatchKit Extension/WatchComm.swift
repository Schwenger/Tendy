////
////  WatchComm.swift
////  SimpleTimeTracker WatchKit Extension
////
////  Created by Maximilian Schwenger on 20.03.22.
////
//
//import SwiftUI
//import WatchConnectivity
//
//class WatchComm: NSObject, WCSessionDelegate {
//  var session: WCSession
//  let timeHandler: TimeHandler
//  init(session: WCSession = .default, timeHandler: TimeHandler){
//    self.session = session
//    self.timeHandler = timeHandler
//    super.init()
//    self.session.delegate = self
//    session.activate()
//  }
//  
//  func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
//    if error != nil || activationState != .activated {
//      // Handle better before going productive.
//      fatalError()
//    }
//    assert(error == nil)
//    assert(activationState == .activated)
//  }
//  
//  func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
//    Comm.receive(message, timeHandler: self.timeHandler)
//  }
//  
//  func send(_ data: [String : Any]) {
//    if session.activationState != .activated {
//      fatalError("Session not active.")
//    }
//    if session.isReachable {
//      session.sendMessage(data, replyHandler: nil, errorHandler: nil)
//    } else {
//      session.transferUserInfo(data)
//    }
//  }
//  
//}
