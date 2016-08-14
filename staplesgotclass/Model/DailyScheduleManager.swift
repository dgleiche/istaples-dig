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
    let realm = try! Realm()
    
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
        self.modifiedSchedules = Array(realm.objects(Schedule.self).filter("isStatic == false"))
        self.staticSchedules = Array(realm.objects(Schedule.self).filter("isStatic == true"))
        self.lunchSchedules = Array(realm.objects(LunchSchedule.self))
        self.delegate.didFetchSchedules(true)
        self.getDailySchedule()
    }
    
    func getDailySchedule() {
        let query = PFQuery(className: "Schedule")
        query.includeKey("Pointers")
        
        query.findObjectsInBackgroundWithBlock({ (schedules: [PFObject]?, error: NSError?) in
            if (error == nil) {
                try! self.realm.write {
                    self.realm.delete(self.realm.objects(Schedule.self))
                }
                for schedule in schedules! {
                    let newSchedule = Schedule()
                    if (schedule["name"] != nil) {
                        newSchedule.name = schedule["Name"] as? String
                    }
                    if let custom = schedule["Static"] as? Bool {
                        newSchedule.isStatic = custom
                    }
                    if let weekday = schedule["Weekday"] as? Int {
                        newSchedule.weekday = weekday
                    }
                    
                    let periods = schedule["Periods"] as! [PFObject]
                    for period in periods {
                        let newPeriod = SchedulePeriod()
                        newPeriod.name = period["Name"] as? String
                        
                        if let custom = period["Custom"] as? Bool {
                            newPeriod.isCustom = custom
                        }
                        if let id = period["Id"] as? Int {
                            newPeriod.id = id
                        }
                        if let lunch = period["Lunch"] as? Bool {
                            newPeriod.isLunch = lunch
                        }
                        if let startSeconds = period["StartSeconds"] as? Int {
                            newPeriod.startSeconds = startSeconds
                        }
                        if let endSeconds = period["EndSeconds"] as? Int {
                            newPeriod.endSeconds = endSeconds
                        }
                        newSchedule.periods.append(newPeriod)
                    }
                    
                    try! self.realm.write {
                        self.realm.add(newSchedule)
                    }
                    
                    if (newSchedule.isStatic) {
                        self.staticSchedules.append(newSchedule)
                    }
                    else {
                        self.modifiedSchedules.append(newSchedule)
                    }
                    
                }
                
                let lunchQuery = PFQuery(className: "LunchSchedule")
                lunchQuery.includeKey("LunchType")
                
                lunchQuery.findObjectsInBackgroundWithBlock({ (lunchSchedules: [PFObject]?, lunchError: NSError?) in
                    if (error == nil) {
                        try! self.realm.write {
                            self.realm.delete(self.realm.objects(LunchSchedule.self))
                        }
                        
                        for lunchSchedule in lunchSchedules! {
                            let newLunchSchedule = LunchSchedule()
                            let newLunchType = LunchType()
                            if let lunchType = lunchSchedule["LunchType"] as? PFObject {
                                newLunchType.name = lunchType["Name"] as? String
                            }
                            newLunchSchedule.lunchType = newLunchType
                            newLunchSchedule.monthNumber = lunchSchedule["MonthNumber"] as! Int
                            newLunchSchedule.lunchNumber = lunchSchedule["LunchNumber"] as! Int
                            
                            try! self.realm.write {
                                self.realm.add(newLunchSchedule)
                            }
                            self.lunchSchedules.append(newLunchSchedule)
                        }
                        
                        self.delegate.didFetchSchedules(true)
                    }
                    else {
                        self.delegate.didFetchSchedules(false)
                    }
                })
            }
            else {
                self.delegate.didFetchSchedules(false)
            }
        })
    }
    
    func clock() {
        /* currentSchedule must be a valid schedule from modifiedSchedules or staticSchedules */
        
        //if let currentSchedule = self.currentSchedule {
        //Determine current period
        //let curPeriod: SchedulePeriod = getCurPeriod(inSchedule: currentSchedule) ?? SchedulePeriod() // TODO: Last thing should be handled
        
        //Time in, time out, percent in/out
        
        //Determine next period
        
        //}
        
    }
    
    //TODO: Detect 10 mins before, after school;
    func getCurrentPeriod() -> SchedulePeriod? {
        if let schedule = self.currentSchedule {
            //Do math based on current time in seconds in the day, assumed schedule start time, period start time
            let secondsFromMidnight = self.secondsFromMidnight()
            
            var inBetweenPeriods: Bool = false
            var passingTimeStart: Int = 0
            
            for period in schedule.periods {
                if secondsFromMidnight > period.startSeconds {
                    if secondsFromMidnight < period.endSeconds {
                        //Seconds are completely encapsulated in this period, thus this period is the current period
                        return period
                    }
                    
                    inBetweenPeriods = true
                    passingTimeStart = period.endSeconds
                    
                } else if inBetweenPeriods {
                    //secondsFromMidnight was greater than the previous period, but less than the current periods start time
                    //Thus it's passing time
                    //Create and return a passing time period
                    let passingTimePeriod: SchedulePeriod = SchedulePeriod()
                    
                    passingTimePeriod.isPassingTime = true
                    passingTimePeriod.startSeconds = passingTimeStart
                    passingTimePeriod.endSeconds = passingTimeStart + 5 * 60 //5 mins after
                    passingTimePeriod.name = "Passing Time"
                    
                    return passingTimePeriod
                    
                } else if abs(secondsFromMidnight - period.startSeconds) < 10 * 60 {
                    //Ten minutes before school
                    let beforeSchoolPeriod: SchedulePeriod = SchedulePeriod()
                    
                    beforeSchoolPeriod.isBeforeSchool = true
                    beforeSchoolPeriod.startSeconds = period.startSeconds - (10 * 60) //10 mins before
                    beforeSchoolPeriod.endSeconds = period.startSeconds
                    beforeSchoolPeriod.name = "Time until school starts"
                    
                    return beforeSchoolPeriod
                    
                }
            }
            
            //If it's still within ten minutes of the last period, we have the bus passing time thing
            if abs(secondsFromMidnight - passingTimeStart) < 10 * 60 {
                let afterSchoolPeriod: SchedulePeriod = SchedulePeriod()
                
                afterSchoolPeriod.isAfterSchool = true
                afterSchoolPeriod.startSeconds = passingTimeStart
                afterSchoolPeriod.endSeconds = passingTimeStart + 10 * 60 //10 mins after
                afterSchoolPeriod.name = "Get to the buses!"
                
                return afterSchoolPeriod
            }
            
            //Must be before or after the school day
            return nil
        }
        
        //Set yer darn schedules
        print("YOUR SCHEDULE WAS NOT SET! BAD DYLAN! BAD!")
        return nil
    }
    
    func secondsFromMidnight() -> Int {
        let units : NSCalendarUnit = [.Hour, .Minute, .Second]
        let components = NSCalendar.currentCalendar().components(units, fromDate: NSDate())
        return (60 * 60 * components.hour) + (60 * components.minute) + components.second
    }
    
    func getSchedule(withDate date: NSDate) -> Schedule? {
        
        let calendar = NSCalendar.currentCalendar()
        let selDateComponents = calendar.components([.Day, .Month, .Weekday], fromDate: date)
        
        for modifiedSchedule in modifiedSchedules {
            if let modDate = modifiedSchedule.modifiedDate {
                let modDateComponents = calendar.components([.Day , .Month], fromDate: modDate)
                
                if (modDateComponents.month == selDateComponents.month) && (modDateComponents.day == selDateComponents.day) {
                    //Month and day exactly match, thus this date corresponds with a modified schedule
                    return modifiedSchedule
                }
            }
        }
        
        //Function hasnt returned, thus it is a static schedule
        //Determine if it's a weekday (otherwise there is no schedule)
        let weekday = selDateComponents.weekday
        if weekday > 1 && weekday < 7 {
            //It's a weekday
            //Return the corresponding static schedule
            for staticSchedule in staticSchedules {
                if staticSchedule.weekday == weekday { return staticSchedule }
            }
        }
        
        //Assume there's no available schedule (most likely it's a weekend)
        return nil
    }
    
}
