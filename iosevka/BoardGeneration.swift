//
//  BoardGeneration.swift
//  iosevka
//
//  Created by Zaymon Foulds-Cook on 19/10/2023.
//

import Foundation

func coordinateSquare(size: Int) -> Set<BoardCoordinate> {
  Set((0..<size).flatMap { x in
    (0..<size).map { y in
      BoardCoordinate(x: x, y: y)
    }
  })
}

func mkGameBoard(size: Int) -> (GameBoard, [BoardWord]) {
  let coordinates = coordinateSquare(size: size)

  var board = GameBoard(size: size)
  var boardWords = Solver.shared.findAllWords(board: board)
  var usedPositions = Set(boardWords.flatMap { x in x.path })
  var unusedPositions = coordinates.subtracting(usedPositions)

  var attempts = 0

  while unusedPositions.count != 0, attempts < 5 {
    let pos = unusedPositions.first!

    let newLetter = randomLetter()

    var letters = board.letters
    letters[pos.x][pos.y] = newLetter

    board = GameBoard(letters: letters)
    boardWords = Solver.shared.findAllWords(board: board)
    usedPositions = Set(boardWords.flatMap { x in x.path })
    unusedPositions = coordinates.subtracting(usedPositions)

    attempts += 1
  }

  return (board, boardWords)
}
