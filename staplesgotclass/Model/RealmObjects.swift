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
    dynamic var weekDay: Int?
    let periods = List<SchedulePeriod>()
    
}

class SchedulePeriod: Object {
    dynamic var name: String?
    dynamic var isCustom: Bool = false
    dynamic var id: Int = 0
    dynamic var isLunch: Bool = false
    dynamic var startSeconds: Int = 0
    dynamic var endSeconds: Int = 50*60
    
}

class Course: Object {
    dynamic var name: String?
}

class LunchType: Object {
    dynamic var name: String?
}

class LunchSchedule: Object {
    dynamic var className: String?
    dynamic var lunchType: LunchType?
}
