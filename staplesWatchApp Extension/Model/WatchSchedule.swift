//
//  WatchSchedule.swift
//  staplesgotclass
//
//  Created by Dylan Diamond on 9/5/16.
//  Copyright © 2016 Dylan Diamond. All rights reserved.
//

import UIKit

class WatchSchedule: NSObject {
    var name: String?
    var modifiedDate: NSDate?
    var isStatic: Bool = false
    
    //Weekday: 1 is Sunday, 7 is Saturday
    var weekday = 0
    
    var periods = [WatchSchedulePeriod]()
}
