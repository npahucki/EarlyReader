//
//  SlideInFromLeftModalSegue.swift
//  EarlyReader
//
//  Created by Nathan  Pahucki on 12/9/14.
//  Copyright (c) 2014 Nathan Pahucki. All rights reserved.
//

import UIKit


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
        let dstView = toViewInContext(context)!
        let srcView = fromViewInContext(context)!
        
        dstView.frame = inView.convertRect(inView.frame , fromView: nil)
        inView.addSubview(dstView)
        inView.backgroundColor = UIColor.whiteColor()

        let centerScreen = inView.convertPoint(inView.center, fromView: nil)
        var centerOffScreen = centerScreen
        var centerOffScreen2 = centerScreen
        centerOffScreen.x = dstView.frame.size.width * 1.5
        centerOffScreen2.x = dstView.frame.size.width * -0.5
        
        dstView.center = centerOffScreen
        UIView.animateWithDuration(duration, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1.0, options: UIViewAnimationOptions.allZeros, animations: {
                dstView.center = centerScreen
                srcView.center  = centerOffScreen2
            }, completion: { finished in
                context.completeTransition(true)
        })
    }

    func executeDismissalAnimation(context : UIViewControllerContextTransitioning) {
        let inView = context.containerView()
        let dstView = toViewInContext(context)!
        let srcView = fromViewInContext(context)!
        
        // Important that the frame is set BEFORE adding to the container (Bug in iOS 8?)
        dstView.frame = inView.convertRect(inView.frame , fromView: nil)
        inView.addSubview(dstView)
        inView.backgroundColor = UIColor.whiteColor()

        
        let centerScreen = inView.convertPoint(inView.center, fromView: nil)
        var centerOffScreen = centerScreen
        var centerOffScreen2 = centerScreen
        centerOffScreen.x = dstView.frame.size.width * -0.5
        centerOffScreen2.x = dstView.frame.size.width * 1.5
        
        dstView.center = centerOffScreen
        UIView.animateWithDuration(duration, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1.0, options: UIViewAnimationOptions.allZeros, animations: {
            dstView.center = centerScreen
            srcView.center  = centerOffScreen2
            }, completion: { finished in
                context.completeTransition(true)
        })
    }
    
    private func fromViewInContext(transitionContext : UIViewControllerContextTransitioning) -> UIView? {
        if transitionContext.respondsToSelector("viewForKey") {
            return transitionContext.viewForKey(UITransitionContextFromViewKey) // iOS 8+
        } else {
            return transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)?.view
        }
    }
    
    private func toViewInContext(transitionContext : UIViewControllerContextTransitioning) -> UIView? {
        if transitionContext.respondsToSelector("viewForKey") {
            return transitionContext.viewForKey(UITransitionContextToViewKey) // iOS 8+
        } else {
            return transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)?.view
        }
    }

    
}
