import Combine
import Foundation
import ObservableStore

// -- Domain ------------------------------------------------------------------
let wordPoints: [Int: Int] = [
  3: 1, 4: 1, 5: 2,
  6: 3, 7: 5, 8: 8,
  9: 13, 10: 21, 11: 34,
  12: 55, 13: 89, 14: 144,
  15: 233, 16: 377, 17: 610,
  18: 987, 19: 1597, 20: 2584,
  21: 4181, 22: 6765, 23: 10946,
  24: 17711, 25: 28657, 26: 46368
]

// let timeLimit: Int = 60 * 3
let timeLimit: Int = 5

func calculatePossibleScore(_ words: Set<String>) -> Int {
  words.reduce(0) { $0 + wordPoints[$1.count, default: 0] }
}

enum GameAction {
  case appear
  case selectLetter(position: BoardCoordinate)
  case submitWord
  case tickTimer(_ remainingTime: Int)
  case gameOver
}

enum StateOfTheGame {
  case playing
  case summary
}

struct GameState: ModelProtocol {
  var gameId: UUID
  var stateOfTheGame: StateOfTheGame = .playing
  var gameBoard: GameBoard
  var selectedCells: [BoardCoordinate] = []
  var selection: [Character] = []
  var foundWords: [String] = []
  var possibleWords: Set<String> = []

  var timeRemaining: Int = timeLimit

  var possibleScore: Int
  var score: Int = 0

  static func update(
    state: GameState,
    action: GameAction,
    environment: AppEnvironment
  ) -> Update<GameState> {
    print(action)

    switch action {
    case .appear:
      var draft = state
      draft.gameId = UUID()
      draft.stateOfTheGame = .playing

      draft.selectedCells = []
      draft.selection = []
      draft.foundWords = []

      let gameBoard = GameBoard(size: 4)
      draft.gameBoard = gameBoard

      draft.possibleWords = Solver.shared.findAllWords(board: gameBoard)
      draft.possibleScore = calculatePossibleScore(draft.possibleWords)
      draft.score = 0

      // Start the timer ticking
      return update(state: draft, action: .tickTimer(timeLimit), environment: environment)

    case let .selectLetter(position):
      var draft = state

      // Check that the new position is a neighbour of the last selection
      guard let lastPosition = draft.selectedCells.last else {
        draft.selectedCells.append(position)
        draft.selection.append(draft.gameBoard[position] ?? "?")
        return Update(state: draft)
      }

      let neighbours = draft.gameBoard.neighbors(of: lastPosition)

      guard neighbours.contains(position) else { return Update(state: draft) }

      draft.selectedCells.append(position)
      draft.selection.append(draft.gameBoard[position] ?? "?")

      return Update(state: draft)

    case .submitWord:
      var draft = state

      // Convert selected cells to a word and add to submittedWords
      let word = draft.selectedCells.reduce("") { word, position in
        word + String(draft.gameBoard[position]!)
      }

      if !draft.foundWords.contains(word)
        && draft.possibleWords.contains(word)
      {
        draft.foundWords.append(word)
        draft.score += wordPoints[word.count] ?? 0
      }

      draft.selectedCells = []
      draft.selection = []
      return Update(state: draft)

    case let .tickTimer(timeRemaining):
      var draft = state

      draft.timeRemaining = timeRemaining

      if draft.timeRemaining == 0 {
        return update(state: draft, action: .gameOver, environment: environment)

      } else {
        let fx: Fx<GameAction> = Future {
          try await Task.sleep(nanoseconds: 1000000000)

          return .tickTimer(draft.timeRemaining - 1)
        }.catch { _ in
          Just(GameAction.appear)
        }.eraseToAnyPublisher()

        return Update(state: draft, fx: fx)
      }

    case .gameOver:
      var draft = state

      draft.stateOfTheGame = .summary

      return Update(state: draft)
    }
  }
}
