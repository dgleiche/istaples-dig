//
//  DailySchedule.swift
//  staplesgotclass
//
//  Created by Dylan on 8/11/16.
//  Copyright © 2016 Dylan Diamond. All rights reserved.
//

import Foundation

class DailySchedule: NSObject {
    
    var date: NSDate!
    var isModified: Bool?
    
    init(date: NSDate) {
        self.date = date
        
        super.init()
    }
    
}