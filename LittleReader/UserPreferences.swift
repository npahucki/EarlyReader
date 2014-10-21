//
//  UserPreferences.swift
//  LittleReader
//
//  Created by Nathan  Pahucki on 10/21/14.
//  Copyright (c) 2014 Nathan Pahucki. All rights reserved.
//

import Foundation

class UserPreferences {
    class var lessonReminderInvervalMins : Int {
        set(lessonReminderInvervalMins) {
            NSUserDefaults.standardUserDefaults().setInteger(lessonReminderInvervalMins, forKey:"lessonRemindersEnabled");
        }
        get {
            let interval = NSUserDefaults.standardUserDefaults().integerForKey("lessonRemindersEnabled");
            return interval > 0 ? interval : 15
        }
    }
}

