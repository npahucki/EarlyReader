//
//  LessonLog.swift
//  LittleReader
//
//  Created by Nathan  Pahucki on 10/29/14.
//  Copyright (c) 2014 Nathan Pahucki. All rights reserved.
//

import Foundation
import CoreData

class LessonLog: NSManagedObject {

    @NSManaged var numberOfWordsViewed: UInt16
    @NSManaged var lessonDate: NSDate
    @NSManaged var durationSeconds: NSTimeInterval
    @NSManaged var words: String
    @NSManaged var wordSetNumber: UInt16
    @NSManaged var useDay : UInt16
    @NSManaged var totalNumberOfWordSets : UInt16
    @NSManaged var baby : Baby
    

}
