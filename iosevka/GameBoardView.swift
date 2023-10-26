import Combine
import Foundation
import ObservableStore
import SwiftUI

func submissionResultToColor(_ result: SubmissionResult) -> Color {
  switch result {
    case .invalid: return Color.red
    case .duplicate: return Color.yellow
    case .valid: return Color.green
  }
}

struct GameBoardView: View {
  let gameBoard: GameBoard
  let selected: [BoardCoordinate]
  let flashingLetters: [BoardCoordinate]
  let flashType: SubmissionResult
  let dispatch: GameDispatch
  let rotation: RotationAngle

  @State var swipeState: SwipeState
  @State var isDragging = false

  init(gameBoard: GameBoard,
       selected: [BoardCoordinate],
       flashingLetters: [BoardCoordinate],
       flashType: SubmissionResult,
       dispatch: @escaping GameDispatch,
       rotation: RotationAngle)
  {
    self.gameBoard = gameBoard
    self.selected = selected
    self.flashingLetters = flashingLetters
    self.flashType = flashType
    self.dispatch = dispatch
    self.swipeState = SwipeState(gameBoard: gameBoard, dispatch: dispatch)
    self.rotation = rotation
  }

  var body: some View {
    GeometryReader { geometry in
      VStack(spacing: 0) {
        ForEach(gameBoard.letters.indices, id: \.self) { row in
          HStack(spacing: 0) {
            ForEach(gameBoard.letters[row].indices, id: \.self) { col in
              let coord =
                BoardCoordinate(row: row, col: col)
                  .withRotation(of: rotation, inMatrixOfSize: gameBoard.size)

              CellView(letter: gameBoard.letters[coord.row][coord.col],
                       selected: selected.contains(coord),
                       flashing: flashingLetters.contains(coord),
                       flashType: flashType)
                .frame(width: geometry.size.width / CGFloat(gameBoard.size),
                       height: geometry.size.height / CGFloat(gameBoard.size))
            }
          }
        }
      }
      .onAppear { swipeState.send(.appear(geometry.size)) }
      .border(Color.accentColor, width: 0.5) // Add an external border
      .gesture(
        DragGesture()
          .onChanged { value in
            if !isDragging {
              isDragging = true
              swipeState.send(.dragStart(value.startLocation))
            }
            swipeState.send(.positionUpdated(value.location))
          }
          .onEnded { value in
            swipeState.send(.dragStop(value.location))
            isDragging = false
          }
      )
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .aspectRatio(1, contentMode: .fit)
  }
}

struct CellView: View {
  let letter: Character
  let selected: Bool
  let flashing: Bool
  let flashType: SubmissionResult

  func backgroundColor(selected: Bool, flashing: Bool, flashType: SubmissionResult) -> Color {
    if flashing {
      return submissionResultToColor(flashType)
    } else if selected {
      return Color.accentColor.opacity(0.2)
    } else {
      return Color.white
    }
  }

  var body: some View {
    GeometryReader { _ in
      Text(String(letter))
        .font(.title)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay(
          Rectangle()
            .stroke(Color.accentColor, lineWidth: 0.5)
            .padding(.top, 0.5)
            .padding(.leading, 0.5)
        )
        .background(backgroundColor(selected: selected, flashing: flashing, flashType: flashType))
    }
  }
}
