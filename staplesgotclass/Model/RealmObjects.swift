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
    dynamic var isBeforeSchool: Bool = false
    dynamic var isAfterSchool: Bool = false
    
    //Seconds from midnight
    dynamic var startSeconds: Int = 0
    dynamic var endSeconds: Int = 50*60
    
    dynamic var realPeriod: RealmPeriod? 
    
//    override static func ignoredProperties() -> [String] {
//        return ["realPeriod", "isPassingTime", "isBeforeSchool", "isAfterSchool"]
//    }
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

//MARK: Replacements for period and user to conform to Realm

class RealmUser: Object {
    let schedule = List<RealmPeriod>()
}

class RealmPeriod: Object {
    dynamic var name: String?
    dynamic var periodNumber: Int = 0
    dynamic var teacherName: String?
    dynamic var quarters: String?
    dynamic var id: Int = 0
    
    func setPeriod(period period: Period) {
        self.name = period.name
        self.periodNumber = period.periodNumber
        self.teacherName = period.teacherName
        self.quarters = period.quarters
        self.id = period.id
    }
}
