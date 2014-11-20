//
//  Notification.swift
//  LittleReader
//
//  Created by Nathan  Pahucki on 11/20/14.
//  Copyright (c) 2014 Nathan Pahucki. All rights reserved.
//

import Foundation
import CoreData

enum NotificationType : Int {
    case Alert = 0
    case Tip = 1
    case Error = 2
}

public class Notification: NSManagedObject {

    
    @NSManaged public var deliveredOn: NSDate
    @NSManaged public var message: String
    @NSManaged public var type: NSNumber

}
