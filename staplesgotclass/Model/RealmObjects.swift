//
//  RealmObjects.swift
//  staplesgotclass
//
//  Created by Dylan Diamond on 8/11/16.
//  Copyright © 2016 Dylan Diamond. All rights reserved.
//

import Foundation
import RealmSwift

class Schedule: Object {
    dynamic var name: String?
    dynamic var date: NSDate?
    dynamic var custom = false
    let periods = List<SchedulePeriod>()
    
    
}

class SchedulePeriod: Object {
    dynamic var name: String?
    dynamic var custom = false
    dynamic var id = 0
    
}
