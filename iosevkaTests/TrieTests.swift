import XCTest
@testable import iosevka

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
        XCTAssertEqual(trie.size, 2)  // Size should not increase if the word is already in the trie
        
        trie.insert(word: "orange")
        XCTAssertEqual(trie.size, 3)
    }
}
