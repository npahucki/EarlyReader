//
//  NSManagedObjectExportImport.swift
//  EarlyReader
//
//  Created by Nathan  Pahucki on 11/26/14.
//  Copyright (c) 2014 Nathan Pahucki. All rights reserved.
//

import CoreData

class NSManagedObjectExporterImporter {
    
    private let _managedObjectContext : NSManagedObjectContext
    
    init(managedObjectContext : NSManagedObjectContext) {
        _managedObjectContext = managedObjectContext
    }
    
    func export(entityName : String, predicate : NSPredicate?, prettyPrint : Bool) -> (json :String?, error : NSError?) {
        var jsonString : String? = nil
        var error : NSError? = nil
        
        let fetchRequest = NSFetchRequest(entityName: entityName)
        fetchRequest.resultType = NSFetchRequestResultType.DictionaryResultType
        if let results = _managedObjectContext.executeFetchRequest(fetchRequest, error: &error) as? [NSDictionary] {
            for d in results {
                for (k, v) in d {
                    // Replace dates with strings
                    if let date = v as? NSDate {
                        d.setValue(date.toISO8601String(), forKey: k as NSString)
                    }
                }
            }
            let options = prettyPrint ? NSJSONWritingOptions.PrettyPrinted : NSJSONWritingOptions.allZeros
            let jsonData = NSJSONSerialization.dataWithJSONObject(results, options:options, error:&error)
            jsonString = NSString(data: jsonData!, encoding: NSUTF8StringEncoding)
        }
        
        return (json : jsonString, error : error)
    }

    func exportAll(entityName : String, prettyPrint : Bool) -> (json :String?, error : NSError?) {
        return export(entityName, predicate: nil, prettyPrint : prettyPrint)
    }
    
    func importJSON(entityName : String,  json: String, clearEntitiesFirst : Bool = false) -> (numbeOfEntitiesImported : Int, error : NSError?) {
        var count = 0
        var error : NSError?

        // Clear first if needed
        if clearEntitiesFirst {
            let fetchRequest = NSFetchRequest(entityName: entityName)
            if let results = _managedObjectContext.executeFetchRequest(fetchRequest, error: &error) as? [NSManagedObject] {
                for o in results {
                    _managedObjectContext.deleteObject(o)
                }
            }
        }
        
        if error == nil {
            if let entityDescription = NSEntityDescription.entityForName(entityName, inManagedObjectContext:_managedObjectContext) {
                let data = json.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
                if let objects = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers, error: &error) as? [NSDictionary] {
                    for d in objects {
                        count++
                        let ent = NSManagedObject(entity: entityDescription, insertIntoManagedObjectContext: _managedObjectContext)
                        ent.setValue(Baby.currentBaby, forKey: "baby")
                        for (k,v) in d {
                            var newVal: AnyObject = v
                            if let s = v as? String {
                                // Try to see if it can be parsed to a date, if so use that
                                if let date = NSDate.dateFromISO8601String(s) {
                                    newVal = date
                                }
                            }
                            ent.setValue(newVal, forKey: k as String)
                        }
                        
                    }
                    _managedObjectContext.save(&error)
                }
            }
        } else {
            error = NSError.applicationError(NSError.ErrorCode.FailedToImportEntites, description: "There is no Entity named \(entityName)")
        }

        
        if error != nil {
            _managedObjectContext.reset()
        }
        
        return (numbeOfEntitiesImported : count, error : error)
        
    }
    
    
}

