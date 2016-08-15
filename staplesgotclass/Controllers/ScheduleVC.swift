//
//  ScheduleVC.swift
//  staplesgotclass
//
//  Created by Dylan Diamond on 8/11/16.
//  Copyright © 2016 Dylan Diamond. All rights reserved.
//

import UIKit

class ScheduleVC: UITableViewController, DailyScheduleManagerDelegate {
    @IBOutlet var timeLeftRing: KDCircularProgress!
    @IBOutlet var timeElapsedRing: KDCircularProgress!
    @IBOutlet var timeRemainingLabel: UILabel!
    
    var clockTimer: NSTimer?
    var periodTimer: NSTimer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DailyScheduleManager.setup(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Daily Schedule Manager Delegate Methods
    
    func didFetchSchedules(success: Bool) {
        print("delegate called")
        if DailyScheduleManager.sharedInstance != nil {
            print("schedules: \(DailyScheduleManager.sharedInstance?.staticSchedules)")
            DailyScheduleManager.sharedInstance?.currentSchedule = DailyScheduleManager.sharedInstance!.getSchedule(withDate: NSDate())
            print("current schedule: \(DailyScheduleManager.sharedInstance?.currentSchedule)")
            
            //Setup the current period
            DailyScheduleManager.sharedInstance?.currentPeriod = DailyScheduleManager.sharedInstance!.getCurrentPeriod()
            
            if (DailyScheduleManager.sharedInstance?.currentSchedule != nil) {
                //start timer if current schedule not nil
                self.setupClockTimer()
                self.setupPeriodTimer()
            }
        }
    }
    
    func setupClockTimer() {
        if self.clockTimer != nil {
            if self.clockTimer!.valid == true { self.clockTimer!.invalidate() }
        }
        
        self.clockTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(ScheduleVC.clock), userInfo: nil, repeats: true)
    }
    
    func setupPeriodTimer() {
        DailyScheduleManager.sharedInstance!.currentPeriod = DailyScheduleManager.sharedInstance!.getCurrentPeriod()
        
        if self.periodTimer != nil {
            if self.periodTimer!.valid == true { self.periodTimer!.invalidate() }
        }
        
        //Will only set up the timer if a 'next period' is available
        //i.e nothing will happen if the day is over
        if let nextPeriod = DailyScheduleManager.sharedInstance!.getNextRealPeriodInSchedule() {
            let timeIntervalUntilNextPeriodStart: Double = Double(nextPeriod.startSeconds - DailyScheduleManager.sharedInstance!.secondsFromMidnight())
    
            //Add in 1 second to the interval to ensure it's the start of a new period and nothing funky happens
            self.periodTimer = NSTimer.scheduledTimerWithTimeInterval(timeIntervalUntilNextPeriodStart + 1.0, target: self, selector: #selector(ScheduleVC.setupPeriodTimer), userInfo: nil, repeats: false)
        }
    }
    
    func clock() {
        if DailyScheduleManager.sharedInstance != nil {
            
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }
    
    /*
     override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
     let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)
     
     // Configure the cell...
     
     return cell
     }
     */
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
     if editingStyle == .Delete {
     // Delete the row from the data source
     tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
     } else if editingStyle == .Insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
