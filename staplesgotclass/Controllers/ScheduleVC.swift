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
    @IBOutlet var timeElapsedLabel: UILabel!
    @IBOutlet var percentDoneLabel: UILabel!
    @IBOutlet var currentPeriodNumberLabel: UILabel!
    @IBOutlet var currentPeriodTitleLabel: UILabel!
    
    var selectedSchedule: Schedule?
    var isCurrentSchedule = true
    
    var timer: NSTimer?
    
    var clockTimer: NSTimer?
    var periodTimer: NSTimer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let sweetBlue = UIColor(red:0.13, green:0.42, blue:0.81, alpha:1.0)
        
        //Turn off extra lines in the table view
        
        self.navigationController?.navigationBar.barTintColor = sweetBlue
        self.navigationController?.navigationBar.translucent = false
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "AppleSDGothicNeo-Medium", size: 17)!, NSForegroundColorAttributeName: UIColor.whiteColor()]
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        
        let swipeRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(ScheduleVC.changeDate(_:)))
        
        self.tableView.addGestureRecognizer(swipeRecognizer)
        
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
                if (DailyScheduleManager.sharedInstance?.currentSchedule?.isStatic == false) {
                    self.navigationItem.prompt = "Modified Schedule"
                }
                else {
                    self.navigationItem.prompt = nil
                }
                self.selectedSchedule = DailyScheduleManager.sharedInstance?.currentSchedule
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
        if DailyScheduleManager.sharedInstance != nil {
            DailyScheduleManager.sharedInstance!.currentPeriod = DailyScheduleManager.sharedInstance!.getCurrentPeriod()
            
            if self.periodTimer != nil {
                if self.periodTimer!.valid == true { self.periodTimer!.invalidate() }
            }
            
            if let currentPeriod = DailyScheduleManager.sharedInstance!.currentPeriod {
                if currentPeriod.isPassingTime || currentPeriod.isBeforeSchool {
                    
                    //If it's currently passing time the next real period event should come into play
                    //Will only set up the timer if a 'next period' is available
                    //i.e nothing will happen if the day is over
                    if let nextPeriod = DailyScheduleManager.sharedInstance!.getNextSchedulePeriodInSchedule() {
                        let timeIntervalUntilNextPeriodStart: Double = Double(nextPeriod.startSeconds - DailyScheduleManager.sharedInstance!.secondsFromMidnight())
                        
                        //Add in 1 second to the interval to ensure it's the start of a new period and nothing funky happens
                        self.periodTimer = NSTimer.scheduledTimerWithTimeInterval(timeIntervalUntilNextPeriodStart + 1.0, target: self, selector: #selector(ScheduleVC.setupPeriodTimer), userInfo: nil, repeats: false)
                    }
                    
                } else if !currentPeriod.isAfterSchool {
                    
                    //Next period event should be a passing time which occurs immediately after this period is over
                    let timeIntervalUntilNextPeriodStart: Double = Double(currentPeriod.endSeconds - DailyScheduleManager.sharedInstance!.secondsFromMidnight())
                    
                    //Add in 1 second to the interval to ensure it's the start of a new period and nothing funky happens
                    self.periodTimer = NSTimer.scheduledTimerWithTimeInterval(timeIntervalUntilNextPeriodStart + 1.0, target: self, selector: #selector(ScheduleVC.setupPeriodTimer), userInfo: nil, repeats: false)
                }
            }
            
            //This should be for the morning period
            if let nextPeriod = DailyScheduleManager.sharedInstance!.getNextSchedulePeriodInSchedule() {
                let timeIntervalUntilNextPeriodStart: Double = Double(nextPeriod.startSeconds - DailyScheduleManager.sharedInstance!.secondsFromMidnight())
                
                //Add in 1 second to the interval to ensure it's the start of a new period and nothing funky happens
                self.periodTimer = NSTimer.scheduledTimerWithTimeInterval(timeIntervalUntilNextPeriodStart + 1.0, target: self, selector: #selector(ScheduleVC.setupPeriodTimer), userInfo: nil, repeats: false)
            }
        }
    }
    
    func clock() {
        if DailyScheduleManager.sharedInstance != nil {
            if let currentPeriod = DailyScheduleManager.sharedInstance!.currentPeriod {
                //Update the countdown label and UI components
                let timeRemainingInPeriod = currentPeriod.endSeconds - DailyScheduleManager.sharedInstance!.secondsFromMidnight()
                //TODO: UPDATE THE LABELS AND UI COMPONENTS HERE BASED ON timeRemainingInPeriod
                let timeElapsedInPeriod = DailyScheduleManager.sharedInstance!.secondsFromMidnight() - currentPeriod.startSeconds
                
                let percentDone = (timeElapsedInPeriod)/(currentPeriod.endSeconds - currentPeriod.startSeconds)
                
                self.timeRemainingLabel.text = Double(timeRemainingInPeriod).stringFromTimeInterval() as String
                
                self.timeElapsedLabel.text = Double(timeElapsedInPeriod).stringFromTimeInterval() as String
                
                    self.timeLeftRing.animateToAngle(Double(360*percentDone), duration: 0.1, completion: { (success: Bool) in
                        if (success) {
                            //progress ring successfully animated
                        }
                    })
            }
        }
    }
    
    func changeDate(sender: UISwipeGestureRecognizer) {
        
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        if (self.isCurrentSchedule == true) {
            return 2
        }
        else {
            return 1
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (self.isCurrentSchedule == true) {
            if (section == 0) {
                return "Up Next"
            }
            else {
                return "Schedule"
            }
        }
        else {
            return "Schedule"
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (self.isCurrentSchedule == true) {
            if (section == 0) {
                return 1
            }
            else {
                return (DailyScheduleManager.sharedInstance?.currentSchedule?.periods.count)!
            }
        }
        else {
            return (self.selectedSchedule?.periods.count)!
        }
        
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("scheduleCell", forIndexPath: indexPath) as! ClassCell
        
        
        
        
        return cell
    }
    
    
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
