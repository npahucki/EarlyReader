//
//  WordTest.swift
//  LittleReader
//
//  Created by Nathan  Pahucki on 10/27/14.
//  Copyright (c) 2014 Nathan Pahucki. All rights reserved.
//

import XCTest
import CoreData

class WordImporterTests : XCTestCase {
    
    var importer : WordImporter!
    var ctx : NSManagedObjectContext!
    
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.dataparenting.LittleReader" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] as NSURL
        }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("LittleReader", withExtension: "momd")
        return NSManagedObjectModel(contentsOfURL: modelURL!)!
        }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("LittleReader.sqlite")
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        if coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil, error: &error) == nil {
            coordinator = nil
            // Report any error we got.
            let dict = NSMutableDictionary()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "LittleReader", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            UsageAnalytics.trackError("Failed to create the persistentStoreCoordinator", error: error!)
            #if DEBUG
                abort()
            #endif
        }
        
        return coordinator
        }()
    
    lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
        }()

    
    
    
    override func setUp() {
        super.setUp()
        let modelURL = NSBundle.mainBundle().URLForResource("LittleReader", withExtension: "momd")!
        let managedObjectModel = NSManagedObjectModel(contentsOfURL: modelURL)!
        let testManagedObjectModel = managedObjectModel.copy() as NSManagedObjectModel
//        for entity in testManagedObjectModel.entities as [NSEntityDescription] {
//                entity.managedObjectClassName = entity.managedObjectClassName.stringByReplacingOccurrencesOfString("LittleReader", withString: "LittleReaderTests")
//        }
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel:testManagedObjectModel)
        coordinator.addPersistentStoreWithType(NSInMemoryStoreType, configuration: nil, URL: nil, options: nil, error: nil)
        //ctx = NSManagedObjectContext()
        //ctx.persistentStoreCoordinator = coordinator;
        
        ctx = self.managedObjectContext
        
        importer = WordImporter(managedContext:  ctx)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        importer = nil
        ctx = nil
    }

//    func testWordsCanBeImported() {
//        let wordList1 = ["one", "two", "three"]
//        let result = importer.importWords(wordList1)
//        XCTAssertNil(result.error, "Unexpected error during import: \(result.error)")
//        XCTAssert(result.numberOfWordsAdded == wordList1.count, "Not all words from list were imported")
//        
//        // Verify a count of items.
//        let fetchRequest = NSFetchRequest(entityName: "Word")
//        let actuallyInserted = ctx.countForFetchRequest(fetchRequest, error: nil)
//        XCTAssert(actuallyInserted == wordList1.count, "Not all words from list were inserted into DB!")
//    }

//    func testDuplicateWordsRejected() {
//        let wordList1 = ["one", "two", "three"]
//        let wordList2 = ["one", "two", "three", "four"]
//        let result1 = importer.importWords(wordList1)
//        XCTAssertNil(result1.error, "Unexpected error during import: \(result1.error)")
//        XCTAssert(result1.numberOfWordsAdded == wordList1.count , "Expected \(wordList1.count) words to be initially imported but \(result1.numberOfWordsAdded) were.")
//
//        let result2 = importer.importWords(wordList2)
//        XCTAssertNil(result2.error, "Unexpected error during import: \(result2.error)")
//        XCTAssert(result2.numberOfWordsAdded == wordList2.count - wordList1.count , "Only expected \(wordList2.count - wordList1.count) non duplicates to be imported, but \(result2.numberOfWordsAdded) were.")
//        
//        // Verify a count of items.
//        let actualCount = ctx.countForFetchRequest(NSFetchRequest(entityName: "Word"), error: nil)
//        
//        XCTAssert(actualCount == wordList2.count, "Expect \(wordList2.count) words to be present in DB but \(actualCount) were!")
//    }

}
