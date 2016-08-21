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
    func logoutUser()
}

class DailyScheduleManager: NSObject {
    static var sharedInstance: DailyScheduleManager?
    var currentSchedule: Schedule?
    
    var currentPeriod: SchedulePeriod?
    
    var modifiedSchedules = [Schedule]()
    var staticSchedules = [Schedule]()
    var lunchSchedules = [LunchSchedule]()
    var courses = [Course]()
    var realmPeriods = [RealmPeriod]()
    var currentUser: RealmUser?
    
    let realm = try! Realm()
    
    weak var delegate:DailyScheduleManagerDelegate!
    
    private init(delegate: DailyScheduleManagerDelegate) {
        self.delegate = delegate
        super.init()
        DailyScheduleManager.sharedInstance = self
        self.loadSavedData()
    }
    
    class func setup(delegate: DailyScheduleManagerDelegate) {
        DailyScheduleManager.sharedInstance = DailyScheduleManager(delegate: delegate)
    }
    
    func loadSavedData() {
        self.modifiedSchedules = Array(realm.objects(Schedule.self).filter("isStatic == false"))
        self.staticSchedules = Array(realm.objects(Schedule.self).filter("isStatic == true"))
        self.lunchSchedules = Array(realm.objects(LunchSchedule.self))
        self.courses = Array(realm.objects(Course.self))
        self.currentUser = realm.objects(RealmUser.self).first
        if (staticSchedules.count > 0 && lunchSchedules.count > 0 && currentUser != nil) {
            print("realm objects found")
            self.delegate.didFetchSchedules(true)
        }
        else if (currentUser == nil) {
            self.delegate.logoutUser()
            return
        }
        self.getDailySchedule()
    }
    
    func getDailySchedule() {
        let query = PFQuery(className: "Schedule")
        query.includeKey("Periods")
        query.findObjectsInBackgroundWithBlock({ (schedules: [PFObject]?, error: NSError?) in
            if (error == nil) {
                try! self.realm.write {
                    self.realm.delete(self.modifiedSchedules)
                    self.realm.delete(self.staticSchedules)
                }
                self.modifiedSchedules.removeAll()
                self.staticSchedules.removeAll()
                
                for schedule in schedules! {
                    let newSchedule = Schedule()
                    if (schedule["Name"] != nil) {
                        newSchedule.name = schedule["Name"] as? String
                    }
                    if let custom = schedule["Static"] as? Bool {
                        newSchedule.isStatic = custom
                    }
                    if let weekday = schedule["Weekday"] as? Int {
                        newSchedule.weekday = weekday
                    }
                    if let modifiedDate = schedule["ModifiedDate"] as? NSDate {
                        newSchedule.modifiedDate = modifiedDate
                    }
                    
                    let periods = schedule["Periods"] as! [PFObject]
                    print("periods: \(periods)")
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
                    //
                    //                    let sortedPeriods = newSchedule.periods.sorted("startSeconds")
                    //                    newSchedule.periods.removeAll()
                    //                    for sortedPeriod in sortedPeriods {
                    //                        newSchedule.periods.append(sortedPeriod)
                    //                    }
                    
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
                            self.realm.delete(self.lunchSchedules)
                        }
                        self.lunchSchedules.removeAll()
                        
                        for lunchSchedule in lunchSchedules! {
                            let newLunchSchedule = LunchSchedule()
                            let newLunchType = LunchType()
                            if let lunchType = lunchSchedule["LunchType"] as? PFObject {
                                newLunchType.name = lunchType["Name"] as? String
                            }
                            newLunchSchedule.lunchType = newLunchType
                            newLunchSchedule.monthNumber = lunchSchedule["MonthNumber"] as! Int
                            newLunchSchedule.lunchNumber = lunchSchedule["LunchNumber"] as! Int
                            
                            self.lunchSchedules.append(newLunchSchedule)
                        }
                        
                        let courseQuery = PFQuery(className: "Course")
                        courseQuery.includeKey("LunchType")
                        courseQuery.findObjectsInBackgroundWithBlock({ (courses: [PFObject]?, courseError: NSError?) in
                            if (error == nil) {
                                for course in courses! {
                                    let newCourse = Course()
                                    let newLunchType = LunchType()
                                    if let lunchType = course["LunchType"] as? PFObject {
                                        newLunchType.name = lunchType["Name"] as? String
                                    }
                                    newCourse.lunchType = newLunchType
                                    newCourse.name = course["Name"] as? String
                                    self.courses.append(newCourse)
                                }
                                self.delegate.didFetchSchedules(true)
                                
                                try! self.realm.write {
                                    self.realm.add(self.staticSchedules)
                                    self.realm.add(self.modifiedSchedules)
                                    self.realm.add(self.lunchSchedules)
                                    self.realm.add(self.courses)
                                }
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
            else {
                self.delegate.didFetchSchedules(false)
            }
        })
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
                    passingTimePeriod.endSeconds = (getNextSchedulePeriodInSchedule()?.startSeconds)! //keep passing time until next period starts, DYLAN CHECK TO MAKE SURE THIS WORKS
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
    
    // Gets the next period that hasn't already happened (returns nil if every period has happened)
    func getNextSchedulePeriodInSchedule() -> SchedulePeriod? {
        if let schedule = self.currentSchedule {
            var dayStarted: Bool = false
            var lastPeriodEndTime: Int = 0
            
            let secondsFromMidnight = self.secondsFromMidnight()
            
            //Assumes period array is sorted by startSeconds ascending
            for period in schedule.periods {
                
                //Skip periods that have already happened
                if secondsFromMidnight > period.startSeconds {
                    dayStarted = true
                    lastPeriodEndTime = period.endSeconds
                    continue
                }
                
                //If the day hasn't started, the first period event is 10 mins before school
                if !dayStarted {
                    let beforeSchoolPeriod: SchedulePeriod = SchedulePeriod()
                    
                    beforeSchoolPeriod.isBeforeSchool = true
                    beforeSchoolPeriod.startSeconds = period.startSeconds - (10 * 60) //10 mins before
                    beforeSchoolPeriod.endSeconds = period.startSeconds
                    beforeSchoolPeriod.name = "Time until school starts"
                    
                    return beforeSchoolPeriod
                }
                
                //Period hasnt happened yet, return it
                return period
            }
            
            //If it's still the last period account for bus passing time
            if secondsFromMidnight < lastPeriodEndTime {
                let afterSchoolPeriod: SchedulePeriod = SchedulePeriod()
                
                afterSchoolPeriod.isAfterSchool = true
                afterSchoolPeriod.startSeconds = lastPeriodEndTime
                afterSchoolPeriod.endSeconds = lastPeriodEndTime + 10 * 60 //10 mins after
                afterSchoolPeriod.name = "Get to the buses!"
                
                return afterSchoolPeriod
            }
        }
        
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
                    self.syncPeriodsToSchedule(modifiedSchedule)
                    return modifiedSchedule
                }
            }
        }
        
        //Function hasnt returned, thus it is a static schedule
        //Determine if it's a weekday (otherwise there is no schedule)
        let weekday = selDateComponents.weekday
        var schoolWeekday = 0
        switch weekday {
        case 1:
            schoolWeekday = 6
        case 2:
            schoolWeekday = 0
        case 3:
            schoolWeekday = 1
        case 4:
            schoolWeekday = 2
        case 5:
            schoolWeekday = 3
        case 6:
            schoolWeekday = 4
        case 7:
            schoolWeekday = 5
        default:
            break
        }
        if schoolWeekday >= 0 && schoolWeekday <= 4 {
            //It's a weekday
            //Return the corresponding static schedule
            for staticSchedule in staticSchedules {
                if staticSchedule.weekday == schoolWeekday {
                    self.syncPeriodsToSchedule(staticSchedule)
                    return staticSchedule
                }
                
            }
        }
        
        //Assume there's no available schedule (most likely it's a weekend)
        return nil
    }
    
    func syncPeriodsToSchedule(schedule: Schedule) {
        //this separate function is needed b/c we want to assign real periods AFTER everything is setup from Realm/Network
        for schedulePeriod in schedule.periods {
            schedulePeriod.realPeriod = self.getRealPeriod(fromSchedulePeriod: schedulePeriod)
            
        }
    }
    
    // Returns a period object based off a schedulePeriod object
    func getRealPeriod(fromSchedulePeriod schedulePeriod: SchedulePeriod) -> RealmPeriod? {
        if UserManager.sharedInstance != nil {
            print("user manager not nil")
            let userSchedule = UserManager.sharedInstance!.currentUser.schedule
            
            //Loop through the periods in the user schedule
            //Check them against the inputted schedule period
            for userPeriod in userSchedule! {
                if userPeriod.periodNumber == schedulePeriod.id {
                    print("found user period")
                    let realmPeriod = RealmPeriod()
                    realmPeriod.setPeriod(period: userPeriod)
                    return realmPeriod
                }
            }
            
        }
        
        //Period doesn't appear to exist in the user's schedule
        return nil
    }
    
    func getLunchNumber(withDate date: NSDate, andLunchType lunchtype: LunchType) -> Int? {
        let month = NSCalendar.currentCalendar().component(.Month, fromDate: date)
        
        for lunchSchedule in self.lunchSchedules {
            if (lunchSchedule.monthNumber - 1 == month && lunchSchedule.lunchType == lunchtype) {
                return lunchSchedule.lunchNumber
            }
        }
        
        return nil
    }
    
}
