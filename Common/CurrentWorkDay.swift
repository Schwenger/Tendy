////
////  TimeHandler.swift
////  SimpleTimeTracker
////
////  Created by Maximilian Schwenger on 08.03.22.
////
//
//import Foundation
//import SwiftUI
//
//class CurrentWorkDay: CustomStringConvertible, ObservableObject {
//  @Published var state: ClockState
//
//  init(state: ClockState) {
//    self.state = state
//  }
//
//  var expectedQuittingTime: Date {
//    // TODO: Make way better
//    let start = self.state.startTime ?? Date.now
//    return start + TimeInterval.fromH(h: 8)
//  }
//
//  var asWorkRecord: WorkRecord? {
//    WorkRecord.init(from: self)
//  }
//
//  func quotaStatus(todaysQuota quota: TimeInterval) -> QuotaStatus {
//    switch self.state {
//    case .ClockedOut(_, _, _) where self.quotaReached(todaysQuota: quota),
//         .InBreak(_, _, _)    where self.quotaReached(todaysQuota: quota),
//         .ClockedIn(_, _)     where self.quotaReached(todaysQuota: quota):
//      return .hit
//    case .ClockedOut(_, _, _):
//      return .miss
//    case .ClockedIn(_, _), .InBreak(_, _, _), .Fresh:
//      return .stillPossible
//    }
//  }
//  func quotaReached(todaysQuota quota: TimeInterval) -> Bool {
//    switch self.state {
//    case .Fresh: return false
//    case .ClockedOut(_, _, _), .ClockedIn(_, _), .InBreak(_, _, _):
//      return self.timeWorked! >= quota
//    }
//  }
//
//  var shouldBeReplaced: Bool {
//    switch self.state {
//    case .Fresh: return false
//    case .ClockedOut(_, _, let end): return !end.isEarlierToday
//    default: return false
//    }
//  }
//
//  func replace() -> WorkRecord? {
//    self.state = .Fresh
//    fatalError()
//  }
//
//  var description: String { self.state.description }
//
//  static let preview: CurrentWorkDay = CurrentWorkDay(state: .Fresh)
//}
//
//extension CurrentWorkDay {
//  var clockInOutButtonLabel: Label<Text, Image> {
//    let imageSuffix = self.canTriggerWork ? ".fill" : ""
//    let inOut: String
//    switch self.state {
//    case .Fresh: inOut = "In"
//    case .ClockedIn(_, _), .InBreak(_, _, _): inOut = "Out"
//    case .ClockedOut(_, _, _): inOut = "Back In"
//    }
//    let imagePrefix: String
//    switch self.state {
//    case .Fresh: imagePrefix = "sunrise"
//    case .ClockedIn(_, _), .InBreak(_, _, _): imagePrefix = "sunset"
//    case .ClockedOut(_, _, _): imagePrefix = "moon"
//    }
//
//    return Label(LocalizedStringKey("Clock \(inOut)"), systemImage: imagePrefix + imageSuffix)
//  }
//
//  var breakInOutButtonLabel: Label<Text, Image> {
//    let imageSuffix = self.state.canTriggerBreak ? ".fill" : ""
//    let inOut = self.state.inBreak ? "End" : "Start"
//    let imagePrefix = self.state.inBreak ? "play" : "cup.and.saucer"
//
//    return Label(LocalizedStringKey("\(inOut) Break"), systemImage: imagePrefix + imageSuffix)
//  }
//}
//
///// Time Handler functions similar to the ClockState.  Hence, it reflects and forwards several functions.
//extension CurrentWorkDay {
//  var timeWorked: TimeInterval? { self.state.timeWorked }
//  func triggerBreak(atTime time: Date = Date.now) { self.state = self.state.triggerBreak(atTime: time) }
//  func triggerWork(atTime time: Date = Date.now) { self.state = self.state.triggerClock(atTime: time) }
//  var totalBreakTime: TimeInterval? { self.state.totalBreakTime }
//  var active: Bool { self.state.active }
//  var canTriggerBreak: Bool { self.state.canTriggerBreak }
//  var canTriggerWork: Bool { self.state.canTriggerWork }
//  var clockedIn: Bool { self.state.clockedIn }
//  var inBreak: Bool { self.state.inBreak }
//  var startTime: Date? { self.state.startTime }
//  var breakStartTime: Date? { self.state.breakStartTime }
//  var endTime: Date? { self.state.endTime }
//}
//
//enum QuotaStatus {
//  case stillPossible
//  case hit
//  case miss
//}
//
//struct Break: Codable {
//  let start: Date
//  let end: Date
//  var dur: TimeInterval {
//    end.timeIntervalSince(start)
//  }
//}
//
//enum ClockState {
//  case Fresh
//  case ClockedIn(start: Date, breaks: [Break])
//  case ClockedOut(start: Date, breaks: [Break], end: Date)
//  case InBreak(start: Date, breaks: [Break], breakStart: Date)
//
//  var active: Bool {
//    switch self {
//    case .Fresh, .ClockedIn(_, _), .InBreak(_, _, _) : return true
//    case .ClockedOut(start: _, breaks: _, end: _): return false
//    }
//  }
//  var isFresh: Bool {
//    switch self {
//    case .Fresh: return true
//    default: return false
//    }
//  }
//  var canTriggerBreak: Bool {
//    switch self {
//    case .ClockedIn(_, _), .InBreak(_, _, _): return true;
//    case .Fresh, .ClockedOut(_, _, _): return false;
//    }
//  }
//  var canTriggerWork: Bool {
//    switch self {
//    case .Fresh, .ClockedIn(_, _), .InBreak(_, _, _), .ClockedOut(_, _, _): return true;
//    }
//  }
//  var clockedIn: Bool {
//    switch self {
//    case .ClockedIn(_, _), .InBreak(_, _, _): return true
//    case .Fresh, .ClockedOut(_, _, _): return false
//    }
//  }
//  var inBreak: Bool {
//    switch self {
//    case .InBreak(_, _, _): return true
//    case .Fresh, .ClockedOut(_, _, _), .ClockedIn(_, _): return false
//    }
//  }
//  var startTime: Date? {
//    switch self {
//    case .Fresh: return nil
//    case .ClockedIn(let start, _), .ClockedOut(let start, _, _), .InBreak(let start, _, _): return start
//    }
//  }
//  var breakStartTime: Date? {
//    switch self {
//    case .InBreak(_, _, let breakStart): return breakStart
//    case .ClockedIn(_, _), .ClockedOut(_, _, _), .Fresh: return nil
//    }
//  }
//  var endTime: Date? {
//    switch self {
//    case .ClockedOut(_, _, let end): return end
//    case .ClockedIn(_, _), .InBreak(_, _, _), .Fresh: return nil
//    }
//  }
//  var timeWorked: TimeInterval? {
//    switch self {
//    case .Fresh: return nil
//    case .InBreak(let start, _, _), .ClockedIn(let start, _):
//      return Date.now.timeIntervalSince(start) - self.totalBreakTime!
//    case .ClockedOut(let start, _, let end):
//      return end.timeIntervalSince(start) - self.totalBreakTime!
//    }
//  }
//  var totalBreakTime: TimeInterval? {
//    switch self {
//    case .Fresh: return nil
//    case .ClockedOut(_, let breaks, _), .ClockedIn(_, let breaks):
//      return breaks.map { $0.dur }.reduce(0, +)
//    case .InBreak(_, let breaks, let bStart):
//      let completedBreakTime = breaks.map { $0.dur }.reduce(0, +)
//      let currentBreakTime = Date.now.timeIntervalSince(bStart)
//      return completedBreakTime + currentBreakTime
//    }
//  }
//  func triggerClock(atTime time: Date) -> ClockState {
//    switch self {
//    case .Fresh:
//      return .ClockedIn(start: time, breaks: [])
//    case .ClockedOut(let start, let breaks, _):
//      return .ClockedIn(start: start, breaks: breaks)
//    case .ClockedIn(let start, let breaks):
//      return .ClockedOut(start: start, breaks: breaks, end: time)
//    case .InBreak(let start, let breaks, let bStart):
//      let newBreak = Break(start: bStart, end: time)
//      return .ClockedOut(start: start, breaks: breaks + [newBreak], end: time)
//    }
//  }
//  func triggerBreak(atTime time: Date) -> ClockState {
//    switch self {
//    case .Fresh, .ClockedOut(_, _, _): fatalError()
//    case .ClockedIn(let start, let breaks):
//      return .InBreak(start: start, breaks: breaks, breakStart: time)
//    case .InBreak(let start, let breaks, let bStart):
//      let newBreak = Break(start: bStart, end: time)
//      return .ClockedIn(start: start, breaks: breaks + [newBreak])
//    }
//  }
//
//  public var description: String {
//    switch self {
//    case .Fresh: return "Fresh"
//    case .ClockedOut(_, _, _): return "Clocked Out"
//    case .ClockedIn(_, _): return "Clocked In"
//    case .InBreak(_, _, _): return "In Break"
//    }
//  }
//
//}
//
//
