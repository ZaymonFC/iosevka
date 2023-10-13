import Foundation
import ObservableStore
import SwiftUI

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

struct BadgeView: View {
  var value: Int

  var body: some View {
    ZStack {
      Circle()
        .foregroundColor(.red)
        .frame(width: 20, height: 20)
      Text("\(value)")
        .foregroundColor(.white)
        .font(Font.system(size: 12))
    }
  }
}

struct SummaryView: View {
  @ObservedObject var store: Store<GameState>
  var dispatch: (AppAction) -> Void

  let remainingWords: [String]

  init(store: Store<GameState>, dispatch: @escaping (AppAction) -> Void) {
    self.store = store
    self.dispatch = dispatch
    self.remainingWords = store.state.possibleWords.subtracting(store.state.foundWords).sorted()
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
          VStack {
            if store.state.foundWords.count > 0 {
              ForEach(store.state.foundWords, id: \.self) { word in
                Text(word)
              }
            } else {
              Text("No words found")
            }
          }.frame(maxWidth: .infinity)
        }.tabItem {
          Image(systemName: "text.justify")
          Text("Found Words (2)")
        }
        .tag(0)

        ScrollView {
          VStack {
            ForEach(remainingWords, id: \.self) { word in
              Text(word)
            }
          }.frame(maxWidth: .infinity)
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
      GameBoardView(
        gameBoard: store.state.gameBoard,
        selected: store.state.selectedCells,
        dispatch: store.send
      )
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
