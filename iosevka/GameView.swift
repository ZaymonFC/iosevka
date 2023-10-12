import Foundation
import SwiftUI
import ObservableStore

struct ScoreView: View {
  var gameState: GameState

  var body: some View {
    VStack {
      HStack {
        Text("Words \(gameState.foundWords.count) / \(gameState.possibleWords.count)")
        Spacer()
        Text("Score \(gameState.score) / \(gameState.possibleScore)")
        Spacer()
        Text("Time: \(gameState.timeRemaining)s")
      }.padding(.bottom, 12)
      Text(gameState.foundWords.joined(separator: " "))
    }.padding(12)
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
              .border(Color.accentColor, width: 1)
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
      Spacer()
      SelectionView(selection: store.state.selection)
      GameBoardView(
        gameBoard: store.state.gameBoard,
        selected: store.state.selectedCells,
        dispatch: store.send
      )
    }.onAppear { store.send(GameAction.appear) }
  }
}

struct GameView_Previews: PreviewProvider {
  static var previews: some View {
    GameView()
  }
}
