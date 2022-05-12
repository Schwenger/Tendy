//
//  WorkRecord.swift
//  SimpleTimeTracker
//
//  Created by Maximilian Schwenger on 12.04.22.
//

import Foundation
import CoreData

extension WorkRecord {
  var timeWorked: TimeInterval {
    self.workTime
  }
  
  var at: Date {
    self.date!
  }
  
  var uuid: UUID {
    self.id!
  }
  
  var breaks: TimeInterval {
    self.breakTime
  }
  
  static func arbitraryConsecutive(n: UInt, _ moc: NSManagedObjectContext) -> [WorkRecord] {
    return (0...n).map {
      let start =  Calendar.current.date(byAdding: .day, value: -Int($0), to: Date.now)
      let rec = WorkRecord(context: moc)
      rec.id = UUID()
      rec.date = start
      rec.workTime = TimeInterval.fromHAndMin(h: 6 + ($0 % 4), min: $0 % 60)
      rec.breakTime = TimeInterval.fromMin(min: (3 * $0) % 60)
      try! moc.save()
      return rec
    }
  }
  
//  convenience init(from cwd: CurrentWorkDay, with moc: NSManagedObjectContext) {
//    self.init(context: moc)
//    self.id = UUID()
//    self.date = cwd.startTime
//    self.workTime = cwd.timeWorked ?? TimeInterval.fromH(h: 0)
//    self.breakTime = cwd.totalBreakTime ?? TimeInterval.fromMin(min: 0)
//  }
  
  static func empty(_ moc: NSManagedObjectContext, for date: Date = Date.now) -> WorkRecord {
    let record = WorkRecord(context: moc)
    record.id = UUID()
    record.breakTime = 0.0
    record.workTime = 0.0
    record.date = date
    return record
  }
  
  static func preview(_ moc: NSManagedObjectContext) -> WorkRecord {
    self.arbitraryConsecutive(n: 1, moc).first!
  }

}
