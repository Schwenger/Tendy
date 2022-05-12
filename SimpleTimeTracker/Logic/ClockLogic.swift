//
//  ClockLogic.swift
//  SimpleTimeTracker
//
//  Created by Maximilian Schwenger on 12.05.22.
//

import Foundation

extension Past {
  var timeWorked: TimeInterval? { self.cwd?.timeWorked ?? 0.0 }
  
  func triggerBreak(atTime time: Date = Date.now) {
    assert(settings.clockState != .Fresh && settings.clockState != .ClockedOut)
    switch settings.clockState {
    case .ClockedIn:
      assert(self.cwd != nil)
      let newWorkTime = time.distance(to: settings.lastClockTriggerTime)
      self.cwd!.workTime += newWorkTime
      settings.clockState = .InBreak
    case .InBreak:
      assert(self.cwd != nil)
      let newBreakTime = time.distance(to: settings.lastClockTriggerTime)
      self.cwd!.breakTime += newBreakTime
      settings.clockState = .ClockedIn
    case .Fresh, .ClockedOut:
      fatalError()
    }
    settings.lastClockTriggerTime = time
  }
  
  func triggerWork(atTime time: Date = Date.now) {
    assert(settings.clockState != .ClockedIn)
    switch settings.clockState {
    case .ClockedIn:
      assert(false)
    case .InBreak:
      assert(self.cwd != nil)
      let newBreakTime = time.distance(to: settings.lastClockTriggerTime)
      self.cwd!.breakTime += newBreakTime
      settings.clockState = .ClockedOut
    case .Fresh:
      let record = self.getOrCreateCwd()
      record.date = time
      settings.clockState = .ClockedIn
    case .ClockedOut:
      assert(self.cwd != nil)
      settings.clockState = .ClockedIn
    }
    settings.lastClockTriggerTime = time
  }
  
  var totalBreakTime: TimeInterval? {
    self.cwd?.breakTime ?? TimeInterval.fromH(h: 0)
  }
  var canTriggerBreak: Bool {
    [.ClockedIn, .InBreak].contains(settings.clockState)
  }
  var canTriggerWork: Bool {
    true
  }
  var clockedIn: Bool {
    [.ClockedIn, .InBreak].contains(settings.clockState)
  }
  var inBreak: Bool {
    settings.clockState == .InBreak
  }
  var startTime: Date? {
    cwd?.at
  }
  var breakStartTime: Date? {
    inBreak ? settings.lastClockTriggerTime : nil
  }
  
  var expectedQuittingTime: Date {
    // TODO: Make way better
    let start = self.startTime ?? Date.now
    return start + TimeInterval.fromH(h: 8)
  }
}

enum ClockState {
  case ClockedIn
  case ClockedOut
  case Fresh
  case InBreak
}
