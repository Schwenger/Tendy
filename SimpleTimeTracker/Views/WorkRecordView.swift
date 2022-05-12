//
//  AltWorkRecordView.swift
//  SimpleTimeTracker
//
//  Created by Maximilian Schwenger on 11.05.22.
//

import SwiftUI

struct WorkRecordView: View {
  
  @EnvironmentObject var settings: UserSettings
  var record: WorkRecordProtocol
  var positive: Color = .green
  var negative: Color = .orange
  var neutral: Color = .accentColor
  
  var quota: Quota {
    settings.quota(record.date)
  }
  
  var isFreeDay: Bool {
    DateHelper.isFreeDay(record.date, settings)
  }
  
  var progress: Double {
    let expected: TimeInterval
    if isFreeDay && record.timeWorked > 0.0 {
      expected = settings.weeklyQuota.divide(by: DateHelper.numWorkDays(settings)).asTimeInterval
    } else {
      expected = quota.asTimeInterval
    }
    let was = record.timeWorked
    return was / expected
  }
  
  var lineWidth: Double { 1 }
  
  init(record: WorkRecordProtocol) {
    self.record = record
  }
  
  private init(positive: Color? = nil, negative: Color? = nil, neutral: Color? = nil) {
    self.record = RecentWorkRecord(start: Date.now, breakTimes: [], end: Date.now)
    if let pos = positive { self.positive = pos }
    if let neg = negative { self.negative = neg }
    if let neu = neutral { self.neutral = neu }
  }
  
  static var empty: Self {
    Self(neutral: .gray)
  }
  
  var body: some View {
    GeometryReader { geo in
      ZStack {
        ForEach(self.progressEntities, id: \.self) { entity in
          CapsuleProgressBar(
            progress: .constant(entity.frac),
            lineWidth: self.lineWidth,
            color: entity.color,
            cornerRadius: geo.size.height * 0.05,
            opacity: entity.opacity
          )
        }
      }
    }
  }
  
  var progressEntities: [Entity] {
    if isFreeDay {
      return [
        Entity.bg(neutral),
        Entity.prog(progress, positive),
      ]
    } else if self.progress > 1.0 {
      return [
        Entity.bg(neutral),
        Entity.prog(1.0, neutral),
        Entity.prog(progress - 1.0, positive),
      ]
    } else if self.progress >= 0.5 {
      return [
        Entity.bg(neutral),
        Entity.prog(progress, neutral),
      ]
    } else if record.date > Date.now {
      return [
        Entity.bg(neutral),
      ]
    } else {
      return [
        Entity.bg(negative),
        Entity.prog(progress, negative),
      ]
    }
  }
    
  struct Entity: Hashable {
    let frac: Double
    let color: Color
    let opacity: CGFloat
    init(frac: Double, opacity: CGFloat, _ color: Color) {
      self.frac = frac
      self.color = color
      self.opacity = opacity
    }
    static func bg(_ color: Color) -> Self {
      Entity(frac: 1.0, opacity: 0.3, color)
    }
    static func prog(_ prog: Double, _ color: Color) -> Self {
      Entity(frac: prog, opacity: 1.0, color)
    }
  }
}

struct WorkRecordView_Previews: PreviewProvider {
    static var previews: some View {
      WorkRecordView(record: RecentWorkRecord.preview)
        .frame(width: 60, height: 150)
        .environmentObject(UserSettings.preview)
    }
}
