//
//  PastRecordDetailView.swift
//  SimpleTimeTracker
//
//  Created by Maximilian Schwenger on 11.05.22.
//

import SwiftUI

struct PastRecordDetailView: View {
  @Binding var record: WorkRecordProtocol?
  var body: some View {
    GeometryReader { geo in
      if let rec = record {
        VStack {
          Spacer()
          HStack {
            Spacer()
            VStack {
              SplitLine("Date:", rec.date.defaultFormatted)
              SplitLine("Time Worked:", rec.timeWorked.defaultFormatted)
              SplitLine("Total Break Time:", rec.totalBreakTime.defaultFormatted)
            }
            .frame(width: geo.size.width * 0.7)
            Spacer()
          }
          Spacer()
        }
      }
    }
  }
}

struct PastRecordDetailView_Previews: PreviewProvider {
    static var previews: some View {
      PastRecordDetailView(record: .constant(RecentWorkRecord.preview))
    }
}
