//
//  UserPreferences.swift
//  LittleReader
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
            return interval > 0 ? interval : 15.0
        }
    }
    
    class var slideDisplayInverval : NSTimeInterval {
        set(slideDisplayInverval) {
            NSUserDefaults.standardUserDefaults().setDouble(slideDisplayInverval, forKey:"slideDisplayInverval");
        }
        get {
            let interval = NSUserDefaults.standardUserDefaults().doubleForKey("slideDisplayInverval");
            return interval > 0 ? interval : 1.5
        }
    }

    
    
}

