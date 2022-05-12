//
//  StackedHighlight.swift
//  SimpleTimeTracker
//
//  Created by Maximilian Schwenger on 19.03.22.
//

import SwiftUI

struct StackedHighlight<VM: ViewModifier>: View {
  let caption: String
  let highlight: String
  let additionalHighlight: VM
  
  init(caption: String, highlight: String, additionalHighlight: VM) {
    self.caption = caption
    self.highlight = highlight
    self.additionalHighlight = additionalHighlight
  }
  
  var body: some View {
    VStack {
      Text(caption)
        .font(.title3)
      Text(highlight)
        .bold()
        .font(.title)
        .modifier(additionalHighlight)
    }
    .padding(.horizontal)
    .font(.title2)
  }
}

extension StackedHighlight where VM == EmptyModifier {
  init(caption: String, highlight: String) {
    self.caption = caption
    self.highlight = highlight
    self.additionalHighlight = EmptyModifier()
  }
}

struct StackedHighlight_Previews: PreviewProvider {
  static var previews: some View {
    StackedHighlight(caption: "Estimated quitting time:", highlight: "18:40")
  }
}
