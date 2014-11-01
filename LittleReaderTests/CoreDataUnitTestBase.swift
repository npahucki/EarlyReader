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
    
    override func setUp() {
        super.setUp()
        let modelURL = NSBundle.mainBundle().URLForResource("LittleReader", withExtension: "momd")!
        let managedObjectModel = NSManagedObjectModel(contentsOfURL: modelURL)!
        let testManagedObjectModel = managedObjectModel.copy() as NSManagedObjectModel
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel:testManagedObjectModel)
        coordinator.addPersistentStoreWithType(NSInMemoryStoreType, configuration: nil, URL: nil, options: nil, error: nil)
        ctx = NSManagedObjectContext()
        ctx.persistentStoreCoordinator = coordinator;
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        ctx = nil
    }
    
    func createBaby() -> Baby {
        let entityDescription = NSEntityDescription.entityForName("Baby", inManagedObjectContext:ctx)
        XCTAssert(entityDescription != nil,"entityDescription came back nil!")
        let baby = Baby(entity: entityDescription!, insertIntoManagedObjectContext: ctx)
        baby.name = "Test Baby"
        baby.birthDate = NSDate()
        ctx.save(nil)
        return baby
    }
    
    func createWordSet() -> WordSet {
        let entityDescription = NSEntityDescription.entityForName("WordSet", inManagedObjectContext:ctx)
        XCTAssert(entityDescription != nil,"entityDescription came back nil!")
        return WordSet(entity: entityDescription!, insertIntoManagedObjectContext: ctx)
    }
    
    func importWords(words : [String]) -> Int {
        return WordImporter(managedContext: ctx).importWords(words).numberOfWordsAdded
    }

}

