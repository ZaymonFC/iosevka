import Foundation

let minimumWordLength = 3

class Solver {
  let trie: Trie
  var validWords: Set<String> = []
    
  init() {
    let dictionaryURL = Bundle.main.url(forResource: "dictionary", withExtension: "txt")!
    let dictionary = try! String(contentsOf: dictionaryURL)
    trie = Trie()
    
    let words = dictionary
      .split(separator: "\n")
      .filter { word in word.count >= minimumWordLength }
    
    for word in words { trie.insert(word: String(word)) }
  }
    
  func findAllWords(board: GameBoard) -> Set<String> {
    for x in 0..<board.size {
      for y in 0..<board.size {
        search(board: board, x: x, y: y)
      }
    }
    return validWords
  }
    
  private func search(board: GameBoard, x: Int, y: Int) {
    var visited = Array(repeating: Array(repeating: false, count: board.size), count: board.size)
    var currentWord = ""
        
    func dfs(x: Int, y: Int) {
      guard x >= 0, x < board.size, y >= 0, y < board.size else { return }
      guard !visited[x][y] else { return }
            
      if let letter = board[Position(x: x, y: y)] {
        let newWord = currentWord + String(letter)
                
        if trie.contains(word: newWord) {
          validWords.insert(newWord)
        }
                
        if !trie.isPrefix(word: newWord) {
          return
        }
                
        visited[x][y] = true
        let previousWord = currentWord
        currentWord = newWord
                
        // Use the neighbours function to get adjacent positions
        let adjacentPositions = board.neighbors(of: Position(x: x, y: y))
                    
        for pos in adjacentPositions {
          dfs(x: pos.x, y: pos.y)
        }
                    
        visited[x][y] = false
        currentWord = previousWord
      }
    }
        
    dfs(x: x, y: y)
  }
}

extension Solver: Equatable {
  static func == (lhs: Solver, rhs: Solver) -> Bool {
    return lhs.trie.size == rhs.trie.size
  }
}
