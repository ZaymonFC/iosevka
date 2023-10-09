import Combine
import Foundation
import ObservableStore
import SwiftUI

struct GameBoardView: View {
  let gameBoard: GameBoard
  let selected: [BoardCoordinate]
  let dispatch: GameDispatch

  @State var swipeState: SwipeState

  init(gameBoard: GameBoard, selected: [BoardCoordinate], dispatch: @escaping GameDispatch) {
    self.gameBoard = gameBoard
    self.selected = selected
    self.dispatch = dispatch
    self.swipeState = SwipeState(gameBoard: gameBoard, dispatch: dispatch)
  }

  var body: some View {
    GeometryReader { geometry in
      VStack(spacing: 0) {
        ForEach(gameBoard.letters.indices, id: \.self) { row in
          HStack(spacing: 0) {
            ForEach(gameBoard.letters[row].indices, id: \.self) { col in
              CellView(
                coordinate: BoardCoordinate(x: row, y: col),
                letter: gameBoard.letters[row][col],
                onAppear: { frame in
                  swipeState.send(.registerTile(
                    tile: BoardCoordinate(x: row, y: col),
                    bound: (
                      frame.origin,
                      CGPoint(x: frame.origin.x + frame.size.width, y: frame.origin.y + frame.size.height)
                    )
                  ))
                }
              ).background(selected.contains(BoardCoordinate(x: row, y: col)) ? Color.yellow : Color.white)
                .frame(width: geometry.size.width / CGFloat(gameBoard.size),
                       height: geometry.size.height / CGFloat(gameBoard.size))
            }
          }
        }
      }
      .border(Color.black, width: 0.5) // Add an external border
      .gesture(
        DragGesture()
          .onChanged { value in
            swipeState.send(.dragStart(value.startLocation))
            swipeState.send(.positionUpdated(value.location))
          }
          .onEnded { value in
            swipeState.send(.dragStop(value.location))
          }
      )
      .coordinateSpace(name: "BoardGeometry")
    }
    .aspectRatio(1, contentMode: .fit)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
}

struct CellView: View {
  let coordinate: BoardCoordinate
  let letter: Character
  var onAppear: ((CGRect) -> Void)?

  var body: some View {
    GeometryReader { geometry in
      Text(String(letter))
        .font(.title)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay(
          Rectangle()
            .stroke(Color.black, lineWidth: 0.5)
            .padding(.top, 0.5)
            .padding(.leading, 0.5)
        )
        .onAppear {
          self.onAppear?(geometry.frame(in: CoordinateSpace.named("BoardGeometry")))
        }
    }
  }
}
