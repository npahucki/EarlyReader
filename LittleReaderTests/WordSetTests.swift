//
//  WordSetTests.swift
//  LittleReader
//
//  Created by Nathan  Pahucki on 10/27/14.
//  Copyright (c) 2014 Nathan Pahucki. All rights reserved.
//

import XCTest
import CoreData
import LittleReader

class WordSetTests: CoreDataUnitTestBase {

    
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testFill() {
        let importer = WordImporter(managedContext: ctx)
        importer.importWords(["one","two", "three", "four", "five", "six"])
        let wordSet = createWordSet()
        
        XCTAssertEqual(wordSet.fill(3).numberOfWordsAdded, 3)
        XCTAssertEqual(wordSet.fill(5).numberOfWordsAdded, 2)
        XCTAssertEqual(wordSet.fill(7).numberOfWordsAdded, 1,"There are not enough words, so only 1 of the 2 requested should fill")

        XCTAssertEqual(wordSet.words.count, 6)
    }
    
    
    func testRetireOldWord() {
        let importer = WordImporter(managedContext: ctx)
        importer.importWords(["one","two", "three", "four", "five", "six"])
        let wordSet = createWordSet()
        XCTAssertEqual(wordSet.fill().numberOfWordsAdded, WORDS_PER_WORDSET)
        
        let words = wordSet.words.allObjects as [NSManagedObject]
        
        XCTAssertEqual(wordSet.retireOldWords(1).numberOfWordsRetired, 0,"No words have 15 views")
        words[0].setValue(Int(WORD_VIEWS_BEFORE_RETIREMENT), forKey: "timesViewed")
        words[1].setValue(Int(WORD_VIEWS_BEFORE_RETIREMENT) + 1, forKey: "timesViewed")
        words[2].setValue(Int(WORD_VIEWS_BEFORE_RETIREMENT) + 2, forKey: "timesViewed")
        words[3].setValue(Int(WORD_VIEWS_BEFORE_RETIREMENT) - 1, forKey: "timesViewed")
        
        XCTAssertEqual(wordSet.retireOldWords(2).numberOfWordsRetired, 2)
        XCTAssertEqual(wordSet.retireOldWords(1).numberOfWordsRetired, 1)
        XCTAssertEqual(wordSet.retireOldWords(1).numberOfWordsRetired, 0)
        
        XCTAssertEqual(wordSet.words.count, 2)
        
    }
    
    private func createWordSet() -> WordSet {
        let entityDescription = NSEntityDescription.entityForName("WordSet", inManagedObjectContext:ctx)
        XCTAssert(entityDescription != nil,"entityDescription came back nil!")
        return WordSet(entity: entityDescription!, insertIntoManagedObjectContext: ctx)
    }
    

}
