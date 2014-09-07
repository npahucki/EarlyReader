//
//  Word.swift
//  LittleReader
//
//  Created by Nathan  Pahucki on 8/21/14.
//  Copyright (c) 2014 Nathan Pahucki. All rights reserved.
//

import Foundation
import CoreData

@objc(Word)
class Word: NSManagedObject {

    @NSManaged var lastViewedOn: NSDate
    @NSManaged var activatedOn: NSDate
    @NSManaged var retiredOn: NSDate
    @NSManaged var text: String
    @NSManaged var wordSet: WordSet

    
}
