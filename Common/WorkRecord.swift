//
//  WorkRecord.swift
//  SimpleTimeTracker
//
//  Created by Maximilian Schwenger on 12.04.22.
//

import Foundation


struct RecentWorkRecord: Identifiable, Codable {
  let start: Date
  let breakTimes: [Break]
  let end: Date
  let id: UUID
  
  init?(from cs: ClockState) {
    assert(!cs.clockedIn || !cs.isFresh)
    switch cs {
    case .ClockedOut(let start, let breaks, let end):
      self = RecentWorkRecord(start: start, breakTimes: breaks, end: end)
    default: return nil
    }
  }
  
  init(start: Date, breakTimes: [Break], end: Date) {
    self.start = start
    self.breakTimes = breakTimes
    self.end = end
    self.id = UUID()
  }
  
  var totalBreakTime: TimeInterval {
    breakTimes.map { $0.dur }.reduce(0, +)
  }
  
  var timeWorked: TimeInterval {
    self.end.timeIntervalSince(start) - self.totalBreakTime
  }
  
  static func arbitraryConsecutive(n: UInt) -> [RecentWorkRecord] {
    let start: Date
    if Date.now.hour > 8 {
      start = Date.now - TimeInterval.fromH(h: UInt(Date.now.hour - 8))
    } else {
      start = Date.now
    }
    return (0...n).map {
      let end = start + TimeInterval.fromH(h: 8) - Double($0) * TimeInterval.fromH(h: 24)
      return Self(start: start, breakTimes: [], end: end)
    }
  }
  
  var asData: Data {
    try! JSONEncoder().encode(self)
  }
  
  static func fromData(_ data: Data) -> Self {
    try! JSONDecoder().decode(Self.self, from: data)
  }
  
  static var preview: Self {
    RecentWorkRecord(
      start: Date.now - TimeInterval.fromH(h: 8),
      breakTimes: [],
      end: Date.now - TimeInterval.fromH(h: 2)
    )
  }
  
}

protocol WorkRecordProtocol {
  var date: Date { get }
  var totalBreakTime: TimeInterval { get }
  var timeWorked: TimeInterval { get }
}

extension RecentWorkRecord: WorkRecordProtocol {
  var date: Date {
    self.start
  }
}

#if os(iOS) 
extension WorkRecord: WorkRecordProtocol {
  var date: Date {
    self.forDate!
  }
  
  var totalBreakTime: TimeInterval {
    self.breakTime
  }
  
  var timeWorked: TimeInterval {
    self.workTime
  }
  
}
#endif
