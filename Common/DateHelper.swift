//
//  DateHandler.swift
//  SimpleTimeTracker
//
//  Created by Maximilian Schwenger on 13.04.22.
//

import Foundation
import SwiftUI

struct DateHelper {
  static func daysInMonth(m month: Int, y year: Int) -> Int {
    let firstInMonth = Self.firstDayOfMonth(m: month, y: year)
    let range = Calendar.current.range(of: .day, in: .month, for: firstInMonth)!
    return range.count
  }
  
  static func allDaysInMonth(m month: Int, y year: Int) -> [Date] {
    let firstDay = Self.firstDayOfMonth(m: month, y: year)
    return (0..<Self.daysInMonth(m: month, y: year))
      .map { Calendar.current.date(byAdding: .day, value: $0, to: firstDay)! }
  }
  
  static func firstDayOfMonth(m month: Int, y year: Int) -> Date {
    var components = DateComponents();
    components.month = month
    components.year = year
    return Calendar.current.date(from: components)!
  }
  
  static func monthYearString(m month: Int, y year: Int) -> String {
    Self.firstDayOfMonth(m: month, y: year)
      .formatted(Date.FormatStyle().month(.wide).year())
  }
  
  static func shortDisplayStr(_ day: Weekday) -> String {
    Calendar.current.shortWeekdaySymbols[day.index]
  }
  
  static func veryShortDisplayStr(_ day: Weekday) -> String {
    Calendar.current.veryShortWeekdaySymbols[day.index]
  }
  
  static func weekdays() -> [Weekday] {
    let pivotIdx = Calendar.current.firstWeekday
    let res = (Array((pivotIdx..<7)) + Array((0..<pivotIdx)))
      .map { Weekday.from(index: $0)}
    return res
  }
  
  static func weekday(from date: Date) -> Weekday {
    Weekday.from(weekday: Calendar.current.component(.weekday, from: date))
  }
  
  static func workDays(us: UserSettings) -> [Weekday] {
    weekdays().filter { us.quota($0).notFree }
  }
  
  static func numWorkDays(_ settings: UserSettings) -> Int {
    Self.workDays(us: settings).count
  }
  
  static func isFreeDay(_ date: Date, _ settings: UserSettings) -> Bool {
    settings.quota(Self.weekday(from: date)).free
  }
}

enum Weekday: Int, CustomStringConvertible, Identifiable, CaseIterable, Equatable {
  
  case Sunday = 0
  case Monday = 1
  case Tuesday = 2
  case Wednesday = 3
  case Thursday = 4
  case Friday = 5
  case Saturday = 6
  
  static var regularWorkWeek: [Self] {
    [.Monday, .Tuesday, .Wednesday, .Thursday, .Friday]
  }
  
  static var regularWeekend: [Self] {
    [.Saturday, .Sunday]
  }
  
  static func from(weekday: Int) -> Self {
    Self(rawValue: weekday - (Calendar.current.firstWeekday))!
  }
  
  static func from(index: Int) -> Self {
    Self(rawValue: index)!
  }
  
  var index: Int {
    self.rawValue
  }
  
  var displayIndex: Int {
    DateHelper.weekdays().firstIndex(of: self)!
  }
  
  var id: Int {
    self.rawValue
  }
  
  var leastDay: Self {
    .Sunday
  }
  
  var greatestDay: Self {
    .Saturday
  }
  
  var description: String {
    switch self {
    case .Monday: return "Monday"
    case .Tuesday: return "Tuesday"
    case .Wednesday: return "Wednesday"
    case .Thursday: return "Thursday"
    case .Friday: return "Friday"
    case .Saturday: return "Saturday"
    case .Sunday: return "Sunday"
    }
  }
}

struct Quota: Codable {
  let hours: Int
  let mins: Int
  
  static func == (lhs: Quota, rhs: Quota) -> Bool {
    lhs.hours == rhs.hours && lhs.mins == rhs.mins
  }
  
  var free: Bool {
    hours == 0 && mins == 0
  }
  
  var notFree: Bool {
    !self.free
  }
  
  static func +(left: Self, right: Self) -> Self {
    if left.mins + right.mins >= 60 {
      return Self(hours: left.hours + right.hours + 1, mins: (left.mins + right.mins) % 60)
    }
    return Self(hours: left.hours + right.hours, mins: left.mins + right.mins)
  }
  
  static func +(left: Self, right: UInt) -> Self {
    let totalMins = left.mins + Int(right)
    let hours = left.hours + totalMins / 60
    let mins = totalMins % 60
    return Self(hours: hours, mins: mins)
  }
  
  static func -(left: Self, right: UInt) -> Self {
    // I'm too tired for maths right now.
    var h = left.hours
    var m = left.mins - Int(right)
    while m < 0 {
      h -= 1
      m += 60
    }
    return Self(hours: h, mins: m)
  }
  
  var asTimeInterval: TimeInterval {
    TimeInterval.fromHAndMin(h: UInt(self.hours), min: UInt(self.mins))
  }
  
  static var zero: Quota {
    Quota(hours: 0, mins: 0)
  }
  
  static var eight: Quota {
    Quota(hours: 8, mins: 0)
  }
  
  var rounded: Self {
    let rem = self.mins % 15
    let mins: Int
    if rem <= 7 {
      mins = self.mins - rem
    } else {
      mins = self.mins - 15 + rem
    }
    if mins == 60 {
      return Quota(hours: self.hours + 1, mins: 0)
    } else {
      return Quota(hours: self.hours, mins: mins)
    }
  }
  
  func divide(by n: Int) -> Self {
    let total = self.hours * 60 + self.mins
    let perDay = total / n
    return Self(hours: perDay / 60, mins: perDay % 60)
  }
  
  var defaultFormatted: String {
    self.asTimeInterval.defaultFormatted
  }
}

extension Quota: Strideable {
  typealias Stride = Int
  
  func distance(to other: Quota) -> Int {
    let δh = self.hours - other.hours
    let δm = self.mins - other.mins
    return δh * 4 + δm / 15
  }
  
  func advanced(by n: Int) -> Quota {
    if n > 0 {
      return self + UInt(n)
    } else {
      return self - UInt(-n)
    }
  }
}

extension Quota: CustomStringConvertible {
  var description: String {
    self.defaultFormatted
  }
}

extension TimeInterval {
  var asQuota: Quota {
    Quota(hours: Int(self.hours), mins: Int(self.mins))
  }
}
