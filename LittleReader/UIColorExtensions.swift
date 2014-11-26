//
//  UIColorExtensions.swift
//  EarlyReader
//
//  Created by Nathan  Pahucki on 11/11/14.
//  Copyright (c) 2014 Nathan Pahucki. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    
    class func applicationPinkColor() -> UIColor {
        return colorFromRGB(0xf0045a)
    }

    class func applicationBlueColor() -> UIColor {
        return colorFromRGB(0x178DC8)
    }
    
    class func applicationLightTextColor() -> UIColor {
        return colorFromRGB(0xCCCCCC)
    }

    class func applicationTextColor() -> UIColor {
        return colorFromRGB(0x333333)
    }

    class func applicationGreenColor() -> UIColor {
        return colorFromRGB(0x2EBF68)
    }

    class func applicationOrangeColor() -> UIColor {
        return colorFromRGB(0xFC5B22)
    }

    class func applicationTableCellSelectedBackgroundColor() -> UIColor {
        return colorFromRGB(0xF1F1F1)
    }
    
    // Move to category on image!
    class func backgroundImageWithColor(color : UIColor) -> UIImage {
        var rect = CGRectMake(0.0, 0.0, 1.0, 1.0);
        UIGraphicsBeginImageContext(rect.size);
        var context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, color.CGColor);
        CGContextFillRect(context, rect);
        var image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return image;
    }
    
    class func colorFromRGB(rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }

}
