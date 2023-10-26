import Foundation
import ObservableStore
import SwiftUI

struct ScoreView: View {
  var gameState: GameState

  var body: some View {
    VStack(spacing: 24) {
      HStack {
        Image(systemName: "sparkle.magnifyingglass")
          .symbolEffect(.bounce, options: .speed(10), value: gameState.foundWords.count)
        Text("\(gameState.foundWords.count) / \(gameState.wordLookup.count)")

        Spacer()

        Image(systemName: "star.circle")
          .symbolEffect(.bounce, options: .speed(9), value: gameState.score)
        Text("\(gameState.score) / \(gameState.possibleScore)")

        Spacer()

        Image(systemName: "clock")
        Text("\(gameState.timeRemaining)s")
      }.padding(.bottom, 12)
      Text(gameState.foundWords.joined(separator: " "))
    }.padding(12).font(.monospacedDigit(.system(size: 18))())
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

      VStack(spacing: 0) {
        HStack {
          Text("Words \(store.state.foundWords.count) / \(store.state.wordLookup.count)")
          Spacer()
          Text("Score \(store.state.score) / \(store.state.possibleScore)")
        }
        .padding(.horizontal, 12)
        .padding(.bottom, 4)

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
}

struct PlayingView: View {
  @ObservedObject var store: Store<GameState>

  var body: some View {
    VStack {
      ScoreView(gameState: store.state)
      Spacer()
      SelectionView(selection: store.state.selection)

      if let gameBoard = store.state.gameBoard {
        VStack {
          GameBoardView(
            gameBoard: gameBoard,
            selected: store.state.selectedCells,
            flashingLetters: store.state.flashingLetters,
            flashType: store.state.flashType,
            dispatch: store.send,
            rotation: store.state.rotation
          ).padding(4)
          HStack {
            Spacer()
            Button(action: { store.send(.rotateBoard) }) {
              Image(systemName: "rotate.right.fill")
                .aspectRatio(1, contentMode: .fill)
                .symbolEffect(.bounce.down.byLayer, options: .speed(5), value: store.state.rotation)
                .font(.largeTitle)
            }
          }.padding(.horizontal, 24).padding(.top, 8)
        }
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
