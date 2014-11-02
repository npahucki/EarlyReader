//
//  LessonLog.swift
//  LittleReader
//
//  Created by Nathan  Pahucki on 10/29/14.
//  Copyright (c) 2014 Nathan Pahucki. All rights reserved.
//

import Foundation
import CoreData

public class LessonLog: NSManagedObject {

    @NSManaged public var numberOfWordsViewed: UInt16
    @NSManaged public var lessonDate: NSDate
    @NSManaged public var durationSeconds: NSTimeInterval
    @NSManaged public var words: String
    @NSManaged public var wordSetNumber: UInt16
    @NSManaged public var useDay : UInt16
    @NSManaged public var totalNumberOfWordSets : UInt16
    @NSManaged public var baby : Baby
    

}
