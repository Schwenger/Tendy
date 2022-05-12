//
//  CircularProgressBar.swift
//  SimpleTimeTracker
//
//  Created by Maximilian Schwenger on 19.03.22.
//

import SwiftUI

// Taken and adapted from https://www.simpleswiftguide.com/how-to-build-a-circular-progress-bar-in-swiftui/
struct CircularProgressBar<Content: View>: View {
  @Binding var progress: Double
  let lineWidth: CGFloat
  let color: Color
  let content: Content
  let opacity: Double
  let inverted: Bool
  
  var angle: Double {
    if inverted {
      return -90.0 - 360.0 * progress
    } else {
      return -90.0
    }
  }
  
  init(progress: Binding<Double>, lineWidth: CGFloat = 10.0, color: Color = .accentColor, opacity: Double = 1.0, inverted: Bool = false, @ViewBuilder content: () -> Content) {
    self._progress = progress
    self.color = color
    self.lineWidth = lineWidth
    self.inverted = inverted
    self.opacity = opacity
    self.content = content()
  }
  
  var body: some View {
    ZStack {
      Circle()
        .trim(from: 0.0, to: CGFloat(min(self.progress, 1.0)))
        .stroke(style: StrokeStyle(lineWidth: self.lineWidth, lineCap: .butt, lineJoin: .round))
        .foregroundColor(self.color)
        .opacity(self.opacity)
        .rotationEffect(Angle(degrees: angle))
      self.content
    }
  }
}

extension CircularProgressBar where Content == EmptyView {
  init(progress: Binding<Double>, lineWidth: CGFloat = 10.0, color: Color = .accentColor, opacity: Double = 1.0, inverted: Bool = false) {
    self._progress = progress
    self.color = color
    self.lineWidth = lineWidth
    self.opacity = opacity
    self.inverted = inverted
    self.content = EmptyView()
  }
}

struct CircularProgressBar_Previews: PreviewProvider {
    static var previews: some View {
      CircularProgressBar(progress: .constant(0.3), inverted: true) {
        Text("Hello")
      }
    }
}
