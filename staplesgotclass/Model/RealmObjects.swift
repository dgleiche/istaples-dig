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
    dynamic var modifiedDate: Date?
    dynamic var isStatic: Bool = false
    
    let periods = List<SchedulePeriod>()
    
    func containsLunchPeriods() -> Bool {
        for period in periods {
            if (period.isLunchPeriod == true) {
                return true
            }
        }
        return false
    }
    
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
    dynamic var lunchType: LunchType?
    
    dynamic var isLunchPeriod: Bool = false
    dynamic var lunchNumber: Int = 0
    
//    override static func ignoredProperties() -> [String] {
//        return ["realPeriod", "isPassingTime", "isBeforeSchool", "isAfterSchool"]
//    }
}

class Course: Object {
    dynamic var name: String?
    dynamic var lunchType: LunchType?
}

class BlockDay: Object {
    dynamic var date: Date?
    dynamic var title: String?
}

class LunchType: Object {
    dynamic var name: String?
    dynamic var isLab: Bool = false
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
    dynamic var color: UIColor?
    
    func setPeriod(_ period: Period) {
        self.name = period.name
        self.periodNumber = period.periodNumber
        self.teacherName = period.teacherName
        self.quarters = period.quarters
        self.id = period.id
    }
    
    func exchangeForRealPeriod() -> Period? {
        if (UserManager.sharedInstance != nil) {
            if (UserManager.sharedInstance?.currentUser.schedule != nil) {
                for period in (UserManager.sharedInstance?.currentUser.schedule)! {
                    if (period.id == self.id) {
                        return period
                    }
                }
            }
        }
        return nil
    }
}

class Homework: Object {
    dynamic var periodNumber = 0
    dynamic var assignment: String?
    dynamic var dueDate: Date?
}
