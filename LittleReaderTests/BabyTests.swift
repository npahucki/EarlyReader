//
//  BabyTests.swift
//  LittleReader
//
//  Created by Nathan  Pahucki on 10/31/14.
//  Copyright (c) 2014 Nathan Pahucki. All rights reserved.
//

import CoreData
import XCTest
import EarlyReader

class BabyTests: CoreDataUnitTestBase {

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testPopulateWordSets() {
        var words = [String]()
        for(var i : Int = 0; i < 30; i++) {
            let word = String(i)
            words.append(word)
        }
        importWords(words)
        
        let baby = self.baby!
        
        XCTAssertEqual(baby.populateWordSets(1, numberOfWordsPerSet: 5).numberOfWordSetsCreated, 1)
        XCTAssertEqual(baby.wordSets.count, 1)
        let ws = baby.wordSets.allObjects.first as WordSet
        XCTAssertEqual(ws.words.count, 5)
        XCTAssert(ws.number == 0, "Expected only word set zero to exist")
        
        XCTAssertEqual(baby.populateWordSets(5, numberOfWordsPerSet: 5).numberOfWordSetsCreated, 4)
        // Ensure each set is populated 
        for ws in (baby.wordSets.allObjects as [WordSet]) {
            XCTAssertEqual(ws.words.count, 5, "Expected each wordset to have 5 words each")
            XCTAssert(ws.number < 5, "Expected only word set 0-4 to exist now")
        }

        // Now, let's remove some wordsets
        XCTAssertEqual(baby.populateWordSets(3, numberOfWordsPerSet: 5).numberOfWordSetsCreated, -2)
        XCTAssertEqual(baby.wordSets.count, 3)
        // The larger word set numbers should have been deleted
        for ws in (baby.wordSets.allObjects as [WordSet]) {
            XCTAssert(ws.number < 3, "Expected only word set 0-2 to exist now")
        }
    }
    

}
