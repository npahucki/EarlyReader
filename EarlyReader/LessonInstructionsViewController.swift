//
//  InstructionsViewController.swift
//  EarlyReader
//
//  Created by Nathan  Pahucki on 12/3/14.
//  Copyright (c) 2014 Nathan Pahucki. All rights reserved.
//

import UIKit

class LessonInstructionsViewController: UIViewController {

    var lessonsListController : LessonsListViewController!
    
    @IBAction func didClickContinueButton(sender: UIButton) {
        lessonsListController.dismissInstructionsAndStartLesson()
    }
}
