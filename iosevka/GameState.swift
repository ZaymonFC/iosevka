import Combine
import Foundation
import ObservableStore

// -- Domain ------------------------------------------------------------------
private let wordPoints: [Int: Int] = [
  3: 1, 4: 1, 5: 2,
  6: 3, 7: 5, 8: 8,
  9: 13, 10: 21, 11: 34,
  12: 55, 13: 89, 14: 144,
  15: 233, 16: 377, 17: 610,
  18: 987, 19: 1597, 20: 2584,
  21: 4181, 22: 6765, 23: 10946,
  24: 17711, 25: 28657, 26: 46368
]

func scoreWord(_ word: String) -> Int { wordPoints[word.count, default: 0] }

let timeLimit: Int = 6 * 30

let boardSize = 4

func calculatePossibleScore(_ words: Set<String>) -> Int {
  words.reduce(0) { acc, word in acc + scoreWord(word) }
}

enum GameAction: Equatable {
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
  var gameId: UUID?
  var gameBoard: GameBoard?
  var stateOfTheGame: StateOfTheGame = .playing
  var selectedCells: [BoardCoordinate] = []
  var selection: [Character] = []
  var foundWords: [String] = []

  var boardWords: [BoardWord] = []
  var wordLookup: Set<String> = []

  var timeRemaining: Int = timeLimit

  var possibleScore: Int = 0
  var score: Int = 0

  static func update(
    state: GameState,
    action: GameAction,
    environment: AppEnvironment
  ) -> Update<GameState> {
    print(action)

    guard state.gameBoard != nil || (state.gameBoard == nil && (action == GameAction.appear)) else {
      print("BOARD NOT INITIALISED! Can't handle \(action)")
      return Update(state: state)
    }

    switch action {
    case .appear:
      var draft = state

      draft.gameId = UUID()

      let gameBoard = GameBoard(size: boardSize)
      draft.gameBoard = gameBoard

      draft.stateOfTheGame = .playing

      draft.selectedCells = []
      draft.selection = []
      draft.foundWords = []

      let boardWords = Solver.shared.findAllWords(board: gameBoard)
      draft.boardWords = boardWords
      draft.wordLookup = Set(boardWords.map { boardWord in boardWord.word })

      draft.possibleScore = calculatePossibleScore(draft.wordLookup)
      draft.score = 0

      // Start the timer ticking
      return update(state: draft, action: .tickTimer(timeLimit), environment: environment)

    case let .selectLetter(position):
      var draft = state

      // Check that the new position is a neighbour of the last selection
      guard let lastPosition = draft.selectedCells.last else {
        draft.selectedCells.append(position)
        draft.selection.append(draft.gameBoard![position] ?? "?")
        return Update(state: draft)
      }

      let neighbours = draft.gameBoard!.neighbors(of: lastPosition)

      guard neighbours.contains(position) else { return Update(state: draft) }

      draft.selectedCells.append(position)
      draft.selection.append(draft.gameBoard![position] ?? "?")

      return Update(state: draft)

    case .submitWord:
      var draft = state

      // Convert selected cells to a word and add to submittedWords
      let word = draft.selectedCells.reduce("") { word, position in
        word + String(draft.gameBoard![position]!)
      }

      if !draft.foundWords.contains(word)
        && draft.wordLookup.contains(word)
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
        let fx: Fx<GameAction> = Future.detached {
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
