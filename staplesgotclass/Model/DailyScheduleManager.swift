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
import RealmSwift

protocol DailyScheduleManagerDelegate: class {
    func didFetchSchedules(success: Bool)
}

class DailyScheduleManager: NSObject {
    static var sharedInstance: DailyScheduleManager?
    var currentSchedule: Schedule?
    var modifiedSchedules = [Schedule]()
    var staticSchedules = [Schedule]()
    var lunchSchedules = [LunchSchedule]()
    weak var delegate:DailyScheduleManagerDelegate!
    
    private init(delegate: DailyScheduleManagerDelegate) {
        self.delegate = delegate
        super.init()
        self.loadSavedSchedules()
    }
    
    class func setup(delegate: DailyScheduleManagerDelegate) {
        DailyScheduleManager.sharedInstance = DailyScheduleManager(delegate: delegate)
    }
    
    func loadSavedSchedules() {
        let realm = try! Realm()
        self.modifiedSchedules = Array(realm.objects(Schedule.self).filter("isStatic == false"))
        self.staticSchedules = Array(realm.objects(Schedule.self).filter("isStatic == true"))
        self.lunchSchedules = Array(realm.objects(LunchSchedule.self))
        self.delegate.didFetchSchedules(true)
        self.getDailySchedule()
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
