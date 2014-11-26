//
//  WordTest.swift
//  EarlyReader
//
//  Created by Nathan  Pahucki on 10/27/14.
//  Copyright (c) 2014 Nathan Pahucki. All rights reserved.
//

import XCTest
import CoreData
import EarlyReader

class WordImporterTests : CoreDataUnitTestBase {

    var importer : WordImporter! = nil
    
    override func setUp() {
        super.setUp()
        importer = WordImporter(baby : baby)
    }
    
    override func tearDown() {
        importer = nil
        super.tearDown()
    }
    
    
    func testWordsCanBeImported() {
        let wordList1 = ["one", "two", "three"]
        let result = importer.importWords(wordList1)
        XCTAssertNil(result.error, "Unexpected error during import: \(result.error)")
        XCTAssert(result.numberOfWordsAdded == wordList1.count, "Not all words from list were imported")
        
        // Verify a count of items.
        let fetchRequest = NSFetchRequest(entityName: "Word")
        let actuallyInserted = ctx.countForFetchRequest(fetchRequest, error: nil)
        XCTAssert(actuallyInserted == wordList1.count, "Not all words from list were inserted into DB!")
    }

    func testDuplicateWordsRejected() {
        let wordList1 = ["one", "two", "three"]
        let wordList2 = ["one", "two", "three", "four"]
        let result1 = importer.importWords(wordList1)
        XCTAssertNil(result1.error, "Unexpected error during import: \(result1.error)")
        XCTAssert(result1.numberOfWordsAdded == wordList1.count , "Expected \(wordList1.count) words to be initially imported but \(result1.numberOfWordsAdded) were.")

        let result2 = importer.importWords(wordList2)
        XCTAssertNil(result2.error, "Unexpected error during import: \(result2.error)")
        XCTAssert(result2.numberOfWordsAdded == wordList2.count - wordList1.count , "Only expected \(wordList2.count - wordList1.count) non duplicates to be imported, but \(result2.numberOfWordsAdded) were.")
        
        // Verify a count of items.
        let actualCount = ctx.countForFetchRequest(NSFetchRequest(entityName: "Word"), error: nil)
        
        XCTAssert(actualCount == wordList2.count, "Expect \(wordList2.count) words to be present in DB but \(actualCount) were!")
    }

}
