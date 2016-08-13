//
//  DailyScheduleManager.swift
//  staplesgotclass
//
//  Created by Dylan on 8/11/16.
//  Copyright © 2016 Dylan Diamond. All rights reserved.
//

import Foundation
import Alamofire
import Parse

class DailyScheduleManager: NSObject {
    static let sharedInstance: DailyScheduleManager = DailyScheduleManager()
    var currentSchedule: Schedule?
    var modifiedSchedules = [Schedule]()
    var staticSchedules = [Schedule]()
    
    private override init() {
        //maybe put custom init code, however since it is initialized at launch probably not necesary. If so, make class func to initialize sharedInstance and we can do custom init.
    }
    
    func getDailySchedule() {
        let query = PFQuery(className: "Schedule")
        query.whereKey("Static", equalTo: true)
        //only get permenant schedules
        
        query.findObjectsInBackgroundWithBlock { (schedules: [PFObject]?, error: NSError?) in
            if (error == nil) {
                for schedule in schedules! {
                    let newSchedule = Schedule()
                    if (schedule["name"] != nil) {
                        newSchedule.name = schedule["Name"] as? String
                    }
                    if let custom = schedule["Static"] as? Bool {
                        newSchedule.isStatic = custom
                    }
                    let periodRelation = schedule.relationForKey("Periods")
                    let periodRelationQuery = periodRelation.query()
                    periodRelationQuery.findObjectsInBackgroundWithBlock({ (periods: [PFObject]?, periodError: NSError?) in
                        if (periodError == nil) {
                            for period in periods! {
                                let newPeriod = SchedulePeriod()
                                newPeriod.name = period["Name"] as? String
                                newSchedule.periods.append(newPeriod)
                            }
                        }
                    })
                }
            }
        }
    }
}
