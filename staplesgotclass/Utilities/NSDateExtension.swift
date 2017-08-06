//
//  NSDateExtension.swift
//  staplesgotclass
//
//  Created by Dylan Diamond on 8/24/16.
//  Copyright © 2016 Dylan Diamond. All rights reserved.
//

import Foundation

extension Date {
    
    func addDay(_ daysToAdd: Int) -> Date {
        return (Calendar.current as NSCalendar)
            .date(
                byAdding: .day,
                value: daysToAdd,
                to: self,
                options: []
        )!
    }
}
