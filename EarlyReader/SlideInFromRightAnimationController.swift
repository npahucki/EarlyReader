//
//  SlideInFromLeftModalSegue.swift
//  EarlyReader
//
//  Created by Nathan  Pahucki on 12/9/14.
//  Copyright (c) 2014 Nathan Pahucki. All rights reserved.
//

import UIKit


class SlideInFromRightSegue : UIStoryboardSegue {
    override func perform() {
            let source = sourceViewController as UIViewController
            let destination = destinationViewController as UIViewController
            UIView.transitionFromView(source.view, toView:destination.view, duration:0.50, options:UIViewAnimationOptions.TransitionFlipFromLeft,completion:nil)
    }
}


class SlideInFromRightAnimationController : NSObject, UIViewControllerAnimatedTransitioning {

    var isPresenting = true
    var duration : NSTimeInterval = 2.0
    
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return duration
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        if self.isPresenting {
            executePresentationAnimation(transitionContext)
        } else {
            executeDismissalAnimation(transitionContext)
        }
    }
    
    func animationEnded(transitionCompleted: Bool) {
        
    }
    
    func executePresentationAnimation(context : UIViewControllerContextTransitioning) {
        let inView = context.containerView()
        let dstVc = context.viewControllerForKey(UITransitionContextToViewControllerKey)!
        let srcVc = context.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        
        // Important that the frame is set BEFORE adding to the container
        dstVc.view.frame = inView.frame;
        inView.addSubview(dstVc.view)
        inView.backgroundColor = UIColor.whiteColor()
        
        var centerOffScreen = inView.center
        centerOffScreen.y = inView.frame.size.height * -0.5 // Note this causes a slide from the right in portrait mode!
        dstVc.view.center = centerOffScreen
        var centerOffScreen2 = inView.center
        centerOffScreen2.y = inView.frame.size.height * 1.5
        
        UIView.animateWithDuration(duration, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1.0, options: UIViewAnimationOptions.allZeros, animations: {
                dstVc.view.center = inView.center
                srcVc.view.center  = centerOffScreen2
            }, completion: { finished in
                context.completeTransition(true)
        })
    }

    func executeDismissalAnimation(context : UIViewControllerContextTransitioning) {
        let inView = context.containerView()
        let dstVc = context.viewControllerForKey(UITransitionContextToViewControllerKey)!
        let srcVc = context.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        
        // Important that the frame is set BEFORE adding to the container
        dstVc.view.frame = inView.frame;
        inView.addSubview(dstVc.view)
        inView.backgroundColor = UIColor.whiteColor()
        
        var centerOffScreen = inView.center
        centerOffScreen.y = 1.5 * inView.frame.size.height // Note this causes a slide from the right in portrait mode!
        dstVc.view.center = centerOffScreen
        var centerOffScreen2 = inView.center
        centerOffScreen2.y = inView.frame.size.height * -0.5
        
        UIView.animateWithDuration(duration, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1.0, options: UIViewAnimationOptions.allZeros, animations: {
            dstVc.view.center = inView.center
            srcVc.view.center  = centerOffScreen2
            }, completion: { finished in
                context.completeTransition(true)
        })
    }
    
}
