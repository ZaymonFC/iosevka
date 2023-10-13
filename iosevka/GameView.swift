import Foundation
import ObservableStore
import SwiftUI

struct ScoreView: View {
  var gameState: GameState

  var body: some View {
    VStack {
      HStack {
        Text("Words \(gameState.foundWords.count) / \(gameState.wordLookup.count)")
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
          ForEach(selection.indices, id: \.self) { index in
            Text(String(selection[index]))
              .frame(width: 30, height: 30)
              .border(Color.accentColor, width: 1)
          }
        }
      )
    }
  }
}

struct WordView: View {
  var word: String
  var onTapped: (String) -> Void

  var body: some View {
    HStack {
      Text(word)
      Spacer()
      Text("+\(scoreWord(word))")
    }.padding(.horizontal, 12)
      .padding(.vertical, 4)
      .background(Color.accentColor)
      .foregroundColor(.white)
      .fontWeight(.semibold)
      .textCase(.uppercase)
      .onTapGesture {
        onTapped(word)
      }
  }
}

struct WordList: View {
  var words: [String]

  var body: some View {
    VStack(spacing: 2) {
      if words.count > 0 {
        ForEach(words, id: \.self) { word in
          WordView(word: word, onTapped: { s in print("Tapped", s) })
        }
      }
    }.frame(maxWidth: .infinity)
  }
}

struct WordList_Previews: PreviewProvider {
  static var previews: some View {
    WordList(words: ["ABC", "DEF", "GHI", "JKL"])
  }
}

struct SummaryView: View {
  @ObservedObject var store: Store<GameState>
  var dispatch: (AppAction) -> Void

  let remainingWords: [String]

  init(store: Store<GameState>, dispatch: @escaping (AppAction) -> Void) {
    self.store = store
    self.dispatch = dispatch
    self.remainingWords =
      store.state.wordLookup.subtracting(store.state.foundWords)
        .sorted()
        .sorted(by: { x, y in scoreWord(x) > scoreWord(y) })
  }

  var body: some View {
    VStack {
      Text("Game Over").font(.largeTitle)

      ScoreView(gameState: store.state)

      Spacer()

      HStack {
        Button("New Game") {
          store.send(GameAction.appear)
        }.buttonStyle(.borderedProminent)
        Button("Main Menu") {
          dispatch(.mainMenu)
        }.buttonStyle(.borderedProminent)
      }
      TabView {
        ScrollView {
          WordList(words: store.state.foundWords)
        }.tabItem {
          Image(systemName: "text.justify")
          Text("Found Words (2)")
        }.tag(0)

        ScrollView {
          WordList(words: remainingWords)
        }.tabItem {
          Image(systemName: "text.badge.plus")
          Text("Remaining Words \\(\(remainingWords.count)\\)")
        }
        .tag(1)
      }
    }
  }
}

struct PlayingView: View {
  @ObservedObject var store: Store<GameState>

  var body: some View {
    VStack {
      ScoreView(gameState: store.state)
      Spacer()
      SelectionView(selection: store.state.selection)
      // Conditionally render GameBoardView if gameBoard is not nil
      if let gameBoard = store.state.gameBoard {
        GameBoardView(
          gameBoard: gameBoard,
          selected: store.state.selectedCells,
          dispatch: store.send
        )
      }
    }.onAppear { store.send(GameAction.appear) }
  }
}

struct GameView: View {
  @StateObject var store = Store(
    state: GameState(),
    environment: AppEnvironment()
  )

  var dispatch: (AppAction) -> Void

  var body: some View {
    switch store.state.stateOfTheGame {
    case .playing:
      return AnyView(PlayingView(store: store)).fadeIn()
    case .summary:
      return AnyView(SummaryView(store: store, dispatch: dispatch)).fadeIn()
    }
  }
}

struct GameView_Previews: PreviewProvider {
  static var previews: some View {
    GameView(dispatch: { action in print("Dispatching \(action)") })
  }
}
