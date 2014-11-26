//
//  HeartsProgressView.swift
//  EarlyReader
//
//  Created by Nathan  Pahucki on 11/25/14.
//  Copyright (c) 2014 Nathan Pahucki. All rights reserved.
//

import UIKit

class HeartsProgressView: UIView {

    private let heartImageSize = CGSize(width: 21, height: 17)
    private let padSpacing : CGFloat = 4.0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor.whiteColor()
    }
    
    override func intrinsicContentSize() -> CGSize {
        let width = subviews.count == 0 ? 0 : (CGFloat(subviews.count) * (heartImageSize.width + padSpacing)) - padSpacing
        return CGSize(width: width, height: heartImageSize.height)
    }
    
    func setLesson(current:Int, totalLessons:Int, wordSets: Int) {
        // Clear all subviews
        for v in subviews as [UIView] {
            v.removeFromSuperview()
        }

        if wordSets > 0 { // could be zero in some rare cases
            let lessonsPerWordSet = totalLessons / wordSets
            // Create one heart for each wordset
            for idx in 1...wordSets {
                
                let remaining = idx * lessonsPerWordSet - current
                var imageName = "IconHeartSmallEmpty"
                if remaining < 1 {
                    imageName = "IconHeartSmallFull"
                } else if remaining < lessonsPerWordSet {
                    let full = lessonsPerWordSet - remaining
                    assert(full<=2, "Only expecting to deal with 3 repitions of a word set")
                    imageName = "IconHeartSmall\(full)"
                } // Else use empty
                
                
                let imageView = UIImageView(image: UIImage(named: imageName))
                let origin = CGPoint(x:(idx - 1) * Int(heartImageSize.width + padSpacing), y:0)
                imageView.frame = CGRect(origin: origin, size: heartImageSize)
                addSubview(imageView)
            }
        }
        invalidateIntrinsicContentSize()
        setNeedsLayout()
    }
    
}
