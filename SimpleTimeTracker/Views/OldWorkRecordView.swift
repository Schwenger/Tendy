//
//  WorkRecordView.swift
//  SimpleTimeTracker
//
//  Created by Maximilian Schwenger on 31.03.22.
//

import SwiftUI

struct AltWorkRecordView: View {
  
  @EnvironmentObject var settings: UserSettings
  var record: WorkRecord
  private var positive: Color = .green
  private var negative: Color = .orange
  private var neutral: Color = .accentColor
  
  init(record: WorkRecord) {
    self.record = record
  }
  
//  private init(positive: Color? = nil, negative: Color? = nil, neutral: Color? = nil) {
//    self.record = RecentWorkRecord(start: Date.now, breakTimes: [], end: Date.now)
//    if let pos = positive { self.positive = pos }
//    if let neg = negative { self.negative = neg }
//    if let neu = neutral { self.neutral = neu }
//  }
//
//  static var empty: Self {
//    // todo: Maybe move to init
//    Self(negative: .gray)
//  }
  
  var quota: Double {
    settings.quota(record.at).asTimeInterval
  }
  
  var relativeToQuota: Double {
    guard self.quota > 0.0 else {
      return 0.0
    }
    return record.timeWorked / self.quota
  }
  
  var quotaProgress: Double {
    min(1.0, relativeToQuota)
  }
  var overtime: Double {
    max(0.0, relativeToQuota - 1.0)
  }
  var undertime: Double {
    max(0.0, 1 - relativeToQuota)
  }
  
  var lineWidth: Double { 17 }
  
  var body: some View {
    ZStack {
      CircularProgressBar(progress: .constant(1), lineWidth: self.lineWidth, color: self.neutral, opacity: 0.3)
      CircularProgressBar(progress: .constant(self.quotaProgress), lineWidth: self.lineWidth, color: self.neutral) //{
//        Text(String(format: "%.f %%", min(self.quotaProgress, 1.0) * 100.0))
//          .bold()
//      }
      CircularProgressBar(progress: .constant(self.overtime), lineWidth: self.lineWidth, color: self.positive)
      CircularProgressBar(progress: .constant(self.undertime), lineWidth: self.lineWidth, color: self.negative, inverted: true)
    }
  }
}

struct AltWorkRecordView_Previews: PreviewProvider {
    static var previews: some View {
      let record = WorkRecord.preview(DataController().container.viewContext)
      AltWorkRecordView(record: record)
        .frame(width: 30)
        .environmentObject(UserSettings.preview)
    }
}
