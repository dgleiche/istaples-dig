//
//  NSDateExtension.swift
//  staplesgotclass
//
//  Created by Dylan Diamond on 8/24/16.
//  Copyright © 2016 Dylan Diamond. All rights reserved.
//

import Foundation

extension NSDate {
    
    func addDay(daysToAdd: Int) -> NSDate {
        return NSCalendar.currentCalendar()
            .dateByAddingUnit(
                .Day,
                value: daysToAdd,
                toDate: self,
                options: []
        )!
    }
}
