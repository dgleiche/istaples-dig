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
    dynamic var modifiedDate: NSDate?
    dynamic var isStatic: Bool = false
    
    //Weekday: 1 is Sunday, 7 is Saturday
    dynamic var weekday = 0
    
    let periods = List<SchedulePeriod>()
    
}

class SchedulePeriod: Object {
    dynamic var name: String?
    dynamic var isCustom: Bool = false
    dynamic var id: Int = 0
    dynamic var isLunch: Bool = false
    dynamic var isPassingTime: Bool = false
    
    //Seconds from midnight
    dynamic var startSeconds: Int = 0
    dynamic var endSeconds: Int = 50*60
    
}

class Course: Object {
    dynamic var name: String?
    dynamic var lunchType: LunchType?
}

class LunchType: Object {
    dynamic var name: String?
}

class LunchSchedule: Object {
    dynamic var lunchType: LunchType?
    dynamic var monthNumber = 0
    dynamic var lunchNumber = 0
}
