//
//  CoreDataUnitTest.swift
//  LittleReader
//
//  Created by Nathan  Pahucki on 10/31/14.
//  Copyright (c) 2014 Nathan Pahucki. All rights reserved.
//

import Foundation
import CoreData
import XCTest
import LittleReader


class CoreDataUnitTestBase : XCTestCase {

    var ctx : NSManagedObjectContext!
    var baby : Baby!

    private var _wordSetNumber = 0
    
    override func setUp() {
        super.setUp()
        NSUserDefaults.resetStandardUserDefaults()
        _wordSetNumber = 0
        let modelURL = NSBundle.mainBundle().URLForResource("LittleReader", withExtension: "momd")!
        let managedObjectModel = NSManagedObjectModel(contentsOfURL: modelURL)!
        let testManagedObjectModel = managedObjectModel.copy() as NSManagedObjectModel
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel:testManagedObjectModel)
        coordinator.addPersistentStoreWithType(NSInMemoryStoreType, configuration: nil, URL: nil, options: nil, error: nil)
        ctx = NSManagedObjectContext()
        ctx.persistentStoreCoordinator = coordinator;
        baby = createBaby()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        NSUserDefaults.resetStandardUserDefaults()
        ctx = nil
        baby = nil
    }
    
    func createBaby() -> Baby {
        let entityDescription = NSEntityDescription.entityForName("Baby", inManagedObjectContext:ctx)
        XCTAssert(entityDescription != nil,"entityDescription came back nil!")
        let baby = Baby(entity: entityDescription!, insertIntoManagedObjectContext: ctx)
        baby.name = "Test Baby"
        baby.birthDate = NSDate()
        saveContext()
        return baby
    }
    
    func createWordSet() -> WordSet {
        let entityDescription = NSEntityDescription.entityForName("WordSet", inManagedObjectContext:ctx)
        XCTAssert(entityDescription != nil,"entityDescription came back nil!")
        let ws = WordSet(entity: entityDescription!, insertIntoManagedObjectContext: ctx)
        ws.baby = baby
        ws.number = UInt16(_wordSetNumber++)
        return ws
    }
    
    func importWords(words : [String]) -> Int {
        return WordImporter(baby: baby).importWords(words).numberOfWordsAdded
    }
    
    func saveContext() {
        var error : NSError? = nil
        ctx.save(&error)
        if let e = error {
            XCTFail("Could not save context: \(error)")
        }
    }

}

