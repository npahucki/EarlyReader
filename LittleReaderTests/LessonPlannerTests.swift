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

    var _planner : LessonPlanner? = nil
    var _baby : Baby? = nil
    
    override func setUp() {
        super.setUp()
        _baby = createBaby()
        _planner = LessonPlanner(baby: _baby!)
    }
    
    override func tearDown() {
        super.tearDown()
        _planner = nil
        _baby = nil
    }
    
    
    

    


}
