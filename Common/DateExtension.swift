//
//  DateExtension.swift
//  SimpleTimeTracker
//
//  Created by Maximilian Schwenger on 22.04.22.
//

import Foundation

struct YMD: Hashable {
  let y: Int
  let m: Int
  let d: Int
  
  init(y: Int, m: Int, d: Int) {
    self.y = y
    self.m = m
    self.d = d
  }
}

extension Date {
  var defaultFormatted: String {
    self.formatted(date: .omitted, time: .shortened)
  }
  var isEarlierToday: Bool {
    Calendar.current.startOfDay(for: Date.now) <= self && self <= Date.now
  }
  var firstDayOfMonth: Date {
    return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: self))!
  }
  static func sameDay(_ d1: Date, _ d2: Date) -> Bool {
    Calendar.current.isDate(d1, equalTo: d2, toGranularity: .day)
  }
  func isSameDay(as other: Date) -> Bool {
    Self.sameDay(self, other)
  }
  var month: Int {
    Calendar.current.component(.month, from: self)
  }
  var day: Int {
    Calendar.current.component(.day, from: self)
  }
  var hour: Int {
    Calendar.current.component(.hour, from: self)
  }
  var weekday: Int {
    Calendar.current.component(.weekday, from: self)
  }
  var year: Int {
    Calendar.current.component(.year, from: self)
  }
  var ymd: YMD {
    YMD(y: self.year, m: self.month, d: self.day)
  }
}

extension TimeInterval {
  var defaultFormatted: String {
    let formatter = DateComponentsFormatter()
    formatter.allowedUnits = [.hour, .minute]
    formatter.unitsStyle = .abbreviated
    return formatter.string(from: self)!
  }
  
  var hourFormatted: String {
    let (whole, frac) = modf(self.hours)
    if frac == 0 {
      return "\(Int(whole))"
    } else {
      return "\(String(format: "%2.1f", self.hours))"
    }
  }
  
  static func fromMin(min: UInt) -> Self {
    TimeInterval.fromHAndMin(h: 0, min: min)
  }
  
  static func fromH(h: UInt) -> Self {
    TimeInterval.fromHAndMin(h: h, min: 0)
  }
  
  static func fromHAndMin(h: UInt, min: UInt) -> Self {
    TimeInterval(h*60*60 + min*60)
  }
  
  static func fromHAndMinNeg(h: UInt = 0, min: UInt = 0) -> Self {
    TimeInterval(-Int(h*60*60 + min*60))
  }
  var hoursRoundedDown: UInt {
    UInt(self / (60*60))
  }
  var hours: Double {
    self / (60.0*60.0)
  }
  var mins: Double {
    self / 60.0
  }
  func roundToQuarterHour(_ rule: FloatingPointRoundingRule) -> Self {
    (self.hours * 4).rounded(rule) / 4.0 * 60 * 60
  }
}
