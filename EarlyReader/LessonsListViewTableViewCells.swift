//
//  LessonsListViewTableCellViews.swift
//  EarlyReader
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
    
    func indicateNoMoreWords() {
        contentView.backgroundColor = UIColor.applicationPinkColor()
        wordsLabel.text = NSLocalizedString("lesson_no_more_words_title",comment: "")
        wordsLabel.textColor = UIColor.whiteColor()
        statusLabel.text = NSLocalizedString("lesson_no_more_words",comment: "")
        statusLabel.textColor = UIColor.whiteColor()
        statusImageView.image = UIImage(named: "IconAlerts")
        startButton.hidden = true
        selected = false
    }
    
    func setWords(words: [Word]) {
        contentView.backgroundColor = UIColor.whiteColor()
        // NOTE: This used to be done using the map function, but the compiler does something 
        // very odd during optimization and it does not capitalize the words at all.
        //wordsLabel.text = ", ".join(words.map { $0.text.capitalizedString}) - FAIL in Release!
        
        var wordsText = ""
        for (idx,w) in enumerate(words) {
            if idx > 0 { wordsText += ", " }
            wordsText += w.text.capitalizedString
        }
        wordsLabel.text = wordsText
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
    
    func setLessonLog(log: LessonLog) {
        let words = log.words.componentsSeparatedByString(",")
        wordsLabel.text = ", ".join(words.map { $0.capitalizedString })
        let formatter = NSNumberFormatter()
        formatter.maximumFractionDigits = 1
        let duration = formatter.stringFromNumber(log.durationSeconds)!
        whenTakenLabel.text = NSString(format:  NSLocalizedString("lesson_past_taken_at_and_duration", comment:""), log.lessonDate.stringWithHumanizedTimeDifference(), duration)

    }
}

