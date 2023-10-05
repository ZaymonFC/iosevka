import Foundation

/// This is a generic ``TrieNode`` class. It stores a ``value`` and has a reference
/// to its ``parent`` and ``children``.
/// The ``parent`` property is `weak` to prevent reference cycles.
class TrieNode<T: Hashable> {
    var value: T?
    var isEndOfWord = false
    weak var parent: TrieNode?
    var children = [T: TrieNode]()

    init(value: T? = nil, parent: TrieNode? = nil) {
        self.value = value
        self.parent = parent
    }

    func add(child: T) -> Void {
        guard children[child] == nil else { return }
        children[child] = TrieNode(value: child, parent: self)
    }
}

class Trie {
    private typealias Node = TrieNode<Character>
    private let root: Node
    var size: Int

    init() {
        root = Node()
        size = 0
    }
}

extension Trie {
      func insert(word: String) -> Void {
          guard !word.isEmpty else { return }

          var currentNode = root
          for character in word.lowercased() {
              if let child = currentNode.children[character] {
                  currentNode = child
              } else {
                  currentNode.add(child: character)
                  currentNode = currentNode.children[character]!
              }
          }

          // Only update the size if the word is not already in the trie
          if !currentNode.isEndOfWord {
              currentNode.isEndOfWord = true
              size += 1
          }
      }

    func contains(word: String) -> Bool {
        guard !word.isEmpty else { return false }

        var currentNode = root
        for character in word.lowercased() {
            guard let child = currentNode.children[character] else {
                return false
            }
            currentNode = child
        }
        return currentNode.isEndOfWord
    }
}
