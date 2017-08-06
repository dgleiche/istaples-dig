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
    
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, M/d"
        let dateString = dateFormatter.string(from: Date())
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
            for (index, period) in (WatchAppDailyScheduleManager.sharedInstance.currentSchedule?.periods.enumerated())! {
                let row = scheduleTable.rowController(at: index) as! ScheduleCell
                if let realPeriod = period.realPeriod {
                    row.classTitleLabel.setText(realPeriod.name)
                    row.periodNumberLabel.setText("\(realPeriod.periodNumber)")
                }
                else {
                    row.classTitleLabel.setText(period.name)
                    row.periodNumberLabel.setText("\(period.name!.characters.first!)")
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
                    row.periodNumberLabel.setTextColor(UIColor.lightGray)
                }
                else if (period == WatchAppDailyScheduleManager.sharedInstance.currentPeriod) {
                    row.periodNumberLabel.setTextColor(UIColor.green)
                }
            }
        }
        else {
            scheduleTable.removeRows(at: IndexSet(integersIn: NSRange(location: 0, length: scheduleTable.numberOfRows).toRange() ?? 0..<0))
        }
    }
    
    override func contextForSegue(withIdentifier segueIdentifier: String, in table: WKInterfaceTable, rowIndex: Int) -> Any? {
        print("context segue called")
        if (segueIdentifier == "scheduleDetailSegue") {
            print("current segue")
        if let selectedPeriod = WatchAppDailyScheduleManager.sharedInstance.currentSchedule?.periods[rowIndex] {
            if (selectedPeriod.realPeriod != nil) {
                let context: AnyObject = selectedPeriod as AnyObject
                print("presenting vc")
                self.presentController(withName: "scheduleDetailVC", context: context)
                return context
            }
        }
        }
        return nil
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        print("selected row")
    }
    
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
}
