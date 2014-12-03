//
//  RewardScreenSegue.swift
//  EarlyReader
//
//  Created by Nathan  Pahucki on 12/3/14.
//  Copyright (c) 2014 Nathan Pahucki. All rights reserved.
//

import UIKit

class RewardScreenSegue: UIStoryboardSegue {
    

    override func perform() {
        let dstVc = destinationViewController as RewardScreenViewController
        let srcVc = sourceViewController as LessonViewController
        let srcView = sourceViewController.view as UIView!
        let dstView = destinationViewController.view as UIView!

        
        
        // Place off screen to right
        dstView.frame = CGRect(x:srcView.bounds.width, y:0, width:srcView.bounds.width, height:srcView.bounds.height)
        srcView.addSubview(dstView)

        // Remove contraints som label can slide off screen
        UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1.0, options: UIViewAnimationOptions.allZeros, animations: {
            dstView.frame = CGRect(x:0, y:0, width:srcView.bounds.width, height:srcView.bounds.height)
            srcVc.textLabel.alpha = 0.0
            }, completion: { finished in
                srcVc.addChildViewController(dstVc)
                dstVc.didMoveToParentViewController(srcVc)
        })
    }
}
