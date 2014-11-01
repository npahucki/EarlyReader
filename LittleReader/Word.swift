//
//  Word.swift
//  LittleReader
//
//  Created by Nathan  Pahucki on 8/21/14.
//  Copyright (c) 2014 Nathan Pahucki. All rights reserved.
//

import Foundation
import CoreData

public class Word: NSManagedObject {

    @NSManaged public var lastViewedOn: NSDate?
    @NSManaged public var activatedOn: NSDate?
    @NSManaged public var retiredOn: NSDate?
    @NSManaged public var text: String
    @NSManaged public var timesViewed: UInt16
    @NSManaged public var wordSet: WordSet?
    
    func wordSetNumber() -> Int {
        if let set = self.wordSet {
            return Int(set.number)
        } else {
            return -1
        }
    }
    
}
