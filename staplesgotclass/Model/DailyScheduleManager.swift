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
    func didFetchSchedules(_ success: Bool)
    func signInUser()
    func showErrorAlert()
}

class DailyScheduleManager: NSObject {
    static var sharedInstance: DailyScheduleManager?
    var currentSchedule: Schedule?
    
    var currentPeriod: SchedulePeriod?
    
    var fetchInProgress = false
    
    var modifiedSchedules = [Schedule]()
    var staticSchedules = [Schedule]()
    var lunchSchedules = [LunchSchedule]()
    var blockDays = [BlockDay]()
    var courses = [Course]()
    var realmPeriods = [RealmPeriod]()
    var currentUser: RealmUser?
    
    var realmPeriodsToDelete: [RealmPeriod]?
    
    var currentQuarter = 1
    
    let realm = try! Realm()
    
    weak var delegate:DailyScheduleManagerDelegate!
    
    fileprivate init(delegate: DailyScheduleManagerDelegate) {
        self.delegate = delegate
        super.init()
        DailyScheduleManager.sharedInstance = self
        
        self.loadSavedData()
    }
    
    class func destroy() {
        self.sharedInstance = nil
        UserManager.destroy()
    }
    
    class func setup(_ delegate: DailyScheduleManagerDelegate) {
        DailyScheduleManager.sharedInstance = DailyScheduleManager(delegate: delegate)
    }
    
    func loadSavedData() {
        print("loading saved data")
        self.modifiedSchedules = Array(realm.objects(Schedule.self).filter("isStatic == false"))
        self.staticSchedules = Array(realm.objects(Schedule.self).filter("isStatic == true"))
        self.lunchSchedules = Array(realm.objects(LunchSchedule.self))
        self.blockDays = Array(realm.objects(BlockDay.self))
        self.courses = Array(realm.objects(Course.self))
        self.currentUser = realm.objects(RealmUser.self).first
        print("mod schedules count: \(self.modifiedSchedules.count)")
        print("static schedules count: \(self.staticSchedules.count)")
        print("lunch schedules count: \(self.lunchSchedules.count)")
        print("block days count: \(self.blockDays.count)")
        print("courses  count: \(self.courses.count)")
        //        print("current user  count: \(self.currentUser)")
        
        print("getting current config")
        if let currentQ = PFConfig.current().object(forKey: "currentQuarter") as? Int {
            self.currentQuarter = currentQ
        }
        
        if (modifiedSchedules.count > 0 && lunchSchedules.count > 0 && currentUser != nil) {
            print("realm objects found")
            self.delegate.didFetchSchedules(true)
            return
        }
        else if (currentUser == nil) {
            print("current user nil")
        }
        print("calling sign in user")
        self.delegate.signInUser()
    }
    
    func getDailySchedule() {
        let query = PFQuery(className: "Schedule")
        query.limit = 500
        query.includeKey("Periods")
        query.findObjectsInBackground { (schedules: [PFObject]?, error: Error?) in
            if (error == nil) {                
                let schedulesToDelete = self.realm.objects(Schedule.self)
                let schedulePeriodsToDelete = self.realm.objects(SchedulePeriod.self)
                
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
                    if let modifiedDate = schedule["ModifiedDate"] as? Date {
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
                lunchQuery.limit = 500
                lunchQuery.includeKey("LunchType")
                
                lunchQuery.findObjectsInBackground(block: { (lunchSchedules: [PFObject]?, lunchError: Error?) in
                    if (lunchError == nil) {
                        let lunchSchedulesToDelete = self.realm.objects(LunchSchedule.self)
                        let lunchTypesToDelete = self.realm.objects(LunchType.self)
                        let coursesToDelete = self.realm.objects(Course.self)
                        
                        self.lunchSchedules.removeAll()
                        self.courses.removeAll()
                        
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
                        courseQuery.limit = 500
                        courseQuery.includeKey("LunchType")
                        courseQuery.findObjectsInBackground(block: { (courses: [PFObject]?, courseError: Error?) in
                            if (courseError == nil) {
                                for course in courses! {
                                    let newCourse = Course()
                                    let newLunchType = LunchType()
                                    if let lunchType = course["LunchType"] as? PFObject {
                                        newLunchType.name = lunchType["Name"] as? String
                                        if let isLab = lunchType["Lab"] as? Bool {
                                            newLunchType.isLab = isLab
                                        }
                                    }
                                    newCourse.lunchType = newLunchType
                                    newCourse.name = course["Name"] as? String
                                    self.courses.append(newCourse)
                                }
                                
                                let blockQuery = PFQuery(className: "BlockRotation")
                                blockQuery.limit = 500
                                
                                blockQuery.findObjectsInBackground(block: { (blockRotations: [PFObject]?, blockError: Error?) in
                                    if (blockError == nil) {
                                        let blockDaysToDelete = self.realm.objects(BlockDay.self)
                                        self.blockDays.removeAll()
                                        for blockRotation in blockRotations! {
                                            if (blockRotation["title"] as! String) != "X" {
                                                let newBlockDay = BlockDay()
                                                newBlockDay.date = blockRotation["date"] as? Date
                                                newBlockDay.title = blockRotation["title"] as? String
                                                self.blockDays.append(newBlockDay)
                                            }
                                        }
                                        PFConfig.getInBackground{(fetchedConfig: PFConfig?, error: Error?) -> Void in
                                            var config: PFConfig?
                                            if (error == nil) {
                                                config = fetchedConfig
                                            }
                                            else {
                                                config = PFConfig.current()
                                            }
                                            
                                            if (config != nil) {
                                                if let currentQ = config!["currentQuarter"] as? Int {
                                                    self.currentQuarter = currentQ
                                                }
                                            }
                                            
                                            try! self.realm.write {
                                                if (self.realmPeriodsToDelete != nil) {
                                                    self.realm.delete(self.realmPeriodsToDelete!)
                                                }
                                                
                                                self.realm.delete(schedulesToDelete)
                                                self.realm.delete(schedulePeriodsToDelete)
                                                
                                                self.realm.delete(lunchSchedulesToDelete)
                                                self.realm.delete(lunchTypesToDelete)
                                                self.realm.delete(coursesToDelete)
                                                
                                                self.realm.delete(blockDaysToDelete)
                                                
                                                self.realm.add(self.staticSchedules)
                                                self.realm.add(self.modifiedSchedules)
                                                self.realm.add(self.lunchSchedules)
                                                self.realm.add(self.courses)
                                                self.realm.add(self.blockDays)
                                                
                                                print("mod schedules count: \(self.modifiedSchedules.count)")
                                                print("static schedules count: \(self.staticSchedules.count)")
                                                print("lunch schedules count: \(self.lunchSchedules.count)")
                                                print("block days count: \(self.blockDays.count)")
                                                print("courses  count: \(self.courses.count)")
                                            }
                                            self.delegate.didFetchSchedules(false)
                                        }
                                    }
                                    else {
                                        self.delegate.showErrorAlert()
                                    }
                                    
                                })
                                
                            }
                            else {
                                self.delegate.showErrorAlert()
                                
                            }
                            
                        })
                        
                    }
                    else {
                        self.delegate.showErrorAlert()
                    }
                })
            }
        }
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
                    beforeSchoolPeriod.name = "Passing Time"
                    
                    return beforeSchoolPeriod
                    
                }
            }
            
            //If it's still within ten minutes of the last period, we have the bus passing time thing
            if abs(secondsFromMidnight - passingTimeStart) < 10 * 60 && passingTimeStart != 0 {
                let afterSchoolPeriod: SchedulePeriod = SchedulePeriod()
                
                afterSchoolPeriod.isAfterSchool = true
                afterSchoolPeriod.startSeconds = passingTimeStart
                afterSchoolPeriod.endSeconds = passingTimeStart + 10 * 60 //10 mins after
                afterSchoolPeriod.name = "Buses Leaving"
                
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
                
                //If the before school period has already started, return the first period in the day
                if secondsFromMidnight > period.startSeconds - (10 * 60) {
                    return period
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
        let calendar = Calendar.current
        _ = Set<Calendar.Component>([.hour, .minute, .second])
        let components = calendar.dateComponents([.hour,.minute,.second], from: Date())
        return (60 * 60 * components.hour!) + (60 * components.minute!) + components.second!
    }
    
    func getSchedule(withDate date: Date) -> Schedule? {
        
        let calendar = Calendar.current
        let selDateComponents = calendar.dateComponents([.day, .month, .weekday], from: date as Date)
        
        for modifiedSchedule in modifiedSchedules {
            if let modDate = modifiedSchedule.modifiedDate {
                let modDateComponents = calendar.dateComponents([.day, .month], from: modDate)
                
                if (modDateComponents.month == selDateComponents.month) && (modDateComponents.day == selDateComponents.day) {
                    //Month and day exactly match, thus this date corresponds with a modified schedule
                    self.syncPeriodsToSchedule(modifiedSchedule, withDate: date as Date)
                    return modifiedSchedule
                }
            }
        }
        
        //FIND CURRENT BLOCK SCHEDULE
        for blockDay in blockDays {
            if let blockDate = blockDay.date {
                let blockDateComponents = calendar.dateComponents([.day, .month], from: blockDate)
                
                if (blockDateComponents.month == selDateComponents.month) && (blockDateComponents.day == selDateComponents.day) {
                    //Month and day exactly match, thus this date corresponds with a modified schedule
                    print("found current schedule: \(blockDay.title!)")
                    let currentStaticSchedule = realm.objects(Schedule.self).filter("name=='\(blockDay.title!)'")[0]
                    self.syncPeriodsToSchedule(currentStaticSchedule, withDate: date as Date)
                    return currentStaticSchedule
                }
            }
        }
        
        //Assume there's no available schedule (most likely it's a weekend)
        return nil
    }
    
    func syncPeriodsToSchedule(_ schedule: Schedule, withDate date: Date) {
        //this separate function is needed b/c we want to assign realm periods AFTER everything is setup from Realm/Network
        for schedulePeriod in schedule.periods {
            try! self.realm.write {
                schedulePeriod.realPeriod = self.getRealPeriod(fromSchedulePeriod: schedulePeriod)
                
                let realPeriodStartTime = schedulePeriod.startSeconds
                let realPeriodEndTime = schedulePeriod.endSeconds
                let passingTime = 5*60
                
                if (schedulePeriod.isLunch && schedulePeriod.realPeriod != nil) {
                    //                    print("real not nil")
                    //get current lunch number
                    if let lunchType = self.getLunchType(forPeriod: self.getRealPeriod(fromSchedulePeriod: schedulePeriod)!) {
                        schedulePeriod.lunchType = lunchType
                        
                        let lunchLength = (lunchType.isLab) ? 15*60 : 30*60
                        
                        if let lunchNumber = getLunchNumber(withDate: date, andLunchType: lunchType) {
                            if (!schedule.containsLunchPeriods()) {
                                switch lunchNumber {
                                case 1:
                                    //Lunch, long period
                                    let firstLunchPeriod = self.realm.create(SchedulePeriod.self, value: schedulePeriod, update: false)
                                    let updatedFirstLunchPeriod = self.createLunchPeriod(withInitialPeriod: firstLunchPeriod, startTime: realPeriodStartTime, endTime: realPeriodStartTime + lunchLength, isLunch: true)
                                    updatedFirstLunchPeriod.lunchNumber = 1
                                    schedule.periods.insert(updatedFirstLunchPeriod, at: schedule.periods.index(of: schedulePeriod)!)
                                    schedulePeriod.startSeconds = realPeriodStartTime + lunchLength + passingTime
                                    
                                case 2:
                                    //Short period, lunch, short period
                                    //Set the original schedule period to be the first period
                                    
                                    let periodLength = (((realPeriodEndTime - realPeriodStartTime) - lunchLength - passingTime*2) / 2)
                                    schedulePeriod.endSeconds = realPeriodStartTime + periodLength
                                    schedulePeriod.lunchNumber = 1
                                    let newFirstSecondLunchPeriod = self.realm.create(SchedulePeriod.self, value: schedulePeriod, update: false)
                                    let updatedFirstSecondLunchPeriod = self.createLunchPeriod(withInitialPeriod: newFirstSecondLunchPeriod, startTime: realPeriodStartTime + periodLength + passingTime, endTime: realPeriodStartTime + periodLength + passingTime + lunchLength, isLunch: true)
                                    updatedFirstSecondLunchPeriod.lunchNumber = 2
                                    schedule.periods.insert(updatedFirstSecondLunchPeriod, at: schedule.periods.index(of: schedulePeriod)!+1)
                                    
                                    let newSecondSecondLunchPeriod = self.realm.create(SchedulePeriod.self, value: schedulePeriod, update: false)
                                    let updatedSecondSecondLunchPeriod = self.createLunchPeriod(withInitialPeriod: newSecondSecondLunchPeriod, startTime: realPeriodStartTime + periodLength + passingTime + lunchLength + passingTime, endTime: realPeriodEndTime, isLunch: false)
                                    updatedSecondSecondLunchPeriod.lunchNumber = 3
                                    schedule.periods.insert(updatedSecondSecondLunchPeriod, at: schedule.periods.index(of: schedulePeriod)!+2)
                                    
                                case 3:
                                    //Long period, lunch
                                    schedulePeriod.endSeconds = realPeriodEndTime - lunchLength - passingTime
                                    
                                    let newThirdLunchPeriod = self.realm.create(SchedulePeriod.self, value: schedulePeriod, update: false)
                                    let updatedThirdLunchPeriod = createLunchPeriod(withInitialPeriod:newThirdLunchPeriod, startTime: realPeriodEndTime - lunchLength, endTime: realPeriodEndTime, isLunch: true)
                                    updatedThirdLunchPeriod.lunchNumber = 3
                                    schedule.periods.insert(updatedThirdLunchPeriod, at: schedule.periods.index(of: schedulePeriod)!+1)
                                default:
                                    print("INVALID LUNCH NUMBER")
                                }
                            }
                        }
                        
                    }
                    else {
                        //NO LUNCH TYPE, FREE LUNCH
                        print("no lunch type for \(String(describing: schedulePeriod.name))")
                        if (!schedule.containsLunchPeriods()) {
                            let lunchLength = 30*60
                            let periodLength = (((realPeriodEndTime - realPeriodStartTime) - lunchLength - passingTime*2) / 2)
                            schedulePeriod.endSeconds = realPeriodStartTime + periodLength
                            schedulePeriod.isLunchPeriod = true
                            schedulePeriod.lunchNumber = 1
                            
                            let newSecondLunchPeriod = self.realm.create(SchedulePeriod.self, value: schedulePeriod, update: false)
                            let updatedSecondLunchPeriod = self.createLunchPeriod(withInitialPeriod: newSecondLunchPeriod, startTime: realPeriodStartTime + periodLength + passingTime, endTime: realPeriodStartTime + periodLength + passingTime + lunchLength, isLunch: true)
                            updatedSecondLunchPeriod.lunchNumber = 2
                            schedule.periods.insert(updatedSecondLunchPeriod, at: schedule.periods.index(of: schedulePeriod)!+1)
                            
                            let newThirdLunchPeriod = self.realm.create(SchedulePeriod.self, value: schedulePeriod, update: false)
                            let updatedThirdLunchPeriod = self.createLunchPeriod(withInitialPeriod: newThirdLunchPeriod, startTime: realPeriodStartTime + periodLength + passingTime + lunchLength + passingTime, endTime: realPeriodEndTime, isLunch: true)
                            updatedThirdLunchPeriod.lunchNumber = 3
                            
                            schedule.periods.insert(updatedThirdLunchPeriod, at: schedule.periods.index(of: schedulePeriod)!+2)
                        }
                    }
                    
                }
                else if (schedulePeriod.isLunch) {
                    //no real period but still show lunch
                    if (!schedule.containsLunchPeriods()) {
                        let lunchLength = 30*60
                        let periodLength = (((realPeriodEndTime - realPeriodStartTime) - lunchLength - passingTime*2) / 2)
                        schedulePeriod.endSeconds = realPeriodStartTime + periodLength
                        schedulePeriod.isLunchPeriod = true
                        schedulePeriod.lunchNumber = 1
                        
                        let newSecondLunchPeriod = self.realm.create(SchedulePeriod.self, value: schedulePeriod, update: false)
                        let updatedSecondLunchPeriod = self.createLunchPeriod(withInitialPeriod: newSecondLunchPeriod, startTime: realPeriodStartTime + periodLength + passingTime, endTime: realPeriodStartTime + periodLength + passingTime + lunchLength, isLunch: true)
                        updatedSecondLunchPeriod.lunchNumber = 2
                        schedule.periods.insert(updatedSecondLunchPeriod, at: schedule.periods.index(of: schedulePeriod)!+1)
                        
                        let newThirdLunchPeriod = self.realm.create(SchedulePeriod.self, value: schedulePeriod, update: false)
                        let updatedThirdLunchPeriod = self.createLunchPeriod(withInitialPeriod: newThirdLunchPeriod, startTime: realPeriodStartTime + periodLength + passingTime + lunchLength + passingTime, endTime: realPeriodEndTime, isLunch: true)
                        updatedThirdLunchPeriod.lunchNumber = 3
                        
                        schedule.periods.insert(updatedThirdLunchPeriod, at: schedule.periods.index(of: schedulePeriod)!+2)
                    }
                }
            }
        }
    }
    
    func createLunchPeriod(withInitialPeriod initialPeriod: SchedulePeriod, startTime: Int, endTime: Int, isLunch: Bool) -> SchedulePeriod {
        initialPeriod.startSeconds = startTime
        initialPeriod.endSeconds = endTime
        initialPeriod.isLunchPeriod = isLunch
        return initialPeriod
    }
    
    // Returns a period object based off a schedulePeriod object
    func getRealPeriod(fromSchedulePeriod schedulePeriod: SchedulePeriod) -> RealmPeriod? {
        if self.currentUser != nil {
            let userSchedule = self.currentUser?.schedule
            //Loop through the periods in the user schedule
            //Check them against the inputted schedule period
            if (userSchedule != nil) {
                for userPeriod in userSchedule! {
                    if ((userPeriod.periodNumber == schedulePeriod.id) && (userPeriod.quarters?.contains("\(self.currentQuarter)"))!) {
                        return userPeriod
                    }
                }
            }
            
        }
        
        //Period doesn't appear to exist in the user's schedule
        return nil
    }
    
    func getLunchType(forPeriod period: RealmPeriod) -> LunchType? {
        for course in self.courses {
            if (course.name == period.name && course.lunchType?.name != nil) {
                return course.lunchType
            }
        }
        return nil
    }
    
    func getLunchNumber(withDate date: Date, andLunchType lunchtype: LunchType) -> Int? {
        let month = (Calendar.current as NSCalendar).component(.month, from: date)
        for lunchSchedule in self.lunchSchedules {
            if let lunchTypeInSchedule = lunchSchedule.lunchType {
                if (lunchSchedule.monthNumber == month - 1) && (lunchTypeInSchedule.name == lunchtype.name) {
                    return lunchSchedule.lunchNumber
                }
            }
        }
        
        return nil
    }
    
}
