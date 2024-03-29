//
//  ChildInfoViewController.swift
//  EarlyReader
//
//  Created by Nathan  Pahucki on 10/23/14.
//  Copyright (c) 2014 Nathan Pahucki. All rights reserved.
//

import UIKit
import CoreData




class ChildInfoViewController: UIViewController, UITextFieldDelegate, ChildInfoBirthDatePopoverViewControllerDelegate  {

    var baby : Baby!
    var skipButtonShouldCancel = false

    private var popover : UIPopoverController?

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var childBirthDateTextField: UITextField!
    @IBOutlet weak var childNameTextField: UITextField!
    @IBOutlet weak var skipButton: UIButton!

    override func viewDidLoad() {
        assert(baby != nil, "Expected a baby would be set before view is loaded!")
        childNameTextField.text = baby.name
        childBirthDateTextField.text = childsDisplayAge()
        calcDoneButtonEnabled()
        skipButton.hidden = baby.name != nil // Once the baby name is filled in, then just show save button. 
    }
    
    @IBAction func didChangeNameField(sender: AnyObject) {
        calcDoneButtonEnabled()
    }
    
    @IBAction func didClickDoneButton(sender: UIButton) {
        doneButton.enabled = false
        skipButton.enabled = false
        
        activityIndicator.startAnimating()
        
        if sender == skipButton {
            UsageAnalytics.instance.trackSkippedEnteringBabyInfo()
            if skipButtonShouldCancel {
                baby.managedObjectContext?.rollback()
                dismissViewControllerAnimated(true, completion: nil)
                return
            } else {
                baby.name = nil
                baby.birthDate = nil
            }
        } else {
            baby.name = childNameTextField.text
        }
        
        var error : NSError? = nil
        baby.managedObjectContext!.save(&error)
        if let e = error {
            skipButton.enabled = true
            self.calcDoneButtonEnabled()
            self.activityIndicator.stopAnimating()
            UsageAnalytics.instance.trackError("Could not save baby", error: e)
            UIAlertView.showGenericLocalizedErrorMessage("msg_error_baby_save")
        } else {
            Baby.currentBaby = baby
            UsageAnalytics.instance.identify() // Reidentify with Baby Info this time.
            if baby.wordSets.count < 1 {
                let importer = WordImporter(baby : baby)
                importer.importWordListNamed("basic") { (error, numberOfWordsImported) -> () in
                    self.activityIndicator.stopAnimating()
                    self.skipButton.enabled = true
                    self.calcDoneButtonEnabled()
                    if let err = error {
                        UIAlertView.showLocalizedErrorMessageWithOkButton("error_msg_download_word_list", title_key : "error_title_download_word_list")
                        UsageAnalytics.instance.trackError("Could not load initial word list", error: err)
                    } else {
                        self.baby.populateWordSets(1)
                        self.dismissViewControllerAnimated(true, nil)
                    }
                }
            } else {
                self.dismissViewControllerAnimated(true, nil)
            }
        }
    }

    func childsDisplayAge() ->String? {
        if let birthDate = baby.birthDate {
            return "\(birthDate.stringWithHumanizedTimeDifference(false)) old"
        } else {
            return nil
        }
    }
    
    func calcDoneButtonEnabled() -> Bool {
        childBirthDateTextField.enabled = !childNameTextField.text.isEmpty
        doneButton.enabled = childBirthDateTextField.enabled && !childBirthDateTextField.text.isEmpty
        return doneButton.enabled
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == childNameTextField && !childNameTextField.text.isEmpty {
            childBirthDateTextField.becomeFirstResponder()
            return true
        }
        
        return false
    }
    
    func changedChildBirthDate(date : NSDate) {
        baby.birthDate = date
        childBirthDateTextField.text = childsDisplayAge()
    }
    
    func selectedChildBirthDate(date : NSDate) {
        baby.birthDate = date
        childBirthDateTextField.text = childsDisplayAge()
        calcDoneButtonEnabled()
        popover?.dismissPopoverAnimated(true)
    }
    
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        // Prevent keyboard, and show popup
        if textField == childBirthDateTextField {
            childNameTextField.resignFirstResponder()
            performSegueWithIdentifier("showDatePickerPopover", sender: self)
            return false;
        }
        
        return true
    }
    


    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        baby.name = childNameTextField.text
        if let vc = segue.destinationViewController as? ChildInfoBirthDatePopoverViewController {
            vc.baby = baby
            vc.delegate = self
            if let popOverSegue = segue as? UIStoryboardPopoverSegue {
                popover = popOverSegue.popoverController
            }
        }
    }
    
}
