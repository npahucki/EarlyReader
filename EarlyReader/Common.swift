//
//  Common.swift
//  EarlyReader
//
//  Created by Nathan  Pahucki on 10/24/14.
//  Copyright (c) 2014 Nathan Pahucki. All rights reserved.
//

import Foundation
import CoreData


let SLIDE_DURATION_MIN = 0.5
let SLIDE_DURATION_MAX = 5.0


let WORDS_PER_WORDSET = 5
let WORD_VIEWS_BEFORE_RETIREMENT : UInt16 = 15
let TIME_INTERVAL_24_HOURS = NSTimeInterval(60 * 60 * 24)


let NS_NOTIFICATION_NUMBER_OF_WORD_SETS_CHANGED = "numberOfWordSetsChanged"
let NS_NOTIFICATION_CURRENT_BABY_CHANGED = "currentBabyChanged"

// Icky Global, but no other good way to get the context to Baby class.
var _mainManagedObjectContext : NSManagedObjectContext? = nil

