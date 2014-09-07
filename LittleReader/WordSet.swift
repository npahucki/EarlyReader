//
//  WordSet.swift
//  LittleReader
//
//  Created by Nathan  Pahucki on 8/21/14.
//  Copyright (c) 2014 Nathan Pahucki. All rights reserved.
//

import Foundation
import CoreData

@objc(WordSet)
class WordSet: NSManagedObject {

    @NSManaged var number: NSNumber
    @NSManaged var lastViewedOn: NSDate
    @NSManaged var words: NSMutableSet

}
