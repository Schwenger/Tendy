//
//  PastRecordDetailView.swift
//  SimpleTimeTracker
//
//  Created by Maximilian Schwenger on 11.05.22.
//

import SwiftUI

struct PastRecordDetailView: View {
  @Binding var record: WorkRecord?
  var body: some View {
    GeometryReader { geo in
      if let rec = record {
        VStack {
          Spacer()
          HStack {
            Spacer()
            VStack {
              SplitLine("Date:", rec.at.defaultFormatted)
              SplitLine("Time Worked:", rec.workTime.defaultFormatted)
              SplitLine("Total Break Time:", rec.breaks.defaultFormatted)
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
      PastRecordDetailView(record: .constant(WorkRecord.preview(DataController().container.viewContext)))
    }
}
