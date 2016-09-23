//
//  WatchSchedulePeriod.swift
//  staplesgotclass
//
//  Created by Dylan Diamond on 9/5/16.
//  Copyright © 2016 Dylan Diamond. All rights reserved.
//

import UIKit

class WatchSchedulePeriod: NSObject {
     var name: String?
     var isCustom: Bool = false
     var id: Int = 0
     var isLunch: Bool = false
     var isPassingTime: Bool = false
     var isBeforeSchool: Bool = false
     var isAfterSchool: Bool = false
    
    //Seconds from midnight
     var startSeconds: Int = 0
     var endSeconds: Int = 50*60
    
     var realPeriod: WatchPeriod?
     var isLunchPeriod: Bool = false
     var lunchNumber: Int = 0
}
