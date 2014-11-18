//
//  ChildInfoViewController.swift
//  LittleReader
//
//  Created by Nathan  Pahucki on 10/23/14.
//  Copyright (c) 2014 Nathan Pahucki. All rights reserved.
//

import UIKit
import CoreData




class ChildInfoViewController: UIViewController, UITextFieldDelegate, ChildInfoBirthDatePopoverViewControllerDelegate  {

    var baby : Baby!
   
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var childBirthDateTextField: UITextField!
    @IBOutlet weak var childNameTextField: UITextField!

    override func viewDidLoad() {
        assert(baby != nil, "Expected a baby would be set before view is loaded!")
        childNameTextField.text = baby.name
        childBirthDateTextField.text = childsDisplayAge()
        calcDoneButtonEnabled()
    }
    
    @IBAction func didClickDoneButton(sender: UIButton) {
        sender.enabled = false;
        activityIndicator.startAnimating()
        baby.name = childNameTextField.text
        var error : NSError? = nil
        baby.managedObjectContext!.save(&error)
        if let e = error {
            UsageAnalytics.trackError("Could not save baby", error: e)
            UIAlertView.showGenericLocalizedErrorMessage("msg_error_baby_save")
        } else {
            Baby.currentBaby = baby
            if baby.wordSets.count < 1 {
                let importer = WordImporter(managedContext: baby!.managedObjectContext!)
                importer.importWordListNamed("basic") { (error, numberOfWordsImported) -> () in
                    self.activityIndicator.stopAnimating()
                    sender.enabled = true
                    if let err = error {
                        UIAlertView.showLocalizedErrorMessageWithOkButton("error_msg_download_word_list", title_key : "error_title_download_word_list")
                        UsageAnalytics.trackError("Could not load initial word list", error: err)
                    } else {
                        self.baby.populateWordSets(1) // TODO: Maybe change depending on age?
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
        let enabled = countElements(childNameTextField.text) > 1
        childBirthDateTextField.enabled = enabled
        doneButton.enabled = enabled
        return enabled
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == childNameTextField && calcDoneButtonEnabled() {
            childBirthDateTextField.becomeFirstResponder()
            return true
        }
        
        return false
    }
    
    func changedChildBirthDate(date : NSDate) {
        baby.birthDate = date
        childBirthDateTextField.text = childsDisplayAge()
        calcDoneButtonEnabled()
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
        }
    }
    
}
