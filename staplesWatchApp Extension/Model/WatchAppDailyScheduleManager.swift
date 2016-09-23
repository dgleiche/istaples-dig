//
//  WatchAppDailyScheduleManager.swift
//  staplesgotclass
//
//  Created by Dylan Diamond on 9/5/16.
//  Copyright © 2016 Dylan Diamond. All rights reserved.
//

import UIKit

class WatchAppDailyScheduleManager: NSObject {
    static var sharedInstance = WatchAppDailyScheduleManager()
    var currentSchedule: WatchSchedule?
    var scheduleSet = false
    var currentPeriod: WatchSchedulePeriod?
    
    var fetchInProgress = false
    
    private override init() {
        super.init()
    }
    
    func getCurrentPeriod() -> WatchSchedulePeriod? {
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
                    let passingTimePeriod: WatchSchedulePeriod = WatchSchedulePeriod()
                    
                    passingTimePeriod.isPassingTime = true
                    passingTimePeriod.startSeconds = passingTimeStart
                    passingTimePeriod.endSeconds = (getNextSchedulePeriodInSchedule()?.startSeconds)! //keep passing time until next period starts, DYLAN CHECK TO MAKE SURE THIS WORKS
                    passingTimePeriod.name = "Passing Time"
                    
                    return passingTimePeriod
                    
                } else if abs(secondsFromMidnight - period.startSeconds) < 10 * 60 {
                    //Ten minutes before school
                    let beforeSchoolPeriod: WatchSchedulePeriod = WatchSchedulePeriod()
                    
                    beforeSchoolPeriod.isBeforeSchool = true
                    beforeSchoolPeriod.startSeconds = period.startSeconds - (10 * 60) //10 mins before
                    beforeSchoolPeriod.endSeconds = period.startSeconds
                    beforeSchoolPeriod.name = "Passing Time"
                    
                    return beforeSchoolPeriod
                    
                }
            }
            
            //If it's still within ten minutes of the last period, we have the bus passing time thing
            if abs(secondsFromMidnight - passingTimeStart) < 10 * 60 && passingTimeStart != 0 {
                let afterSchoolPeriod: WatchSchedulePeriod = WatchSchedulePeriod()
                
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
    func getNextSchedulePeriodInSchedule() -> WatchSchedulePeriod? {
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
                    let beforeSchoolPeriod: WatchSchedulePeriod = WatchSchedulePeriod()
                    
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
                let afterSchoolPeriod: WatchSchedulePeriod = WatchSchedulePeriod()
                
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
    
}
