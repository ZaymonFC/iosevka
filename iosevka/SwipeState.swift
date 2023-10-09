import ObservableStore
import SwiftUI

typealias Bounds = (topLeft: CGPoint, bottomRight: CGPoint)
typealias GameDispatch = (GameAction) -> Void

enum SwipeAction {
  case dragStart(CGPoint)
  case positionUpdated(CGPoint)
  case tileHovered(tile: BoardCoordinate, bound: Bounds)
  case dragStop(CGPoint)
}

struct SwipeState: ModelProtocol {
  var swipe: [CGPoint]
  var previousTile: (tile: BoardCoordinate, bounds: Bounds)?
  var gameBoard: GameBoard
  var dispatch: GameDispatch

  init(dispatch: @escaping GameDispatch, gameBoard: GameBoard) {
    swipe = []
    previousTile = nil
    self.dispatch = dispatch
    self.gameBoard = gameBoard
  }

  static func update(
    state: SwipeState,
    action: SwipeAction,
    environment: Void
  ) -> Update<SwipeState> {
    var draft = state

    switch action {
    case .dragStart(let position):
      draft.swipe = [position]

    case .positionUpdated(let position):
      draft.swipe.append(position)

    case .tileHovered(let tile, let bounds):

      // First tile
      guard let (previousTile, previousBounds) = draft.previousTile else {
        draft.previousTile = (tile, bounds)

        return Update(state: draft)
      }

      // If the next tile is not a neighbour of the last tile, then return
      let neighbours = draft.gameBoard.neighbors(of: previousTile)
      guard neighbours.contains(tile) else { return Update(state: draft) }

      // Find the latest point in the swipe path inside the bounds
      let latestPoint = draft.swipe.last!

      // Search for the last point in the previous bounds
      let lastPointInPreviousTile = draft.swipe.reversed().first { point in
        point.x < previousBounds.topLeft.x
          || point.x > previousBounds.bottomRight.x
          || point.y < previousBounds.topLeft.y
          || point.y > previousBounds.bottomRight.y
      }

      // Calculate the (ideal) straight line angle between previous tile and new tile
      let tileAngle = atan2(
        Double(tile.y - previousTile.y),
        Double(tile.x - previousTile.x)
      )

      let swipeAngle = atan2(
        Double(latestPoint.y - lastPointInPreviousTile!.y),
        Double(latestPoint.x - lastPointInPreviousTile!.x)
      )

      let threshold = 10.0

      if abs(swipeAngle - tileAngle) < threshold {
        draft.previousTile = (tile, bounds)
        state.dispatch(GameAction.selectLetter(position: tile))
      }

      return Update(state: draft)

    case .dragStop:
      state.dispatch(GameAction.submitWord)

      draft.swipe = []
    }

    return Update(state: draft)
  }
}

extension SwipeState: Equatable {
  static func == (lhs: SwipeState, rhs: SwipeState) -> Bool {
    return lhs.swipe == rhs.swipe
      && lhs.previousTile?.tile == rhs.previousTile?.tile
  }
}
