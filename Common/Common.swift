//
//  Common.swift
//  SimpleTimeTracker
//
//  Created by Maximilian Schwenger on 08.03.22.
//

import Foundation
import SwiftUI



struct Common {
  static func partitionIntoWeeks<T>(_ linearized: [T], daysPerWeek dpw: Int = 7) -> [[T]] {
    var linearized = linearized
    var res = [[T]]()
    while linearized.count > dpw {
      res.append(Array(linearized[..<dpw]))
      linearized = Array(linearized[dpw...])
    }
    res += [linearized]
    return res
  }
}

func todo() -> Never {
  while true {}
}

struct ViewForegroundColor: ViewModifier {
  var color: Color
  
  init(_ color: Color) {
    self.color = color
  }
  
  @ViewBuilder
  func body(content: Content) -> some View {
    content.foregroundColor(color)
  }
}
