//
//  LessonsListViewTableCellViews.swift
//  LittleReader
//
//  Created by Nathan  Pahucki on 11/19/14.
//  Copyright (c) 2014 Nathan Pahucki. All rights reserved.
//

import UIKit

class NextLessonTableViewCell : UITableViewCell {
    
    @IBOutlet weak var wordsLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var statusImageView: UIImageView!
    @IBOutlet weak var startButton: UIButton!
    
    override func awakeFromNib() {
        startButton.layer.cornerRadius = 5
    }
    
    func setWords(words: [Word]) {
       wordsLabel.text = ", ".join(words.map { $0.text.capitalizedString })
    }
    
    func setDueIn(nextLesson : NSDate) {
        if nextLesson.timeIntervalSinceNow <= 0 {
            contentView.backgroundColor = UIColor.applicationTableCellSelectedBackgroundColor()
            statusLabel.text = NSLocalizedString("lesson_due_now",comment: "")
            statusLabel.textColor = UIColor.applicationGreenColor()
            statusImageView.image = UIImage(named: "IconTimeGreen")
            startButton.backgroundColor = UIColor.applicationGreenColor()
            startButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            startButton.layer.borderWidth = 0
            startButton.hidden = false
            selected = true
        } else if nextLesson.isTomorrow() {
            contentView.backgroundColor = UIColor.whiteColor()
            statusLabel.text = NSLocalizedString("lesson_due_tommorrow",comment: "")
            statusLabel.textColor = UIColor.applicationLightTextColor()
            statusImageView.image = UIImage(named: "IconTimeGrey")
            startButton.hidden = true
            selected = false
        } else {
            contentView.backgroundColor = UIColor.applicationTableCellSelectedBackgroundColor()
            statusLabel.text = NSString(format: NSLocalizedString("lesson_due_in_time",comment: ""),
                nextLesson.stringWithHumanizedTimeDifference(false))
            statusLabel.textColor = UIColor.applicationOrangeColor()
            statusImageView.image = UIImage(named: "IconTimeOrange")
            startButton.backgroundColor = UIColor.clearColor()
            startButton.setTitleColor(UIColor.applicationPinkColor(), forState: .Normal)
            startButton.layer.borderWidth = 1
            startButton.layer.borderColor = UIColor.applicationPinkColor().CGColor
            startButton.hidden = false
            selected = true
        }
    }
}

class PastLessonTableViewCell : UITableViewCell {
    
    @IBOutlet weak var wordsLabel: UILabel!
    @IBOutlet weak var whenTakenLabel: UILabel!
    @IBOutlet weak var retakeButton: UIButton!
    
    override func awakeFromNib() {
        retakeButton.layer.cornerRadius = 5
        retakeButton.layer.borderWidth = 1
        retakeButton.layer.borderColor = UIColor.applicationPinkColor().CGColor
    }
    
    func setLessonLog(log: LessonLog) {
        let words = log.words.componentsSeparatedByString(",")
        wordsLabel.text = ", ".join(words.map { $0.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()).capitalizedString })
        let formatter = NSNumberFormatter()
        formatter.maximumFractionDigits = 1
        let duration = formatter.stringFromNumber(log.durationSeconds)!
        whenTakenLabel.text = NSString(format:  NSLocalizedString("lesson_past_taken_at_and_duration", comment:""), log.lessonDate.stringWithHumanizedTimeDifference(), duration)

    }
}

