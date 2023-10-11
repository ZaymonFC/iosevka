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

struct ScoreView: View {
  var gameState: GameState

  var body: some View {
    VStack {
      HStack {
        Text("Found words \(gameState.foundWords.count) / \(gameState.possibleWords.count)")
        Spacer()
        Text("Score \(gameState.score) / \(gameState.possibleScore)")
      }
      Spacer()
      Text(gameState.foundWords.joined(separator: " "))
    }
    .padding(8)
  }
}

struct GameView: View {
  @StateObject var store = Store(
    state: GameState(),
    environment: AppEnvironment()
  )

  var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

  var body: some View {
    VStack {
      ScoreView(gameState: store.state)
      GameBoardView(
        gameBoard: store.state.gameBoard,
        selected: store.state.selectedCells,
        dispatch: store.send
      )
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
    case .mainMenu: MenuView(dispatch: dispatch).fadeIn()
    case .game:
      VStack {
        GameView()
        Button("Main Menu") {
          dispatch(.mainMenu)
        }
      }.fadeIn()
    }
  }
}

struct AppView_Previews: PreviewProvider {
  static var previews: some View {
    AppView().fadeIn()
  }
}
