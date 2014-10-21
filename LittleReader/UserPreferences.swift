//
//  UserPreferences.swift
//  LittleReader
//
//  Created by Nathan  Pahucki on 10/21/14.
//  Copyright (c) 2014 Nathan Pahucki. All rights reserved.
//

import Foundation

class UserPreferences {
    class var lessonRemindersEnabled: Bool {
        set(lessonRemindersEnabled) {
            NSUserDefaults.standardUserDefaults().setBool(lessonRemindersEnabled, forKey:"lessonRemindersEnabled");
        }
        get {
            return NSUserDefaults.standardUserDefaults().boolForKey("lessonRemindersEnabled");
        }
    }
}

