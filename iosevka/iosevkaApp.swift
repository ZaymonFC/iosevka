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

struct ScoreView: View {
  var gameState: GameState

  var body: some View {
    HStack {
      Text("Found words \(gameState.foundWords.count) / \(gameState.possibleWords.count)")
      Spacer()
      Text("Score \(gameState.score)")
    }.padding(8)
  }
}

struct AppView: View {
  @StateObject var store = Store(
    state: GameState(),
    environment: AppEnvironment()
  )

  var body: some View {
    VStack {
      ScoreView(gameState: store.state)
      GameBoardView(
        gameBoard: store.state.gameBoard,
        selected: store.state.selectedCells,
        dispatch: store.send
      )

      Button("New Game") { store.send(.newGame) }
    }
  }
}

struct AppView_Previews: PreviewProvider {
  static var previews: some View {
    AppView().fadeIn()
  }
}

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
