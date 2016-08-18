//
//  NSTimeIntervalExtension.swift
//  staplesgotclass
//
//  Created by Dylan Diamond on 8/18/16.
//  Copyright © 2016 Dylan Diamond. All rights reserved.
//

import Foundation

extension NSTimeInterval {
    func stringFromTimeInterval() -> NSString {
        
        let ti = NSInteger(self)
        
        let seconds = ti % 60
        let minutes = (ti / 60)
        
        return NSString(format: "%0.2d:%0.2d",minutes,seconds)
    }
}