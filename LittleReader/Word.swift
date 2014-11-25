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

    public class func wordInSetGroupKey() -> String {
        return "word_group_in_word_set"
    }

    public class func wordRetiredGroupKey() -> String {
        return "word_group_retired"
    }
    
    public class func wordAvailableGroupKey() -> String {
        return "word_group_available"
    }
    
    
    @NSManaged public var lastViewedOn: NSDate?
    @NSManaged public var activatedOn: NSDate?
    @NSManaged public var retiredOn: NSDate?
    @NSManaged public var text: String
    @NSManaged public var timesViewed: UInt16
    @NSManaged public var wordSet: WordSet?
    @NSManaged public var baby: Baby

    
    func wordGroupingKey() -> String {
        if let set = self.wordSet {
            return Word.wordInSetGroupKey()
        } else if retiredOn != nil {
            return Word.wordRetiredGroupKey()
        } else {
            return Word.wordAvailableGroupKey()
        }
    }
}
