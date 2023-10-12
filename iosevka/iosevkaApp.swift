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
        Text("Time: \(gameState.timeRemaining)s")
        Text("Score \(gameState.score) / \(gameState.possibleScore)")
      }
      Text(gameState.foundWords.joined(separator: " "))
    }
    .padding(8)
  }
}

struct SelectionView: View {
  var selection: [Character]

  var body: some View {
    if selection.isEmpty {
      return AnyView(HStack {})
    } else {
      return AnyView(
        HStack(spacing: -1) {
          ForEach(selection, id: \.self) { letter in
            Text(String(letter))
              .frame(width: 30, height: 30)
              .border(Color.black, width: 1)
          }
        }
      )
    }
  }
}

struct GameView: View {
  @StateObject var store = Store(
    state: GameState(),
    environment: AppEnvironment()
  )

  var body: some View {
    VStack {
      ScoreView(gameState: store.state)
//      SelectionView(selection: store.state.selection)
      GameBoardView(
        gameBoard: store.state.gameBoard,
        selected: store.state.selectedCells,
        dispatch: store.send
      )

    }.onAppear { store.send(GameAction.appear) }
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
