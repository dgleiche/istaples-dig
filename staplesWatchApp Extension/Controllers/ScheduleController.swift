//
//  ScheduleController.swift
//  staplesgotclass
//
//  Created by Dylan Diamond on 9/5/16.
//  Copyright © 2016 Dylan Diamond. All rights reserved.
//

import WatchKit
import Foundation


class ScheduleController: WKInterfaceController {
    
    @IBOutlet var dateLabel: WKInterfaceLabel!
    @IBOutlet var scheduleTable: WKInterfaceTable!
    
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        let dateFormatter: NSDateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EEEE, M/d"
        let dateString = dateFormatter.stringFromDate(NSDate())
        self.dateLabel.setText(dateString)
        self.loadTable()
    }
    
    override init() {
        super.init()
        loadTable()
    }
    
    func loadTable() {
        if (WatchAppDailyScheduleManager.sharedInstance.currentSchedule != nil) {
            scheduleTable.setNumberOfRows((WatchAppDailyScheduleManager.sharedInstance.currentSchedule?.periods.count)!, withRowType: "ScheduleCell")
            for (index, period) in (WatchAppDailyScheduleManager.sharedInstance.currentSchedule?.periods.enumerate())! {
                let row = scheduleTable.rowControllerAtIndex(index) as! ScheduleCell
                if let realPeriod = period.realPeriod {
                    row.classTitleLabel.setText(realPeriod.name)
                    row.periodNumberLabel.setText("\(realPeriod.periodNumber)")
                }
                else {
                    row.classTitleLabel.setText(period.name)
                    row.periodNumberLabel.setText("\(period.name!.characters.first)")
                }
                row.timeLabel.setText("\(period.startSeconds.printSecondsToHoursMinutesSeconds())-\(period.endSeconds.printSecondsToHoursMinutesSeconds())")
                if (period.isLunch) {
                    row.lunchWaveLabel.setText("\(period.lunchNumber)")
                    if (period.isLunchPeriod) {
                        row.classTitleLabel.setText("Lunch")
                    }
                }
                else {
                    row.lunchWaveLabel.setText(nil)
                }
                
                if (period.endSeconds < WatchAppDailyScheduleManager.sharedInstance.secondsFromMidnight()) {
                    //period already passed
                    row.periodNumberLabel.setTextColor(UIColor.lightGrayColor())
                }
                else if (period == WatchAppDailyScheduleManager.sharedInstance.currentPeriod) {
                    row.periodNumberLabel.setTextColor(UIColor.greenColor())
                }
            }
        }
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
}
