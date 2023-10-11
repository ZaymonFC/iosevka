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

func calculatePossibleScore(_ words: Set<String>) -> Int {
  words.reduce(0) { $0 + wordPoints[$1.count, default: 0] }
}

enum GameAction {
  case newGame
  case selectLetter(position: BoardCoordinate)
  case submitWord
}

struct GameState: ModelProtocol {
  var gameId: UUID
  var gameBoard: GameBoard
  var solver: Solver = .init()
  var selectedCells: [BoardCoordinate] = []
  var foundWords: [String] = []
  var possibleWords: Set<String> = []

  var possibleScore: Int
  var score: Int = 0

  init() {
    gameId = UUID()
    gameBoard = GameBoard(size: 4)
    possibleWords = solver.findAllWords(board: gameBoard)
    possibleScore = calculatePossibleScore(possibleWords)
  }

  static func update(
    state: GameState,
    action: GameAction,
    environment: AppEnvironment
  ) -> Update<GameState> {
    var draft = state

    print(action)

    switch action {
    case .newGame:
      draft.gameId = UUID()

      draft.selectedCells = []
      draft.foundWords = []

      let gameBoard = GameBoard(size: 4)
      draft.gameBoard = gameBoard

      draft.possibleWords = state.solver.findAllWords(board: gameBoard)
      draft.possibleScore = calculatePossibleScore(draft.possibleWords)
      draft.score = 0

    case .selectLetter(let position):
      // Check that the new position is a neighbour of the last selection
      guard let lastPosition = draft.selectedCells.last else {
        draft.selectedCells.append(position)
        return Update(state: draft)
      }

      let neighbours = draft.gameBoard.neighbors(of: lastPosition)

      guard neighbours.contains(position) else { return Update(state: draft) }

      draft.selectedCells.append(position)

    case .submitWord:
      // Convert selected cells to a word and add to submittedWords
      let word = draft.selectedCells.reduce("") { word, position in
        word + String(draft.gameBoard[position]!)
      }

      if !draft.foundWords.contains(word) {
        if draft.possibleWords.contains(word) {
          draft.foundWords.append(word)
          draft.score += wordPoints[word.count] ?? 0
        }
      }

      draft.selectedCells.removeAll()
    }

    return Update(state: draft)
  }
}

extension GameState: Equatable {
  static func == (lhs: GameState, rhs: GameState) -> Bool {
    return lhs.gameBoard == rhs.gameBoard
      && lhs.solver == rhs.solver
      && lhs.gameBoard == rhs.gameBoard
      && lhs.selectedCells == rhs.selectedCells
      && lhs.foundWords == rhs.foundWords
      && lhs.score == rhs.score
  }
}
