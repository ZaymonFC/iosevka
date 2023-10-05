import Foundation
import SwiftUI

struct GameBoardView: View {
  let gameBoard: GameBoard

  var body: some View {
    GeometryReader { geometry in
      VStack(spacing: 0) {
        ForEach(gameBoard.letters.indices, id: \.self) { row in
          HStack(spacing: 0) {
            ForEach(gameBoard.letters[row].indices, id: \.self) { col in
              CellView(letter: gameBoard.letters[row][col])
                .frame(width: geometry.size.width / CGFloat(gameBoard.size),
                       height: geometry.size.height / CGFloat(gameBoard.size))
            }
          }
        }
      }
      .border(Color.black, width: 0.5) // Add an external border
    }
    .aspectRatio(1, contentMode: .fit)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
}

struct CellView: View {
  let letter: Character

  var body: some View {
    Text(String(letter))
      .font(.title)
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .overlay(
        Rectangle()
          .stroke(Color.black, lineWidth: 0.5)
          .padding(.top, 0.5)
          .padding(.leading, 0.5)
      )
  }
}
