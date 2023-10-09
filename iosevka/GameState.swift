import Foundation
import ObservableStore

enum GameAction {
  case newGame
  case selectLetter(position: BoardCoordinate)
  case submitWord
}

struct GameState: ModelProtocol {
  var gameBoard: GameBoard
  var solver: Solver = .init()
  var selectedCells: [BoardCoordinate] = []
  var foundWords: [String] = []
  var possibleWords: Set<String> = []

  init() {
    gameBoard = GameBoard(size: 4)
    possibleWords = solver.findAllWords(board: gameBoard)
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
      draft.selectedCells.removeAll()
      draft.foundWords.removeAll()

      let gameBoard = GameBoard(size: 4)

      draft.gameBoard = gameBoard
      print(gameBoard)
      draft.possibleWords = state.solver.findAllWords(board: gameBoard)

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

      if draft.possibleWords.contains(word) { draft.foundWords.append(word) }

      // Indicate success

      draft.selectedCells.removeAll()

      // Indicate Failure
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
  }
}
