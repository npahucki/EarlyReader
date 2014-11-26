//
//  NSStringExtensions.swift
//  EarlyReader
//
//  Created by Nathan  Pahucki on 11/25/14.
//  Copyright (c) 2014 Nathan Pahucki. All rights reserved.
//

import Foundation
import UIKit

extension String {

    func rangesOfString(findStr:String) -> [Range<String.Index>] {
        var arr = [Range<String.Index>]()
        var startInd = self.startIndex
        // check first that the first character of search string exists
        if contains(self, first(findStr)!) {
            // if so set this as the place to start searching
            startInd = find(self,first(findStr)!)!
        }
        else {
            // if not return empty array
            return arr
        }
        var i = distance(self.startIndex, startInd)
        while i<=countElements(self)-countElements(findStr) {
            if self[advance(self.startIndex, i)..<advance(self.startIndex, i+countElements(findStr))] == findStr {
                arr.append(Range(start:advance(self.startIndex, i),end:advance(self.startIndex, i+countElements(findStr))))
                i = i+countElements(findStr)
            }
            i++
        }
        return arr
    }
}


