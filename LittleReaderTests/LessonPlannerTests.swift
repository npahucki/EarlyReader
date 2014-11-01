//
//  LessonPlannerTests.swift
//  LittleReader
//
//  Created by Nathan  Pahucki on 10/31/14.
//  Copyright (c) 2014 Nathan Pahucki. All rights reserved.
//

import CoreData
import XCTest
import LittleReader

class LessonPlannerTests: CoreDataUnitTestBase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    private func createBaby() -> Baby {
        let entityDescription = NSEntityDescription.entityForName("Baby", inManagedObjectContext:ctx)
        XCTAssert(entityDescription != nil,"entityDescription came back nil!")
        let baby = Baby(entity: entityDescription!, insertIntoManagedObjectContext: ctx)
        baby.name = "Test Baby"
        baby.birthDate = NSDate()
        ctx.save(nil)
        return baby
    }


}
