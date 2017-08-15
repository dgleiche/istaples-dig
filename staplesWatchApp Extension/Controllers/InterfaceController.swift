//
//  InterfaceController.swift
//  staplesWatchApp Extension
//
//  Created by Dylan Diamond on 9/5/16.
//  Copyright © 2016 Dylan Diamond. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {
    @IBOutlet var group: WKInterfaceGroup!
    @IBOutlet var timerGroup: WKInterfaceGroup!
    
    @IBOutlet var headerLabel: WKInterfaceLabel!
    @IBOutlet var periodLabel: WKInterfaceLabel!
    @IBOutlet var timerOut: WKInterfaceTimer!
    @IBOutlet var timer: WKInterfaceTimer!
    
    var periodTimer: Timer?
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        NotificationCenter.default.addObserver(self, selector: #selector(InterfaceController.setupPeriodTimer), name: NSNotification.Name(rawValue: "scheduleReceived"), object: nil)
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        self.setupPeriodTimer()
    }
    
    func setup() {
        if (WatchAppDailyScheduleManager.sharedInstance.currentSchedule != nil) {
            //current schedule not nil, weekday
            if let currentPeriod = WatchAppDailyScheduleManager.sharedInstance.currentPeriod {
                self.timerGroup.setHidden(false)
                self.headerLabel.setHidden(true)
                self.group.setBackgroundImageNamed("single")
                
                if (currentPeriod.realPeriod != nil) {
                    self.periodLabel.setText("\(currentPeriod.name!) - \(currentPeriod.realPeriod!.name!)")
                }
                else {
                    self.periodLabel.setText(currentPeriod.name!)
                }
                
                let date = Date()
                let cal = Calendar(identifier: Calendar.Identifier.gregorian)
                let newDate = cal.startOfDay(for: date)
                let startDate = Date(timeInterval: TimeInterval(currentPeriod.startSeconds), since: newDate)
                let endDate = Date(timeInterval: TimeInterval(currentPeriod.endSeconds), since: newDate)
                
                self.timer.setDate(startDate)
                self.timerOut.setDate(endDate)
                self.timerOut.start()
                self.timer.start()
                
                let timeElapsedInPeriod = WatchAppDailyScheduleManager.sharedInstance.secondsFromMidnight() - currentPeriod.startSeconds
                let timeRemainingInPeriod = currentPeriod.endSeconds - WatchAppDailyScheduleManager.sharedInstance.secondsFromMidnight()
                
                let percentDone = Double(timeElapsedInPeriod)/Double(currentPeriod.endSeconds - currentPeriod.startSeconds)
                print("percent done: \(percentDone)")
                
                self.group.startAnimatingWithImages(in: NSMakeRange(Int(percentDone * 100), 101), duration: TimeInterval(timeRemainingInPeriod), repeatCount: 0)
                
            }
            else {
                //no current period, school not in session
                self.headerLabel.setText("school not in session")
                self.timerGroup.setHidden(true)
                self.group.setBackgroundImage(nil)
                self.headerLabel.setHidden(false)
                self.periodLabel.setText("--")
            }
        }
        else {
            //weekend or no school
            if (WatchAppDailyScheduleManager.sharedInstance.scheduleSet) {
                let calendar = Calendar.current
                let currentDateComponents = calendar.dateComponents([.day, .month, .weekday], from: Date())
                let weekday = currentDateComponents.weekday!
                print("weekday: \(String(describing: weekday))")
                if (weekday == 7 || weekday == 1) {
                self.headerLabel.setText("enjoy the weekend!")
                }
                else {
                    self.headerLabel.setText("no school!")
                }
            }
            else {
                self.headerLabel.setText("loading schedule")
            }
            self.timerGroup.setHidden(true)
            self.group.setBackgroundImage(nil)
            self.headerLabel.setHidden(false)
            self.periodLabel.setText("--")
        }
        
    }
    
    func setupPeriodTimer() {
        print("setup period timer called")
        if (WatchAppDailyScheduleManager.sharedInstance.currentSchedule != nil) {
            WatchAppDailyScheduleManager.sharedInstance.currentPeriod = WatchAppDailyScheduleManager.sharedInstance.getCurrentPeriod()
            self.setup()
            if self.periodTimer != nil {
                if self.periodTimer!.isValid == true { self.periodTimer!.invalidate() }
            }
            
            if let currentPeriod = WatchAppDailyScheduleManager.sharedInstance.currentPeriod {
                //Next period event should be a passing time which occurs immediately after this period is over
                let timeIntervalUntilNextPeriodStart: Double = Double(currentPeriod.endSeconds - WatchAppDailyScheduleManager.sharedInstance.secondsFromMidnight())
                
                self.periodTimer = Timer.scheduledTimer(timeInterval: timeIntervalUntilNextPeriodStart + 1, target: self, selector: #selector(InterfaceController.setupPeriodTimer), userInfo: nil, repeats: false)
            }
            else {
                //no current period, hide status bar
                
                //This should be for the morning period
                if let nextPeriod = WatchAppDailyScheduleManager.sharedInstance.getNextSchedulePeriodInSchedule() {
                    //Currently before ten mins before morning
                    
                    let timeIntervalUntilNextPeriodStart: Double = Double(nextPeriod.startSeconds - WatchAppDailyScheduleManager.sharedInstance.secondsFromMidnight())
                    
                    self.periodTimer = Timer.scheduledTimer(timeInterval: timeIntervalUntilNextPeriodStart, target: self, selector: #selector(InterfaceController.setupPeriodTimer), userInfo: nil, repeats: false)
                }
            }
            
            if (self.periodTimer != nil) {
                RunLoop.main.add(self.periodTimer!, forMode: RunLoopMode.commonModes)
            }
            
        } else {
            //No schedule set
            self.setup()
        }
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
}
