//
//  PastWorkTimes.swift
//  SimpleTimeTracker
//
//  Created by Maximilian Schwenger on 30.03.22.
//

import Foundation
import CoreData
import SwiftUI

class Past: ObservableObject {
  @Published private var workRecords: [WorkRecord]
  @Published private var recordMap: [YMD: WorkRecord]
  var moc: NSManagedObjectContext
  var settings: UserSettings
  
  private func createCwd() -> WorkRecord {
    assert(cwd == nil)
    let record = WorkRecord.empty(moc)
    settings.mostRecentRecord = record.uuid
    self.recordMap[record.at.ymd] = record
    return record
  }
  
  func getOrCreateCwd() -> WorkRecord {
    self.cwd ?? createCwd()
  }
  
  var cwd: WorkRecord? {
    return workRecords.first(where: { $0.uuid == settings.mostRecentRecord })
  }
  
  init(from us: UserSettings, workRecords: [WorkRecord], moc: NSManagedObjectContext) {
    self.moc = moc
    self.workRecords = workRecords
    self.recordMap = Self.reduceToMap(workRecords)
    self.settings = us
  }
  
  static private func reduceToMap(_ records: [WorkRecord]) -> [YMD: WorkRecord] {
    records.reduce(into: [:]) { $0[$1.at.ymd] = $1 }
  }
  
  func workRecordFor(date: Date) -> WorkRecord? {
    self.recordMap[date.ymd]
  }
  
  func overtime() -> TimeInterval {
    workRecords.map { $0.timeWorked }.reduce(0.0, +)
  }

  var _retrievedFromCoreData: Int {
    return workRecords.count
  }
  
//  func unifiedRecords(_ cwd: CurrentWorkDay) -> [WorkRecord] {
//    guard let today = cwd.asWorkRecord else {
//      return workRecords
//    }
//    return workRecords + [today]
//  }
  
  func displayMatrix(forY y: Int, andM m: Int, numRows rows: Int = 6) -> [[RecordContainer]] {
    let allDays = DateHelper.allDaysInMonth(m: m, y: y)
    let containers = allDays.map { ($0, self.workRecordFor(date: $0)) }
      .map { wrapInContainer($0.0, $0.1) }
    var padded = nonePrefix(first: allDays.first!) + containers + noneSuffix(last: allDays.last!)
    let missingRows = rows - (padded.count / 7)
    padded.append(contentsOf: [RecordContainer](repeating: .None, count: 7 * missingRows))
    let res = Common.partitionIntoWeeks(padded)
    return res
  }
  
  private func wrapInContainer(_ date: Date, _ recOpt: WorkRecord?) -> RecordContainer {
    if let rec = recOpt {
      assert(date <= Date.now)
      if date.isSameDay(as: Date.now) {
        return .Today(rec)
      } else {
        return .Past(rec)
      }
    } else {
      if DateHelper.isFreeDay(date, settings) {
        return .FreeDay
      } else if date > Date.now {
        return .Future
      } else {
        return .Empty
      }
    }
  }
  
  private func nonePrefix(first: Date) -> [RecordContainer] {
    let weekday = Weekday.from(weekday: first.weekday)
    let prefixLen = weekday.displayIndex
    return [RecordContainer](repeating: .None, count: prefixLen)
  }
  
  private func noneSuffix(last: Date) -> [RecordContainer] {
    let weekday = Weekday.from(weekday: last.weekday)
    let suffixLen = 7 - weekday.displayIndex - 1
    return [RecordContainer](repeating: .None, count: suffixLen)
  }
  
  static var preview: Past {
    let us = UserSettings()
    let moc = DataController().container.viewContext
    let records = WorkRecord.arbitraryConsecutive(n: 100, moc)
    return Past(from: us, workRecords: records, moc: moc)
  }
}

enum RecordContainer {
  case Past(WorkRecord)
  case Today(WorkRecord)
  case FreeDay
  case Future
  case Empty
  case None
  
  var toString: String {
    switch self {
    case .FreeDay: return "Free"
    case .Past(_): return "Past"
    case .Future: return "Future"
    case .Empty: return "Empty"
    case .Today(_): return "Today"
    case .None: return "None"
    }
  }
  
  var workRecord: WorkRecord? {
    switch self {
    case .Past(let rec), .Today(let rec): return rec
    case .Future, .Empty, .None, .FreeDay: return nil
    }
  }
}

struct MonthlyRecord {
  let month: Int
  let year: Int
  private let records: [WorkRecord]

  init(m month: Int, y year: Int, records: [WorkRecord]) {
    self.month = month
    self.year = year
    self.records = records
  }
  
  var fullMonthlyRecord: [Date: WorkRecord?] {
    let recByDate = records.reduce(into: [:]) { $0[$1.date] = $1 }
    return DateHelper.allDaysInMonth(m: month, y: year).reduce(into: [:]) { $0[$1] = recByDate[$1] }
  }
  
  func wrapInContainer(fullRecord: [Date: WorkRecord?], settings: UserSettings) -> [(Date, RecordContainer)] {
    return fullRecord.map { (date, optRec) in
      let container: RecordContainer
      if let rec = optRec {
        assert(Date.sameDay(rec.at, date))
        if Date.sameDay(date, Date.now) {
          container = RecordContainer.Today(rec)
        } else {
          container = RecordContainer.Past(rec)
        }
      } else {
        if date < Date.now && !Date.sameDay(date, Date.now) {
          container = RecordContainer.Empty
        } else if DateHelper.isFreeDay(date, settings) {
          container = RecordContainer.FreeDay
        } else {
          container = RecordContainer.Future
        }
      }
      return (date, container)
    }
  }
  
  func displayMatrix(_ settings: UserSettings) -> [[RecordContainer]] {
    let main = self.wrapInContainer(fullRecord: fullMonthlyRecord, settings: settings)
    let firstDate = main.min(by: { $0.0 < $1.0 })!.0
    let lastDate = main.max(by: { $0.0 < $1.0 })!.0
    let nonePrefix = nonePrefix(first: firstDate)
    let futureSuffix = futureSuffix(last: lastDate)
    let all = nonePrefix + main.map { $0.1 } + futureSuffix
    return Common.partitionIntoWeeks(all, daysPerWeek: 7)
  }
  
  func nonePrefix(first: Date) -> [RecordContainer] {
    let weekday = Weekday.from(weekday: first.weekday)
    let prefixLen = weekday.displayIndex
    return [RecordContainer](repeating: .None, count: prefixLen)
  }
  
  func futureSuffix(last: Date) -> [RecordContainer] {
    let weekday = Weekday.from(weekday: last.weekday)
    let suffixLen = 7 - weekday.displayIndex - 1
    return [RecordContainer](repeating: .Future, count: suffixLen)
  }
}
