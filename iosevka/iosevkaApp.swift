import ObservableStore
import SwiftUI

enum AppAction {
  case newGame
  case mainMenu
}

enum AppState {
  case mainMenu
  case game
}

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
  @State var appState = AppState.mainMenu

  func dispatch(_ action: AppAction) {
    switch action {
    case .newGame: appState = AppState.game
    case .mainMenu: appState = AppState.mainMenu
    }
  }

  var body: some View {
    switch appState {
    case .mainMenu: MenuView(dispatch: dispatch)
    case .game:
      VStack {
        GameView()
        Button("Main Menu") { dispatch(.mainMenu) }
      }.fadeIn()
    }
  }
}

struct AppView_Previews: PreviewProvider {
  static var previews: some View {
    AppView().fadeIn()
  }
}
