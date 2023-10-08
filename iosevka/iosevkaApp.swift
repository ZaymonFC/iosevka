import ObservableStore
import SwiftUI

struct AppEnvironment {}

@main
struct iosevkaApp: App {
  var body: some Scene {
    WindowGroup {
      AppView()
    }
  }
}

struct AppView: View {
  @StateObject var store = Store(
    state: GameState(),
    environment: AppEnvironment()
  )

  var body: some View {
    VStack {
      GameBoardView(gameBoard: store.state.gameBoard)
      Button("New Game") { store.send(.newGame) }
    }
  }
}

struct AppView_Previews: PreviewProvider {
  static var previews: some View {
    AppView()
  }
}
