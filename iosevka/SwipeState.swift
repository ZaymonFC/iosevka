import Combine
import ObservableStore
import SwiftUI

typealias Bounds = (topLeft: CGPoint, bottomRight: CGPoint)
typealias GameDispatch = (GameAction) -> Void

enum SwipeAction {
  case registerTile(tile: BoardCoordinate, bound: Bounds)
  case dragStart(CGPoint)
  case positionUpdated(CGPoint)
  case dragStop(CGPoint)
}

class SwipeState: ObservableObject {
  var cancellableSet: Set<AnyCancellable> = []

  private var action$ = PassthroughSubject<SwipeAction, Never>()
  var gameBoard: GameBoard
  var dispatch: GameDispatch

  var tileRegistry: [(BoardCoordinate, Bounds)] = []

  var swipe: [CGPoint] = []
  var previousTile: BoardCoordinate?

  init(gameBoard: GameBoard, dispatch: @escaping GameDispatch) {
    self.gameBoard = gameBoard
    self.dispatch = dispatch

    initPublishers()
  }

  func send(_ action: SwipeAction) {
    action$.send(action)
  }

  func initPublishers() {
    action$
      .receive(on: DispatchQueue.main)
      .sink { [weak self] action in self?.handleAction(action) }
      .store(in: &cancellableSet)
  }

  func handleAction(_ action: SwipeAction) {
    print(action)

    switch action {
    case .registerTile(let coordinate, let bounds):
      print("Registering tile: \(coordinate) \(bounds)")
      tileRegistry.append((coordinate, bounds))

    case .dragStart:
      swipe = []
      previousTile = nil

    case .positionUpdated(let position):
      let tile = tileRegistry.first { _, bounds in
        let isInside = position.x >= bounds.topLeft.x
          && position.x <= bounds.bottomRight.x
          && position.y >= bounds.topLeft.y
          && position.y <= bounds.bottomRight.y

        return isInside
      }

      // Make sure we found a tile
      guard let (tileCoordinate, _) = tile else { return }

      print("Found Tile")

      guard let previous = previousTile else {
        print("Guard all the way down, \(String(describing: previousTile))")

        print("Setting previousTile to \(tileCoordinate)")
        previousTile = tileCoordinate
        print("previousTile is now \(String(describing: previousTile))")

        dispatch(.selectLetter(position: tileCoordinate))
        return
      }

      // Make sure the tile is not the previous tile
      guard tileCoordinate != previous else { return }

      previousTile = tileCoordinate
      dispatch(.selectLetter(position: tileCoordinate))

    case .dragStop:
      dispatch(.submitWord)
      swipe = []
    }
  }
}
