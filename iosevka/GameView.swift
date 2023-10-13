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
      Text(word.uppercased())
      Spacer()
      Text("+\(scoreWord(word))")
    }.padding(.horizontal, 12)
      .padding(.vertical, 4)
      .background(Color.accentColor)
      .foregroundColor(.white)
      .fontWeight(.semibold)
      .onTapGesture {
        onTapped(word)
      }
  }
}

struct WordList: View {
  var words: [String]
  var selectWord: (String) -> Void

  var body: some View {
    VStack(spacing: 2) {
      if words.count > 0 {
        ForEach(words, id: \.self) { word in
          WordView(word: word, onTapped: { word in
            selectWord(word)
          })
        }
      }
    }.frame(maxWidth: .infinity)
  }
}

struct WordList_Previews: PreviewProvider {
  static var previews: some View {
    WordList(words: ["ABC", "DEF", "GHI", "JKL"], selectWord: { _ in })
  }
}

struct SummaryView: View {
  @ObservedObject var store: Store<GameState>
  var dispatch: (AppAction) -> Void

  let remainingWords: [String]
  @State var selected: [BoardCoordinate] = []

  init(store: Store<GameState>, dispatch: @escaping (AppAction) -> Void) {
    self.store = store
    self.dispatch = dispatch
    self.remainingWords =
      store.state.wordLookup.subtracting(store.state.foundWords)
        .sorted()
        .sorted(by: { x, y in scoreWord(x) > scoreWord(y) })
  }

  func select(word: String) {
    selected =
      store.state.boardWords
        .filter { boardWord in word == boardWord.word }
        .randomElement()!
        .path
  }

  var body: some View {
    VStack {
      Text("Game Over").font(.largeTitle)

      HStack {
        Button("Main Menu") {
          dispatch(.mainMenu)
        }.buttonStyle(.borderedProminent)
        Button("New Game") {
          store.send(GameAction.appear)
        }.buttonStyle(.borderedProminent)
      }

      ReadOnlyBoardView(gameBoard: store.state.gameBoard!, selected: selected)
        .padding(12)
        .frame(width: 200, height: 200)

      VStack {
        HStack {
          Text("Words \(store.state.foundWords.count) / \(store.state.wordLookup.count)")
          Spacer()
          Text("Score \(store.state.score) / \(store.state.possibleScore)")
        }.padding(.bottom, 12)
      }.padding(12)

      TabView {
        ScrollView {
          WordList(words: store.state.foundWords, selectWord: select)
        }.tabItem {
          Image(systemName: "text.justify")
          Text("Found Words (\(store.state.foundWords.count))")
        }.tag(0)

        ScrollView {
          WordList(words: remainingWords, selectWord: select)
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
    Spacer()
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
