//
//  SplitLine.swift
//  SimpleTimeTracker
//
//  Created by Maximilian Schwenger on 11.05.22.
//

import SwiftUI

struct SplitLine<Leading: View, Trailing: View>: View {
  let leading: Leading
  let trailing: Trailing
  
  init(@ViewBuilder leading: () -> Leading, @ViewBuilder trailing: () -> Trailing) {
    self.leading = leading()
    self.trailing = trailing()
  }
  
  var body: some View {
    HStack {
      leading
      Spacer()
      trailing
    }
  }
}

extension SplitLine where Leading == Text, Trailing == Text {
  init(_ leading: LocalizedStringKey, _ trailing: String) {
    self.leading = Text(leading)
    self.trailing = Text(trailing)
  }
}

extension SplitLine where Leading == Text, Trailing == Image {
  init(_ leading: LocalizedStringKey, systemName: String) {
    self.leading = Text(leading)
    self.trailing = Image(systemName: systemName)
  }
}

struct SplitLine_Previews: PreviewProvider {
    static var previews: some View {
      SplitLine { Text("A") } trailing: { Text("B") }
    }
}
