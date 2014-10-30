//
//  LittleReader.swift
//  LittleReader
//
//  Created by Nathan  Pahucki on 10/29/14.
//  Copyright (c) 2014 Nathan Pahucki. All rights reserved.
//

import Foundation
import CoreData

class LittleReader: NSManagedObject {

    @NSManaged var viewedAllWords: NSNumber
    @NSManaged var lessonDate: NSDate
    @NSManaged var durationSeconds: NSNumber
    @NSManaged var words: String
    @NSManaged var wordSetNumber: NSNumber

}
