@testable import iosevka
import XCTest

class TrieTests: XCTestCase {
  var trie: Trie!
    
  override func setUp() {
    super.setUp()
    trie = Trie()
  }

  override func tearDown() {
    trie = nil
    super.tearDown()
  }

  func testInsertAndContains() {
    trie.insert(word: "apple")
    XCTAssertTrue(trie.contains(word: "apple"))
    XCTAssertFalse(trie.contains(word: "app"))
        
    trie.insert(word: "app")
    XCTAssertTrue(trie.contains(word: "app"))
  }
  
  func testIsPrefix() {
    // Insert some words into the Trie
    trie.insert(word: "apple")
    trie.insert(word: "appetizer")
    trie.insert(word: "banana")
    trie.insert(word: "bat")

    // Test prefixes
    XCTAssertTrue(trie.isPrefix(word: "app"), "App should be a prefix.")
    XCTAssertTrue(trie.isPrefix(word: "appl"), "Appl should be a prefix.")
    XCTAssertTrue(trie.isPrefix(word: "bat"), "Bat should be a prefix.")
    XCTAssertTrue(trie.isPrefix(word: "ban"), "Ban should be a prefix.")
    XCTAssertFalse(trie.isPrefix(word: "batman"), "Batman should not be a prefix.")
    XCTAssertFalse(trie.isPrefix(word: "applepie"), "Applepie should not be a prefix.")
    XCTAssertFalse(trie.isPrefix(word: "xyz"), "XYZ should not be a prefix.")

    // Edge case: An empty string should not be a prefix.
    XCTAssertFalse(trie.isPrefix(word: ""), "Empty string should not be a prefix.")
  }

  func testEmptyString() {
    trie.insert(word: "")
    XCTAssertFalse(trie.contains(word: ""))
    trie.insert(word: "a")
    XCTAssertFalse(trie.contains(word: ""))
  }
    
  func testCaseInsensitive() {
    trie.insert(word: "Apple")
    XCTAssertTrue(trie.contains(word: "apple"))
    XCTAssertTrue(trie.contains(word: "Apple"))
  }
    
  func testSize() {
    trie.insert(word: "apple")
    trie.insert(word: "app")
    XCTAssertEqual(trie.size, 2)
        
    trie.insert(word: "apple")
    XCTAssertEqual(trie.size, 2) // Size should not increase if the word is already in the trie
        
    trie.insert(word: "orange")
    XCTAssertEqual(trie.size, 3)
  }
}
