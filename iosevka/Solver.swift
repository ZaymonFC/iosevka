import Foundation

class Solver {
  let board: GameBoard
  let trie: Trie
  var validWords: Set<String> = []
    
  init(board: GameBoard, trie: Trie) {
    self.board = board
    self.trie = trie
  }
    
  func findAllWords() -> Set<String> {
    for x in 0..<board.size {
      for y in 0..<board.size {
        dfs(x: x, y: y)
      }
    }
    return validWords
  }
    
  private func dfs(x: Int, y: Int) {
    // Initialize the state variables inside the function
    var visited = Array(repeating: Array(repeating: false, count: board.size), count: board.size)
    var currentWord = ""
        
    // Internal function to handle the actual recursion
    func dfsInternal(x: Int, y: Int) {
      guard x >= 0, x < board.size, y >= 0, y < board.size else { return }
      guard !visited[x][y] else { return }
            
      if let letter = board[(x, y)] {
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
        let adjacentPositions = board.neighbors(of: (x: x, y: y))
                    
        for pos in adjacentPositions {
          dfsInternal(x: pos.x, y: pos.y)
        }
                    
        visited[x][y] = false
        currentWord = previousWord
      }
    }
        
    dfsInternal(x: x, y: y)
  }
}
