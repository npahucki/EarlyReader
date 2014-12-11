//
//  UserPreferences.swift
//  EarlyReader
//
//  Created by Nathan  Pahucki on 10/21/14.
//  Copyright (c) 2014 Nathan Pahucki. All rights reserved.
//

import Foundation

class UserPreferences {
    class var lessonReminderInverval : NSTimeInterval {
        set(lessonReminderInverval) {
            NSUserDefaults.standardUserDefaults().setDouble(lessonReminderInverval, forKey:"lessonReminderInverval");
        }
        get {
            let interval = NSUserDefaults.standardUserDefaults().doubleForKey("lessonReminderInverval");
            return interval > 0 ? interval : 15.0 * 60.0
        }
    }

    class var numberOfTimesToRepeatEachWordSet : Int {
        set(numberOfTimesToRepeatEachWordSet) {
        NSUserDefaults.standardUserDefaults().setInteger(numberOfTimesToRepeatEachWordSet, forKey:"numberOfTimesToRepeatEachWordSet");
        }
        get {
            let times = NSUserDefaults.standardUserDefaults().integerForKey("numberOfTimesToRepeatEachWordSet");
            return times > 0 ? times : 3
        }
    }
    
    class var slideDisplayInverval : NSTimeInterval {
        set(slideDisplayInverval) {
             NSUserDefaults.standardUserDefaults().setDouble(slideDisplayInverval, forKey:"slideDisplayInverval");
        }
        get {
            let defs = NSUserDefaults.standardUserDefaults()
            return defs.objectForKey("slideDisplayInverval") == nil ? 3.0 : defs.doubleForKey("slideDisplayInverval");
        }
    }

    class var alwaysUseManualMode : Bool {
        get {
            return UserPreferences.slideDisplayInverval == 0.0
        }
    }
    
    
}

