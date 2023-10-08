import Foundation

let letterFrequencies = [
  ("E", 12.70),
  ("T", 9.06),
  ("A", 8.17),
  ("O", 7.51),
  ("I", 6.97),
  ("N", 6.75),
  ("S", 6.33),
  ("H", 6.09),
  ("R", 5.99),
  ("D", 4.25),
  ("L", 4.03),
  ("C", 2.78),
  ("U", 2.76),
  ("M", 2.41),
  ("W", 2.36),
  ("F", 2.23),
  ("G", 2.02),
  ("Y", 1.97),
  ("P", 1.93),
  ("B", 1.49),
  ("V", 0.98),
  ("K", 0.77),
  ("J", 0.15),
  ("X", 0.15),
  ("Q", 0.10),
  ("Z", 0.07)
].map { ($0.0, $0.1 / 100) } // Transform percentages into proportions

var cumulativeProbability: Double = 0

let cumulativeFrequencies = letterFrequencies.map { letter, probability -> (String, Double) in
  cumulativeProbability += probability
  return (letter, cumulativeProbability)
}

func randomLetter() -> Character {
  let randomNumber = Double.random(in: 0..<1)
  for (letter, cumProb) in cumulativeFrequencies {
    if randomNumber < cumProb {
      return Character(letter)
    }
  }

  return "^" // This line should never be reached, but is included for safety
}

struct Position: Equatable { var x: Int; var y: Int }

struct GameBoard {
  let size: Int
  public private(set) var letters: [[Character]]

  init(size: Int) {
    self.size = size
    self.letters = (0..<size).map { _ in
      (0..<size).map { _ in randomLetter() }
    }
  }

  subscript(position: Position) -> Character? {
    guard position.x >= 0, position.x < size else { return nil }
    guard position.y >= 0, position.y < size else { return nil }

    return letters[position.x][position.y]
  }
}

extension GameBoard {
  func neighbors(of position: Position) -> [Position] {
    let dx = [-1, -1, -1, 0, 1, 1, 1, 0]
    let dy = [-1, 0, 1, 1, 1, 0, -1, -1]

    var neighbors: [Position] = []

    for i in 0..<dx.count {
      let newX = position.x + dx[i]
      let newY = position.y + dy[i]

      if newX >= 0, newX < size, newY >= 0, newY < size {
        neighbors.append(Position(x: newX, y: newY))
      }
    }

    return neighbors
  }
}

extension GameBoard: Equatable {
  static func == (lhs: GameBoard, rhs: GameBoard) -> Bool {
    return lhs.letters == rhs.letters
  }
}
