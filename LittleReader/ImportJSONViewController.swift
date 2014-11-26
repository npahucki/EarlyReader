//
//  ImportJSONViewController.swift
//  LittleReader
//
//  Created by Nathan  Pahucki on 11/26/14.
//  Copyright (c) 2014 Nathan Pahucki. All rights reserved.
//

import UIKit
import CoreData

class ImportJSONViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, ManagedObjectContextHolder {
    

    @IBOutlet weak var entityPickerView: UIPickerView!
    @IBOutlet weak var jsonTextView: UITextView!
    @IBOutlet weak var textViewBottomConstraint: NSLayoutConstraint!
    
    private let _entityNames = ["Word", "WordSet", "LessonLog","Notification"]
    private let _operationNames = ["Import", "Export"]
    private let _importOptionNames = ["Erase First", "Append"]
    private let _exportOptionNames = ["Flat", "Pretty"]
    
    var managedContext : NSManagedObjectContext? = nil
    
    
    @IBAction func didClickCloseButton(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func didClickDoneButton(sender: UIButton) {
        self.view.endEditing(true)
        let entityName = _entityNames[entityPickerView.selectedRowInComponent(0)]
        let tool = NSManagedObjectExporterImporter(managedObjectContext: managedContext!)
        if entityPickerView.selectedRowInComponent(1) == 0 {
            // Import
            let clearFirst = entityPickerView.selectedRowInComponent(2) == 0
            let result = tool.importJSON(entityName, json: jsonTextView.text, clearEntitiesFirst: clearFirst)
            if let err = result.error {
                    NSLog("Failed to import JSON: %@", err)
                UIAlertView(title: "Oh shucks!", message: "Failed to import the JSON, please validate it before trying again. See log for error details.", delegate: nil, cancelButtonTitle: "Ok").show()
            } else {
                UIAlertView(title: "Goody!", message: "Imported \(result.numbeOfEntitiesImported) entities.", delegate: nil, cancelButtonTitle: "Ok").show()
            }
        } else {
            // Export
            let prettyPrint = entityPickerView.selectedRowInComponent(2) == 1
            let result = tool.exportAll(entityName, prettyPrint : prettyPrint)
            if let err = result.error {
                NSLog("Failed to export JSON: %@", err)
                UIAlertView(title: "Oh shucks!", message: "Failed to export the JSON. This should not happen! See log for error details.", delegate: nil, cancelButtonTitle: "Ok").show()

            } else {
                jsonTextView.text = result.json
            }
        }
    }
    
    override func viewDidLoad() {
        jsonTextView.layer.borderWidth = 1
        entityPickerView.dataSource = self
        entityPickerView.delegate = self
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didShowKeyBoard:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didHideKeyBoard:", name: UIKeyboardDidHideNotification, object: nil)
    }

    override func viewDidAppear(animated: Bool) {
        // Show keyboard right away.
        jsonTextView.becomeFirstResponder()
    }
    
    func didHideKeyBoard(notification: NSNotification) {
        view.layoutIfNeeded()
        textViewBottomConstraint.constant = 8
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }
    
    func didShowKeyBoard(notification: NSNotification) {
        if let keyboardInfo = notification.userInfo {
            let keyboardFrameBegin = keyboardInfo[UIKeyboardFrameBeginUserInfoKey] as NSValue
            let keyboardFrameBeginRect = keyboardFrameBegin.CGRectValue()
            view.layoutIfNeeded()
            textViewBottomConstraint.constant = keyboardFrameBeginRect.height + 8
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.view.layoutIfNeeded()
            })
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 3
    }

    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return _entityNames.count
        case 1:
            return _operationNames.count
        case 2:
            return entityPickerView.selectedRowInComponent(1) == 0 ? _importOptionNames.count : _exportOptionNames.count
        default:
            return -1
        }
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        switch component {
        case 0:
            return _entityNames[row]
        case 1:
            return _operationNames[row]
        case 2:
            return entityPickerView.selectedRowInComponent(1) == 0 ? _importOptionNames[row] : _exportOptionNames[row]
        default:
            return ""
        }
    }
    
    func pickerView(pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return component == 0 ? 200 : 100
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 1 {
            pickerView.reloadComponent(2)
            jsonTextView.text = ""
            jsonTextView.editable = (row == 0)
        } else if component == 0 {
            jsonTextView.text = ""
        }
    }
    
    
    
}
