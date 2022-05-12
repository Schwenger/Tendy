//
//  UserDefault.swift
//  SimpleTimeTracker
//
//  Created by Maximilian Schwenger on 18.03.22.
//

import Foundation

class UserSettings: ObservableObject {
  @Published var recentWorkRecords: [RecentWorkRecord] {
    didSet {
      UserDefaults.standard.set(recentWorkRecords.map { $0.asData }, forKey: Keys.recentWorkRecords.key)
    }
  }
  
  @Published private var workDays: [Quota] {
    didSet {
      UserDefaults.standard.set(workDays.map { $0.asTimeInterval }, forKey: Keys.workdays.key)
    }
  }
  
  @Published var recentWorkRecordStorageLimit: UInt {
    didSet(old) {
      if recentWorkRecordStorageLimit == 0 {
        assert(false)
        recentWorkRecordStorageLimit = old
      }
      UserDefaults.standard.set(recentWorkRecordStorageLimit, forKey: Keys.storageLimits.key)
    }
  }
  
  init() {
    let timeIntervals = UserDefaults.standard.array(forKey: Keys.workdays.key) as? [TimeInterval]
    self.workDays = timeIntervals.map { $0.map { $0.asQuota } } ?? UserSettings.workdaysDefault
    self.recentWorkRecordStorageLimit = UserDefaults.standard.object(forKey: Keys.recentWorkRecords.key) as? UInt ?? UserSettings.recentWorkRecordStorageLimitDefault
    let workRecords = UserDefaults.standard.array(forKey: Keys.workdays.key) as? [Data]
    self.recentWorkRecords = workRecords.map { $0.map(RecentWorkRecord.fromData) } ?? UserSettings.recentWorkRecordsDefault
  }
  
}
  
extension UserSettings {
  var weeklyQuota: Quota {
    workDays.reduce(.zero, +)
  }
  func quota(_ day: Weekday) -> Quota {
    workDays[day.index]
  }
  func quota(_ date: Date) -> Quota {
    return workDays[DateHelper.weekday(from: date).index]
  }
  
  func reset() {
    self.workDays = Self.workdaysDefault
    self.recentWorkRecordStorageLimit = Self.recentWorkRecordStorageLimitDefault
    self.recentWorkRecords = Self.recentWorkRecordsDefault
  }
  
  func setQuota(for day: Weekday, _ quota: Quota) {
    workDays[day.index] = quota
  }
  
  enum Keys: String {
    case recentWorkRecords
    case workdays
    case storageLimits
    
    var key: String { self.rawValue }
  }
}

extension UserSettings {
  static let workdaysDefault: [Quota] = [
    Quota.zero,  // Sunday
    Quota.eight, // Monday
    Quota.eight, // Tuesday
    Quota.eight, // Wednesday
    Quota.eight, // Thursday
    Quota.eight, // Friday
    Quota.zero,  // Saturday
  ]
  static let defaultWorkdayQuota: Quota = .eight
  static let recentWorkRecordStorageLimitDefault: UInt = 30
  static let recentWorkRecordsDefault: [RecentWorkRecord] = []
}

extension UserSettings {
  static var preview: UserSettings {
    let us = UserSettings();
    us.recentWorkRecords = RecentWorkRecord.arbitraryConsecutive(n: 1)
    return us
  }
}
