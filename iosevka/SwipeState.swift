import Combine
import ObservableStore
import SwiftUI

typealias Bounds = (topLeft: CGPoint, bottomRight: CGPoint)
typealias GameDispatch = (GameAction) -> Void

func pointInBounds(_ point: CGPoint, _ bounds: Bounds) -> Bool {
  point.x >= bounds.topLeft.x
    && point.x <= bounds.bottomRight.x
    && point.y >= bounds.topLeft.y
    && point.y <= bounds.bottomRight.y
}

func angleBetweenPoints(_ point1: CGPoint, _ point2: CGPoint) -> Double {
  let deltaX = point2.x - point1.x
  let deltaY = point2.y - point1.y

  return atan2(deltaY, deltaX)
}

func suffix<T>(_ array: [T], _ n: Int) -> [T] {
  guard n > 0 else { return [] }

  guard n < array.count else { return array }
  return array.suffix(n)
}

func angleDifference(_ angle1: Double, _ angle2: Double) -> Double {
  let diff = angle1 - angle2
  let normalizedDiff = atan2(sin(diff), cos(diff))
  let absoluteDiff = fabs(normalizedDiff)
  return absoluteDiff
}

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
  var visited: [BoardCoordinate] = []

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

  func findTileByPosition(_ position: CGPoint) -> (BoardCoordinate, Bounds)? {
    tileRegistry.first { _, bounds in pointInBounds(position, bounds) }
  }

  func handleAction(_ action: SwipeAction) {
    switch action {
    case .registerTile(let coordinate, let bounds):
      print("Registering tile: \(coordinate) \(bounds)")
      tileRegistry.append((coordinate, bounds))

    case .dragStart(let position):
      guard let (tileCoordinate, _) = findTileByPosition(position) else {
        print("No tile found at position \(position)")
        return
      }

      swipe = [position]
      visited = [tileCoordinate]
      dispatch(.selectLetter(position: tileCoordinate))

    case .positionUpdated(let position):
      swipe.append(position)
      guard let (tileCoordinate, _) = findTileByPosition(position) else { return }

      guard let previous = visited.last else {
        visited.append(tileCoordinate)
        dispatch(.selectLetter(position: tileCoordinate))
        return
      }

      guard !visited.contains(tileCoordinate) else { return }
      guard gameBoard.neighbors(of: previous).contains(tileCoordinate) else { return }

      let angle = cardinalAngle(previous, tileCoordinate) + 3.14 // Comparisons are off by PI radians ¯\_(ツ)_/¯

      guard let (_, previousTileBounds) = tileRegistry.first(where: { $0.0 == previous })
      else { print("No previous tile found"); return }

      guard let lastPointInPreviousTile = swipe.last(where: { pointInBounds($0, previousTileBounds) })
      else { print("No last point in previous tile"); return }

      let swipeAngle = angleBetweenPoints(lastPointInPreviousTile, position)
      let difference = angleDifference(angle, swipeAngle)

      guard difference < 0.4 else {
        print("Skipping tile")
        return
      }

      visited.append(tileCoordinate)
      dispatch(.selectLetter(position: tileCoordinate))

    case .dragStop:
      dispatch(.submitWord)
      swipe = []
    }
  }
}
