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
  @Published private var recentPast: [RecentWorkRecord]
//  @Published var cwd: CurrentWorkDay
  @Published private var workRecords: [WorkRecordProtocol]
  @Published private var recordMap: [YMD: WorkRecordProtocol]
  var moc: NSManagedObjectContext
  var settings: UserSettings
  
  init(from us: UserSettings, oldWorkRecords: [WorkRecord], moc: NSManagedObjectContext) {
    self.recentPast = us.recentWorkRecords
    self.workRecords = oldWorkRecords as! [WorkRecordProtocol]
    self.moc = moc
    self.recordMap = Self.reduceToMap(us.recentWorkRecords, oldWorkRecords)
    self.settings = us
  }
  
  private init(recentPast: [RecentWorkRecord], cwd: CurrentWorkDay, oldWorkRecords: [WorkRecord], moc: NSManagedObjectContext, settings: UserSettings) {
    self.recentPast = recentPast
    self.workRecords = oldWorkRecords as! [WorkRecordProtocol]
    self.moc = moc
    self.recordMap = Self.reduceToMap(recentPast, oldWorkRecords)
    self.settings = settings
  }
  
  static private func reduceToMap(_ recent: [RecentWorkRecord], _ old: [WorkRecord]) -> [YMD: WorkRecordProtocol] {
    let r: [WorkRecordProtocol] = recent
    let o: [WorkRecordProtocol] = old as! [WorkRecordProtocol]
    return (r + o).reduce(into: [:]) { $0[$1.date.ymd] = $1 }
  }
  
  func workRecordFor(date: Date, with cwd: CurrentWorkDay) -> WorkRecordProtocol? {
    if date.isSameDay(as: Date.now) {
      return cwd.asWorkRecord
    }
    return self.recordMap[date.ymd]
  }
  
  func overtime(_ cwd: CurrentWorkDay) -> TimeInterval {
    unifiedRecords(cwd).map { $0.timeWorked }.reduce(0.0, +)
  }
  
  func accept(_ rec: RecentWorkRecord?) {
    @EnvironmentObject var settings: UserSettings
    @Environment(\.managedObjectContext) var context
    let a = true
    assert(!a)
    // rework
  }
  
//  func workRecordsFor(m month: Int, y year: Int) -> MonthlyRecord {
//    let recs: [WorkRecordProtocol] = unifiedRecords
//      .filter { $0.date.month == month && $0.date.year == year}
//    return MonthlyRecord(m: month, y: year, records: recs)
//  }

  var _retrievedFromCoreData: Int {
    return workRecords.count
  }
  
  func unifiedRecords(_ cwd: CurrentWorkDay) -> [WorkRecordProtocol] {
    guard let today = cwd.asWorkRecord else {
      return workRecords + recentPast
    }
    return workRecords + recentPast + [today]
  }
  
  func displayMatrix(forY y: Int, andM m: Int, with cwd: CurrentWorkDay, numRows rows: Int = 6) -> [[RecordContainer]] {
    let allDays = DateHelper.allDaysInMonth(m: m, y: y)
    let containers = allDays.map { ($0, self.workRecordFor(date: $0, with: cwd)) }
      .map { wrapInContainer($0.0, $0.1) }
    var padded = nonePrefix(first: allDays.first!) + containers + noneSuffix(last: allDays.last!)
    let missingRows = rows - (padded.count / 7)
    padded.append(contentsOf: [RecordContainer](repeating: .None, count: 7 * missingRows))
    let res = Common.partitionIntoWeeks(padded)
    return res
  }
  
  private func wrapInContainer(_ date: Date, _ recOpt: WorkRecordProtocol?) -> RecordContainer {
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
  
}

extension Past {
  
  static var preview: Past {
    let recs: [RecentWorkRecord] = (0...5).map { i in
      let start = Date.now - TimeInterval.fromHAndMin(h: UInt(24 * (i + 1)), min: UInt(3 * i))
      let end = start + TimeInterval.fromHAndMin(h: UInt(5 + i), min: UInt(8 * i))
      let breaks: [Break]
      if i > 0 {
        let numBreaks = i % 2 + 1
        breaks = (1...numBreaks).map { j in
          Break(start: start + TimeInterval.fromH(h: UInt(j)), end: start + TimeInterval.fromHAndMin(h: UInt(j), min: 15))
        }
      } else {
        breaks = []
      }
      return RecentWorkRecord(start: start, breakTimes: breaks, end: end)
    }
    return Past(
      recentPast: recs,
      cwd: CurrentWorkDay.preview,
      oldWorkRecords: [],
      moc: DataController().container.viewContext,
      settings: UserSettings.preview
    )
  }
}


enum RecordContainer {
  case Past(WorkRecordProtocol)
  case Today(WorkRecordProtocol)
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
  
  var workRecord: WorkRecordProtocol? {
    switch self {
    case .Past(let rec), .Today(let rec): return rec
    case .Future, .Empty, .None, .FreeDay: return nil
    }
  }
}

struct MonthlyRecord {
  let month: Int
  let year: Int
  private let records: [WorkRecordProtocol]

  init(m month: Int, y year: Int, records: [WorkRecordProtocol]) {
    self.month = month
    self.year = year
    self.records = records
  }
  
  var fullMonthlyRecord: [Date: WorkRecordProtocol?] {
    let recByDate = records.reduce(into: [:]) { $0[$1.date] = $1 }
    return DateHelper.allDaysInMonth(m: month, y: year).reduce(into: [:]) { $0[$1] = recByDate[$1] }
  }
  
  func wrapInContainer(fullRecord: [Date: WorkRecordProtocol?], settings: UserSettings) -> [(Date, RecordContainer)] {
    return fullRecord.map { (date, optRec) in
      let container: RecordContainer
      if let rec = optRec {
        assert(Date.sameDay(rec.date, date))
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
