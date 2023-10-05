import Foundation

typealias Position = (x: Int, y: Int)

struct GameBoard {
  let size: Int
  public private(set) var letters: [[Character]]
    
  init(size: Int) {
    self.size = size
    self.letters = (0..<size).map { _ in
      (0..<size).map { _ in
        Character(UnicodeScalar(Int.random(in: 97 ... 122))!)
      }
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
        neighbors.append((newX, newY))
      }
    }
        
    return neighbors
  }
}
