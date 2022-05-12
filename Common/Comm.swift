//
//  Comm.swift
//  SimpleTimeTracker
//
//  Created by Maximilian Schwenger on 20.03.22.
//

import Foundation
import WatchConnectivity

class Comm: NSObject, WCSessionDelegate {
  var session: WCSession
  var past: Past
  
  init(session: WCSession = .default, _ past: Past){
    self.session = session
    self.past = past
    super.init()
    self.session.delegate = self
    session.activate()
  }
  
  func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    if error != nil || activationState != .activated {
      // Handle better before going productive.
      fatalError()
    }
    assert(error == nil)
    assert(activationState == .activated)
  }
  
  func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
    self.receive(message)
  }
  
  func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any]) {
    DispatchQueue.main.async{
      self.receive(userInfo)
    }
  }
  
  func send(_ data: [String : Any]) {
    if session.activationState != .activated {
      fatalError("Session not active.")
    }
    if session.isReachable {
      session.sendMessage(data, replyHandler: nil, errorHandler: nil)
    } else {
      session.transferUserInfo(data)
    }
  }

  
  static func receive(_ data: [String: Any]) -> Message {
    Message(
      when: data["when"] as! Date,
      what: What(rawValue: data["what"] as! String)!,
      inOut: InOut(rawValue: data["inOut"] as! String)!
    )
  }

}

extension Comm {
  static func sendClockTrigger(when time: Date, inOut: InOut) -> [String: Any] {
    ["when": time, "what": What.Clock.rawValue, "in": inOut.rawValue]
  }
  static func sendClockIn(when time: Date) -> [String: Any] {
    self.sendClockTrigger(when: time, inOut: .In)
  }
  static func sendClockOut(when time: Date) -> [String: Any] {
    self.sendClockTrigger(when: time, inOut: .Out)
  }
  static func sendBreakTrigger(when time: Date, inOut: InOut) -> [String: Any] {
    ["when": time, "what": "clock", What.Break.rawValue: inOut.rawValue]
  }

  func receive(_ data: [String : Any]) {
    let message = Comm.receive(data)
    switch (message.what, message.inOut) {
    case (.Clock, .In):
      assert(!past.clockedIn)
      assert(past.canTriggerWork)
      past.triggerWork(atTime: message.when)
    case (.Clock, .Out):
      assert(past.clockedIn)
      assert(past.canTriggerWork)
      past.triggerWork(atTime: message.when)
    case (.Break, .In):
      assert(!past.inBreak)
      assert(past.canTriggerBreak)
      past.triggerBreak(atTime: message.when)
    case (.Break, .Out):
      assert(past.inBreak)
      assert(past.canTriggerBreak)
      past.triggerBreak(atTime: message.when)
    }
  }
}

enum Keys: String {
   case When = "when"
   case What = "what"
   case inOut = "inOut"
 }
                 
struct Message {
  let when: Date
  let what: What
  let inOut: InOut
}

enum What: String {
  case Clock = "clock"
  case Break = "break"
}

enum InOut: String {
  case In = "in"
  case Out = "out"
}
