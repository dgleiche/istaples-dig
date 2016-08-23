//
//  ScheduleVC.swift
//  staplesgotclass
//
//  Created by Dylan Diamond on 8/11/16.
//  Copyright © 2016 Dylan Diamond. All rights reserved.
//

import UIKit
import RealmSwift

class ScheduleVC: UITableViewController, DailyScheduleManagerDelegate, GIDSignInDelegate {
    @IBOutlet var timeLeftRing: KDCircularProgress!
    @IBOutlet var timeElapsedRing: KDCircularProgress!
    @IBOutlet var timeRemainingLabel: UILabel!
    @IBOutlet var timeElapsedLabel: UILabel!
    @IBOutlet var percentDoneLabel: UILabel!
    @IBOutlet var currentPeriodNumberLabel: UILabel!
    @IBOutlet var currentPeriodTitleLabel: UILabel!
    
    var tableHeaderView: UIView!
    
    var selectedSchedule: Schedule?
    var isCurrentSchedule = true
    
    var timer: NSTimer?
    
    var clockTimer: NSTimer?
    var periodTimer: NSTimer?
    
    var spinnerSetup = false
    
    var firstSignInHasBeenAttempted = false
    var loadedOnline = false
    
    override func viewDidLoad() {
        tableHeaderView = tableView.tableHeaderView
        
        super.viewDidLoad()
        
        let sweetBlue = UIColor(red:0.13, green:0.42, blue:0.81, alpha:1.0)
        
        //Turn off extra lines in the table view
        
        self.navigationController?.navigationBar.barTintColor = sweetBlue
        self.navigationController?.navigationBar.translucent = false
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "AppleSDGothicNeo-Medium", size: 17)!, NSForegroundColorAttributeName: UIColor.whiteColor()]
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        
        self.timeLeftRing.angle = 0
        self.timeElapsedRing.angle = 360
        
        let swipeRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(ScheduleVC.changeDate(_:)))
        
        self.tableView.addGestureRecognizer(swipeRecognizer)
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ScheduleVC.callSetup), name: "loggedIn", object: nil)
        GIDSignIn.sharedInstance().delegate = self
        print("view did load setup")
        DailyScheduleManager.setup(self)
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if (self.loadedOnline) {
            //reload schedules in case of change, and go back to current schedule
            DailyScheduleManager.setup(self)
        }
        
        if !firstSignInHasBeenAttempted {
            
        }
            
        else {
            
        }
    }
    
    func callSetup() {
        print("calling setup")
        DailyScheduleManager.setup(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Daily Schedule Manager Delegate Methods
    
    func didFetchSchedules(offline: Bool) {
        print("delegate called")
        if DailyScheduleManager.sharedInstance != nil {
            print("staticScheduleCount: \(DailyScheduleManager.sharedInstance?.staticSchedules.count)")
            print("modScheduleCount: \(DailyScheduleManager.sharedInstance?.modifiedSchedules.count)")
            
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
        if (offline) {
            signInUser()
        }
        else {
            self.loadedOnline = true
        }
        
    }
    
    func signInUser() {
        if (GIDSignIn.sharedInstance().currentUser == nil) {
            GIDSignIn.sharedInstance().delegate = self
            print("no current user, sign in")
            GIDSignIn.sharedInstance().signInSilently()
        }
        else {
            self.getRealClassPeriods()
        }
    }
    
    func showErrorAlert() {
        let alert = UIAlertController(title: "Error loading schedules", message: "Please try again.", preferredStyle: .Alert)
        let ok = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(ok)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func logoutUser() {
        DailyScheduleManager.destroy()
        GIDSignIn.sharedInstance().delegate = nil
        GIDSignIn.sharedInstance().signOut()
        let loginPage = self.storyboard?.instantiateViewControllerWithIdentifier("loginVC") as! LoginVC
        self.tabBarController?.presentViewController(loginPage, animated: true, completion: nil)
    }
    
    func setupClockTimer() {
        if self.clockTimer != nil {
            if self.clockTimer!.valid == true { self.clockTimer!.invalidate() }
        }
        
        self.clockTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(ScheduleVC.clock), userInfo: nil, repeats: true)
        NSRunLoop.mainRunLoop().addTimer(self.clockTimer!, forMode: NSRunLoopCommonModes)
    }
    
    func setupPeriodTimer() { hidePeriodStatusBar()
        if DailyScheduleManager.sharedInstance != nil {
            DailyScheduleManager.sharedInstance!.currentPeriod = DailyScheduleManager.sharedInstance!.getCurrentPeriod()
            self.tableView.reloadData()
            
            if self.periodTimer != nil {
                if self.periodTimer!.valid == true { self.periodTimer!.invalidate() }
            }
            
            if let currentPeriod = DailyScheduleManager.sharedInstance!.currentPeriod {
                if tableView.tableHeaderView == nil {
                    //showPeriodStatusBar()
                }
                
                if currentPeriod.isPassingTime || currentPeriod.isBeforeSchool {
                    
                    //If it's currently passing time the next real period event should come into play
                    //Will only set up the timer if a 'next period' is available
                    //i.e nothing will happen if the day is over
                    if let nextPeriod = DailyScheduleManager.sharedInstance!.getNextSchedulePeriodInSchedule() {
                        let timeIntervalUntilNextPeriodStart: Double = Double(nextPeriod.startSeconds - DailyScheduleManager.sharedInstance!.secondsFromMidnight())
                        
                        //Add in 1 second to the interval to ensure it's the start of a new period and nothing funky happens
                        self.periodTimer = NSTimer.scheduledTimerWithTimeInterval(timeIntervalUntilNextPeriodStart + 1, target: self, selector: #selector(ScheduleVC.setupPeriodTimer), userInfo: nil, repeats: false)
                    }
                    
                } else if !currentPeriod.isAfterSchool {
                    
                    //Next period event should be a passing time which occurs immediately after this period is over
                    let timeIntervalUntilNextPeriodStart: Double = Double(currentPeriod.endSeconds - DailyScheduleManager.sharedInstance!.secondsFromMidnight())
                    
                    self.periodTimer = NSTimer.scheduledTimerWithTimeInterval(timeIntervalUntilNextPeriodStart + 1, target: self, selector: #selector(ScheduleVC.setupPeriodTimer), userInfo: nil, repeats: false)
                }
                else if currentPeriod.isAfterSchool {
                    ///DAY HAS ENDED
                    hidePeriodStatusBar()
                    print("day is now over")
                }
            }
            
            //This should be for the morning period
            else if let nextPeriod = DailyScheduleManager.sharedInstance!.getNextSchedulePeriodInSchedule() {
                //Currently before ten mins before morning
                hidePeriodStatusBar()
                
                let timeIntervalUntilNextPeriodStart: Double = Double(nextPeriod.startSeconds - DailyScheduleManager.sharedInstance!.secondsFromMidnight())
                
                self.periodTimer = NSTimer.scheduledTimerWithTimeInterval(timeIntervalUntilNextPeriodStart, target: self, selector: #selector(ScheduleVC.setupPeriodTimer), userInfo: nil, repeats: false)
            }
            
//            else if (DailyScheduleManager.sharedInstance?.currentSchedule != nil) {
//                //no current period so make timer call every 5 seconds to keep checking if there is one ONLY IF CURRENT SCHEDULE IS SET
//                
//                self.periodTimer = NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: #selector(ScheduleVC.setupPeriodTimer), userInfo: nil, repeats: false)
//                
//            }
            if (self.periodTimer != nil) {
                NSRunLoop.mainRunLoop().addTimer(self.periodTimer!, forMode: NSRunLoopCommonModes)
            }
            
        } else {
            //No schedule set
            self.hidePeriodStatusBar()
        }
    }
    
    func hidePeriodStatusBar() {
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(2)
        //UIView.setAnimationCurve(UIViewAnimationCurve.EaseInOut)
        
        self.tableView.beginUpdates()
        for subview in self.tableView.tableHeaderView!.subviews {
            subview.frame = CGRectZero
        }
        tableView.tableHeaderView!.frame = CGRectZero
        self.tableView.endUpdates()
        
        UIView.commitAnimations()
    }
    
    func showPeriodStatusBar() {
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(2)
        UIView.setAnimationCurve(UIViewAnimationCurve.EaseInOut)
        
        self.tableView.beginUpdates()
        self.tableView.tableHeaderView = self.tableHeaderView
        self.tableView.endUpdates()
        
        UIView.commitAnimations()
    }
    
    func clock() {
        if DailyScheduleManager.sharedInstance != nil {
            if let currentPeriod = DailyScheduleManager.sharedInstance!.currentPeriod {
                //Update the countdown label and UI components
                let timeRemainingInPeriod = currentPeriod.endSeconds - DailyScheduleManager.sharedInstance!.secondsFromMidnight()
                //TODO: UPDATE THE LABELS AND UI COMPONENTS HERE BASED ON timeRemainingInPeriod
                let timeElapsedInPeriod = DailyScheduleManager.sharedInstance!.secondsFromMidnight() - currentPeriod.startSeconds
                
                let percentDone = Double(timeElapsedInPeriod)/Double(currentPeriod.endSeconds - currentPeriod.startSeconds)
                
                self.percentDoneLabel.text = "\(Int(percentDone * 100))%"
                
                self.timeRemainingLabel.text = Double(timeRemainingInPeriod).stringFromTimeInterval() as String
                
                self.timeElapsedLabel.text = Double(timeElapsedInPeriod).stringFromTimeInterval() as String
                
                //                if (!spinnerSetup) {
                //                    spinnerSetup = true
                //
                //                    self.timeElapsedRing.animateFromAngle(360, toAngle: <#T##Double#>, duration: <#T##NSTimeInterval#>, completion: <#T##((Bool) -> Void)?##((Bool) -> Void)?##(Bool) -> Void#>)
                //                }
                //
                self.timeElapsedRing.animateToAngle(Double(360*percentDone), duration: 1.0, completion: { (success: Bool) in
                    if (success) {
                        //progress ring successfully animated
                        
                    }
                })
                
                self.timeLeftRing.animateToAngle(Double(360*(1-percentDone)), duration: 1.0, completion: { (success: Bool) in
                    if (success) {
                        //progress ring successfully animated
                        
                    }
                })
                
                if (currentPeriod.realPeriod != nil) {
                    //real period set
                    self.currentPeriodNumberLabel.text = "\(currentPeriod.realPeriod!.periodNumber)"
                    self.currentPeriodTitleLabel.text = currentPeriod.realPeriod!.name
                }
                else {
                    //no real period, probs modified
                    self.currentPeriodNumberLabel.text = String(currentPeriod.name!.characters.first!)
                    self.currentPeriodTitleLabel.text = currentPeriod.name!
                }
                
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
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 63
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
        if (self.selectedSchedule != nil) {
            
            if (self.isCurrentSchedule == true) {
                if (section == 0) {
                    if let nextPeriod = DailyScheduleManager.sharedInstance!.getNextSchedulePeriodInSchedule() {
                        if (nextPeriod.isAfterSchool != true && nextPeriod.isBeforeSchool != true) {
                            return 1
                        }
                    }
                }
                else {
                    return (DailyScheduleManager.sharedInstance?.currentSchedule?.periods.count)!
                }
            }
            else {
                return (self.selectedSchedule?.periods.count)!
            }
        }
        return 0
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("scheduleCell", forIndexPath: indexPath) as! ClassCell
        
        var indexSchedulePeriod: SchedulePeriod?
        
        if (self.isCurrentSchedule == true && indexPath.section == 0) {
            //get up next period
            if let nextPeriod = DailyScheduleManager.sharedInstance!.getNextSchedulePeriodInSchedule() {
                indexSchedulePeriod = nextPeriod
            }
            
        }
        else {
            //rest of schedule
            indexSchedulePeriod = self.selectedSchedule?.periods[indexPath.row]
        }
        
        if (indexSchedulePeriod != nil) {
            if (indexSchedulePeriod?.realPeriod != nil) {
                //there is a real period assigned so show number and class name
                cell.classTitleLabel.text = indexSchedulePeriod!.realPeriod!.name
                cell.teacherLabel.text = indexSchedulePeriod!.realPeriod!.teacherName
                cell.periodNumberLabel.text = "\(indexSchedulePeriod!.realPeriod!.periodNumber)"
            }
            else {
                //no real period assigned, probs a modified period
                cell.periodNumberLabel.text = String(indexSchedulePeriod!.name!.characters.first!)
                cell.classTitleLabel.text = indexSchedulePeriod!.name
                cell.teacherLabel.text = nil
                
            }
            
            cell.timeLabel!.text = "\(indexSchedulePeriod!.startSeconds.printSecondsToHoursMinutesSeconds())-\(indexSchedulePeriod!.endSeconds.printSecondsToHoursMinutesSeconds())"
        }
        
        if (self.isCurrentSchedule == true) {
            if (DailyScheduleManager.sharedInstance?.secondsFromMidnight() > indexSchedulePeriod?.endSeconds) {
                cell.periodNumberLabel.textColor = UIColor.lightGrayColor()
                cell.classTitleLabel.font = UIFont(name: "HelveticaNeue", size: 17)
            }
            else if (indexSchedulePeriod == DailyScheduleManager.sharedInstance?.currentPeriod) {
                cell.periodNumberLabel.textColor = UIColor.orangeColor()
                cell.classTitleLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 17)
            }
            else {
                cell.periodNumberLabel.textColor = UIColor(red:0.0, green:0.38, blue:0.76, alpha:1.0)
                cell.classTitleLabel.font = UIFont(name: "HelveticaNeue", size: 17)
            }
        }
        
        
        return cell
    }
    
    func getRealClassPeriods() {
        if (UserManager.sharedInstance != nil) {
            
            UserManager.sharedInstance?.currentUser.getClassmates({ (success: Bool) in
                if (success) {
                    //add current user to Realm with all of the data
                    let realm = try! Realm()
                    
                    try! realm.write {
                        realm.delete(realm.objects(RealmUser.self))
                    }
                    
                    DailyScheduleManager.sharedInstance?.currentUser = nil
                    
                    let realmUser = RealmUser()
                    
                    for period in UserManager.sharedInstance!.currentUser.schedule! {
                        let realmPeriod = RealmPeriod()
                        
                        realmPeriod.setPeriod(period: period)
                        
                        realmUser.schedule.append(realmPeriod)
                    }
                    
                    try! realm.write {
                        realm.add(realmUser)
                    }
                    
                    DailyScheduleManager.sharedInstance?.currentUser = realmUser
                    
                    DailyScheduleManager.sharedInstance?.getDailySchedule()
                    
                    print("success in view did appear")
                    
                }
                else {
                    print("error getting classes")
                    let alert = UIAlertController(title: "Error retrieving classes", message: "Please check your network connection and try again.", preferredStyle: .Alert)
                    let dismiss = UIAlertAction(title: "Dismiss", style: .Default, handler: nil)
                    alert.addAction(dismiss)
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            })
        }
    }
    
    func signIn(signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!,
                withError error: NSError!) {
        if (error == nil) {
            print("email: \(user.profile.email)")
            let emailDomain = user.profile.email.componentsSeparatedByString("@").last
            if (emailDomain?.containsString("westport.k12.ct.us") == true) {
                print("confirmed wepo")
                
                var profilePicURL: String?
                
                if (user.profile.hasImage) {
                    profilePicURL = user.profile.imageURLWithDimension(250).absoluteString
                    print(profilePicURL)
                }
                
                UserManager.createCurrentUser(user.profile.name, email: user.profile.email, token: user.authentication.idToken, profilePicURL: profilePicURL, completion: { (success: Bool) in
                    if (success) {
                        print("success!")
                        self.getRealClassPeriods()
                    }
                    else {
                        print("error signing in")
                        let alert = UIAlertController(title: "Error signing you in", message: "Please check your network connection and try again.", preferredStyle: .Alert)
                        let dismiss = UIAlertAction(title: "Dismiss", style: .Default, handler: nil)
                        alert.addAction(dismiss)
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                })
                //self.performSegueWithIdentifier("logIn", sender: self)
                
            }
            else {
                GIDSignIn.sharedInstance().signOut()
                let alert = UIAlertController(title: "Not Westport Account", message: "Please sign in using your Westport Google account and try again.", preferredStyle: .Alert)
                let ok = UIAlertAction(title: "OK", style: .Default, handler: nil)
                alert.addAction(ok)
                self.presentViewController(alert, animated: true, completion: nil)
            }
            
        } else {
            print("error signing in:( \(error)")
            self.logoutUser()//only do this if error is wrong creds, not for offline
        }
    }
    
}
