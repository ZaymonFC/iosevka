import Foundation
import SwiftUI

struct MenuView: View {
  var dispatch: (AppAction) -> Void

  var body: some View {
    VStack(spacing: 44) {
      Text("Iosevka").font(.largeTitle)
      VStack(spacing: 22) {
        Button("New Game") { dispatch(.newGame) }.buttonStyle(.borderedProminent)
      }
    }.padding(24)
  }
}

struct MenuView_Previews: PreviewProvider {
  static var previews: some View {
    MenuView(dispatch: { action in print("Dispatching \(action)") })
  }
}
