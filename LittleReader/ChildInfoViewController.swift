//
//  ChildInfoViewController.swift
//  LittleReader
//
//  Created by Nathan  Pahucki on 10/23/14.
//  Copyright (c) 2014 Nathan Pahucki. All rights reserved.
//

import UIKit
import CoreData




class ChildInfoViewController: UIViewController, UITextFieldDelegate, ManagedObjectContextHolder {
    var managedContext : NSManagedObjectContext? = nil
    var baby : Baby? = nil
   
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var childNameTextField: UITextField!

    @IBOutlet weak var birthDatePicker: UIDatePicker!
    override func viewDidLoad() {
        birthDatePicker.maximumDate = NSDate()
        if let b = baby {
            birthDatePicker.date =  b.birthDate
            childNameTextField.text = b.name
        } else {
            birthDatePicker.date =  birthDatePicker.maximumDate!
            if let ctx = managedContext {
                if let entityDescripition = NSEntityDescription.entityForName("Baby", inManagedObjectContext:ctx) {
                    baby = Baby(entity: entityDescripition, insertIntoManagedObjectContext: ctx)
                }
            }
        }
        calcDoneButtonEnabled()
        
    }
    
    @IBAction func didClickDoneButton(sender: UIBarButtonItem) {
        baby!.name = childNameTextField.text
        baby!.birthDate = birthDatePicker.date

        var error : NSError? = nil
        baby!.managedObjectContext!.save(&error)
        if let e = error {
            UsageAnalytics.trackError("Could not save baby", error: e)
            UIAlertView.showGenericLocalizedErrorMessage("error_msg_baby_save")
        } else {
            Baby.currentBaby = baby
            self.dismissViewControllerAnimated(true, nil)
        }
    }

    func calcDoneButtonEnabled() -> Bool {
        doneButton.enabled = countElements(childNameTextField.text) > 1
        return doneButton.enabled
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if calcDoneButtonEnabled() {
            textField.resignFirstResponder()
            return true
        }
        
        return false
    }
    
    
    
}
