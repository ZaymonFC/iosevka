import Foundation
import SwiftUI

struct FadeIn: ViewModifier {
  @State private var opacity: Double = 0

  func body(content: Content) -> some View {
    content
      .opacity(opacity)
      .onAppear {
        withAnimation(.easeIn(duration: 0.2)) {
          opacity = 1
        }
      }
  }
}

extension View {
  func fadeIn() -> some View {
    modifier(FadeIn())
  }
}
