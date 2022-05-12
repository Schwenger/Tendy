//
//  CapsuleProgressBar.swift
//  SimpleTimeTracker
//
//  Created by Maximilian Schwenger on 11.05.22.
//

import SwiftUI

struct CapsuleProgressBar<Content: View>: View {
  @Binding var _progress: Double
  let lineWidth: CGFloat
  let cornerRadius: CGFloat
  let color: Color
  let content: Content
  let opacity: Double
  
  var progress: Double {
    max(0.0, min(1.0, _progress))
  }
  
  init(
    progress: Binding<Double>,
    lineWidth: CGFloat = 10.0,
    color: Color = .accentColor,
    cornerRadius: CGFloat = 5.0,
    opacity: Double = 1.0,
    @ViewBuilder content: () -> Content
  ) {
    self.__progress = progress
    self.color = color
    self.lineWidth = lineWidth
    self.opacity = opacity
    self.content = content()
    self.cornerRadius = cornerRadius
  }
  
  var body: some View {
    GeometryReader { geo in
      VStack {
        Spacer()
          .frame(height: (1.0 - progress) * geo.size.height)
        RoundedRectangle(cornerRadius: cornerRadius)
          .foregroundColor(color)
          .opacity(opacity)
          .frame(height: geo.size.height * progress)
          .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
              .stroke(lineWidth: self.lineWidth)
              .foregroundColor(.secondary)
          )
      }
    }
  }
}

extension CapsuleProgressBar where Content == EmptyView {
  init(
    progress: Binding<Double>,
    lineWidth: CGFloat = 10.0,
    color: Color = .accentColor,
    cornerRadius: CGFloat = 5.0,
    opacity: Double = 1.0
  ) {
    self.__progress = progress
    self.color = color
    self.lineWidth = lineWidth
    self.opacity = opacity
    self.content = EmptyView()
    self.cornerRadius = cornerRadius
  }
}

struct CapsuleProgressBar_Previews: PreviewProvider {
    static var previews: some View {
      CapsuleProgressBar(progress: .constant(0.7)) {
        Text("Hello")
      }
      .frame(width: 50, height: 150)
    }
}
