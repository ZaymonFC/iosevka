import Combine
import Foundation
import ObservableStore
import SwiftUI

struct ReadOnlyBoardView: View {
  let gameBoard: GameBoard
  let selected: [BoardCoordinate]

  var body: some View {
    GeometryReader { geometry in
      VStack(spacing: 0) {
        ForEach(gameBoard.letters.indices, id: \.self) { row in
          HStack(spacing: 0) {
            ForEach(gameBoard.letters[row].indices, id: \.self) { col in
              let coordinate = BoardCoordinate(row: row, col: col)
              let isSelected = selected.contains(coordinate)
              let opacityValue = isSelected ? calculateOpacity(for: coordinate) : 0

              ReadOnlyCellView(letter: gameBoard.letters[row][col])
                .background(isSelected ? Color.accentColor.opacity(opacityValue) : Color.white)
                .frame(
                  width: geometry.size.width / CGFloat(gameBoard.size),
                  height: geometry.size.height / CGFloat(gameBoard.size)
                )
            }
          }
        }
      }
      .border(Color.accentColor, width: 1)
    }
    .aspectRatio(1, contentMode: .fit)
  }

  private func calculateOpacity(for coordinate: BoardCoordinate) -> Double {
    guard let index = selected.firstIndex(of: coordinate) else { return 0 }

    return 1 - interpolate(
      value: Double(index),
      from: 0...Double(selected.count - 1),
      to: 0.4...0.65
    )
  }
}

struct ReadOnlyBoard_Previews: PreviewProvider {
  static var previews: some View {
    ReadOnlyBoardView(
      gameBoard: GameBoard(size: 4),
      selected: []
    )
  }
}

struct ReadOnlyCellView: View {
  let letter: Character

  var body: some View {
    GeometryReader { _ in
      Text(String(letter))
        .font(.title2)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay(
          Rectangle()
            .stroke(Color.accentColor, lineWidth: 1)
            .padding(.top, 0.5)
            .padding(.leading, 0.5)
        )
    }
  }
}
