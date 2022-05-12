//
//  PastView.swift
//  SimpleTimeTracker
//
//  Created by Maximilian Schwenger on 18.03.22.
//

import SwiftUI
import Foundation

struct PastView: View {
  
  @EnvironmentObject var past: Past
  @EnvironmentObject var settings: UserSettings
  @EnvironmentObject var cwd: CurrentWorkDay
  @State var month: Int = Date.now.month
  @State var year: Int = Date.now.year
  
  @State var showDetailsOf: WorkRecordProtocol? = nil
  @State var showDetails: Bool = false
  
  let entryWidth: CGFloat = 33
  let rowHeight: CGFloat = 50
  let summaryColWidth: CGFloat = 50
  let entryPadding: CGFloat = 5
  
  var displayMatrix: [[RecordContainer]] {
    past.displayMatrix(forY: year, andM: month, with: cwd)
  }
  
  var body: some View {
    VStack {
      
      monthSelection
      
      Spacer()
      
      header
      
      matrix
      
      Spacer()
    }
    .sheet(isPresented: $showDetails, onDismiss: { showDetailsOf = nil; showDetails = false }) {
      PastRecordDetailView(record: $showDetailsOf)

    }
  }
  
  var monthSelection: some View {
    HStack {
      Image(systemName: "chevron.left")
        .onTapGesture {
          month -= 1
          if month < 1 {
            month = 12
            year -= 1
          }
        }
      Spacer()
      Text("\(DateHelper.monthYearString(m: month, y: year))")
      Spacer()
      Image(systemName: "chevron.right")
      .onTapGesture {
        month += 1
        if month > 12 {
          month = 1
          year += 1
        }
      }
    }
    .font(.title2)
    .padding(.horizontal)
    .padding(.horizontal)
    .padding(.horizontal)
  }
  
  var header: some View {
    HStack {
      ForEach(daysOfWeek, id: \.self) { day in
        Text(day.prefix(2))
          .font(.title3)
          .bold()
          .frame(width: entryWidth)
          .padding(entryPadding)
      }
    }
  }
  
  var matrix: some View {
    ForEach(0..<displayMatrix.count, id: \.self) { weekIdx in
      HStack {
        ForEach(0..<displayMatrix[weekIdx].count, id: \.self) { dayIdx in
          displayMatrix[weekIdx][dayIdx]
            .frame(width: entryWidth, height: rowHeight)
            .padding(entryPadding)
            .onTapGesture {
              if let record = displayMatrix[weekIdx][dayIdx].workRecord {
                self.showDetailsOf = record
                self.showDetails = true
              }
            }
        }
      }
    }
  }
  
  func weekTotal(_ weekIdx: Int) -> some View {
    let num = displayMatrix[weekIdx].map { $0.timeWorked }.reduce(0, +)
    if num >= settings.weeklyQuota.asTimeInterval {
      return Text(num.hourFormatted)
        .foregroundColor(.green)
    } else {
      return Text(num.hourFormatted)
        .foregroundColor(.orange)
    }
  }
  
  var daysOfWeek: [String] {
    DateHelper.weekdays().map(DateHelper.shortDisplayStr)
  }
  
}

extension RecordContainer: View {
  
  var body: some View {
    switch self {
    case .Past(let rec): WorkRecordView(record: rec)
    case .None: WorkRecordView.empty.opacity(0.0)
    case .Future: WorkRecordView.empty.opacity(0.4)
    case .Today(let rec): WorkRecordView(record: rec)
    case .Empty: WorkRecordView.empty.opacity(0.1)
    case .FreeDay: WorkRecordView.empty.opacity(0.1)
    }
  }
}

extension RecordContainer: WorkRecordProtocol {
  var date: Date {
    self.workRecord!.date
  }
  
  var totalBreakTime: TimeInterval {
    self.workRecord?.totalBreakTime ?? 0.0
  }
  
  var timeWorked: TimeInterval {
    self.workRecord?.timeWorked ?? 0.0
  }
}

struct PastView_Previews: PreviewProvider {
    static var previews: some View {
      PastView(month: Date.now.month)
        .environmentObject(Past.preview)
        .environmentObject(CurrentWorkDay.preview)
        .environmentObject(UserSettings.preview)
    }
}
