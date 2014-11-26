//
//  Notification.swift
//  EarlyReader
//
//  Created by Nathan  Pahucki on 11/20/14.
//  Copyright (c) 2014 Nathan Pahucki. All rights reserved.
//

import Foundation
import CoreData

enum NotificationType : Int {
    case Alert = 0
    case Tip = 1
    case Guidance = 2
}

public class Notification: NSManagedObject {

    @NSManaged public var deliveredOn: NSDate
    @NSManaged public var expiresOn: NSDate?
    @NSManaged public var key: String
    @NSManaged public var message: String?
    @NSManaged public var title: String
    @NSManaged public var args: String?
    @NSManaged public var type: NSNumber
    @NSManaged public var closedByUser: Bool
    @NSManaged public var baby: Baby?
    

    class func newNotification(type : NotificationType, key : String, title : String, context : NSManagedObjectContext) -> Notification {
        let entityDescription = NSEntityDescription.entityForName("Notification", inManagedObjectContext:context)
        let n1 = Notification(entity: entityDescription!, insertIntoManagedObjectContext: context)
        n1.deliveredOn = NSDate()
        n1.key = key
        n1.type = type.rawValue
        n1.title = title
        n1.baby = Baby.currentBaby
        context.insertObject(n1)
        return n1
    }

    /// Creates and returns a new Notification only if one with the same key does not already exist
    class func newUniqueNotification(type : NotificationType, key : String, title : String, context : NSManagedObjectContext) -> Notification? {
        if !existsNotificaitonWithKey(key, context: context) {
           return newNotification(type, key : key, title : title, context : context)
        }
        return nil
    }

    
    class func existsNotificaitonWithKey(key: String, context : NSManagedObjectContext) -> Bool {
        let fetchRequest = NSFetchRequest()
        fetchRequest.entity = NSEntityDescription.entityForName("Notification", inManagedObjectContext:context)
        fetchRequest.predicate = NSPredicate(format: "key = %@", key)
        return context.countForFetchRequest(fetchRequest, error: nil) > 0
    }
    
}
