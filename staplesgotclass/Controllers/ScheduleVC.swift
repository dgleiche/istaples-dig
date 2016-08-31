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
    var tableHeaderViewHeight: CGFloat!
    
    var selectedSchedule: Schedule?
    var isCurrentSchedule = true
    var selectedDate = NSDate()
    
    var timer: NSTimer?
    
    var clockTimer: NSTimer?
    var periodTimer: NSTimer?
    
    var spinnerSetup = false
    
    var inDetailVC = false
    
    var attemptedToPresentLoginVC = false
    var attemptedToSignIn = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableHeaderView = tableView.tableHeaderView
        tableHeaderViewHeight = tableView.tableHeaderView?.frame.size.height
        
        
        let sweetBlue = UIColor(red:0.13, green:0.42, blue:0.81, alpha:1.0)
        self.setNavTitleForDate(NSDate())
        
        //Info bar button
        let infoButton = UIButton(type: .InfoLight)
        infoButton.addTarget(self, action: #selector(ScheduleVC.infoPressed), forControlEvents: .TouchUpInside)
        let infoBarButtonItem = UIBarButtonItem(customView: infoButton)
        navigationItem.leftBarButtonItem = infoBarButtonItem
        
        self.navigationController?.view.backgroundColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.barTintColor = sweetBlue
        self.navigationController?.navigationBar.translucent = false
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "AppleSDGothicNeo-Bold", size: 17)!, NSForegroundColorAttributeName: UIColor.whiteColor()]
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        
        for item in (self.tabBarController?.tabBar.items)! as [UITabBarItem] {
            if let image = item.image {
                item.image = image.imageWithColor(sweetBlue).imageWithRenderingMode(.AlwaysOriginal)
                item.selectedImage = item.selectedImage!.imageWithColor(sweetBlue).imageWithRenderingMode(.AlwaysOriginal)
                
            }
        }
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: sweetBlue], forState:.Normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: sweetBlue], forState:.Selected)
        
        self.timeLeftRing.angle = 0
        self.timeElapsedRing.angle = 360
        
        let rightSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(ScheduleVC.swipeDate(_:)))
        rightSwipeGestureRecognizer.direction = .Right
        
        let leftSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(ScheduleVC.swipeDate(_:)))
        leftSwipeGestureRecognizer.direction = .Left
        
        
        self.tableView.addGestureRecognizer(rightSwipeGestureRecognizer)
        self.tableView.addGestureRecognizer(leftSwipeGestureRecognizer)
        
        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(setDateToday))
        doubleTapRecognizer.numberOfTapsRequired = 2
        doubleTapRecognizer.delaysTouchesEnded = false
        self.navigationController?.navigationBar.addGestureRecognizer(doubleTapRecognizer)
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "Schedule")
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject: AnyObject])
        
        //Create the listener for log outs
        NSNotificationCenter.defaultCenter().addObserverForName("logout", object: nil, queue: nil) { note in
            GIDSignIn.sharedInstance().signOut()
            self.navigationController?.tabBarController!.selectedIndex = 0
            DailyScheduleManager.destroy()
            UserManager.destroy()
            let loginPage = self.storyboard?.instantiateViewControllerWithIdentifier("loginVC") as! LoginVC
            loginPage.modalTransitionStyle = .FlipHorizontal
            self.tabBarController?.presentViewController(loginPage, animated: true, completion: nil)
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ScheduleVC.callSetup), name: "loggedIn", object: nil)
        GIDSignIn.sharedInstance().delegate = self
        print("view did load setup")
        self.hidePeriodStatusBar(withDuration: 0)
        DailyScheduleManager.setup(self)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        
        
        if (DailyScheduleManager.sharedInstance?.fetchInProgress == false && self.inDetailVC == false && GIDSignIn.sharedInstance().currentUser != nil && UserManager.sharedInstance?.refreshNeeded == true) {
            //reload schedules in case of change, and go back to current schedule
            DailyScheduleManager.sharedInstance?.fetchInProgress = true
            print("calling view did appear setup")
            DailyScheduleManager.setup(self)
        }
        else if (self.inDetailVC == true) {
            self.inDetailVC = false
        }
        else if (GIDSignIn.sharedInstance().currentUser == nil && self.attemptedToSignIn == true) {
            GIDSignIn.sharedInstance().signInSilently()
        }
        
        setupClockTimer()
        setupPeriodTimer()
        
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
            
            DailyScheduleManager.sharedInstance?.fetchInProgress = false
            
            DailyScheduleManager.sharedInstance?.currentSchedule = DailyScheduleManager.sharedInstance!.getSchedule(withDate: NSDate())
            //            print("current schedule: \(DailyScheduleManager.sharedInstance?.currentSchedule)")
            
            //Setup the current period
            DailyScheduleManager.sharedInstance?.currentPeriod = DailyScheduleManager.sharedInstance!.getCurrentPeriod()
            
            self.isCurrentSchedule = true
            self.selectedDate = NSDate()
            self.setNavTitleForDate(self.selectedDate)
            
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
            else {
                self.navigationItem.prompt = nil
                self.selectedSchedule = nil
                self.tableView.reloadData()
            }
            
        }
        if (offline) {
            signInUser()
        }
        else {
            UserManager.sharedInstance?.refreshNeeded = false
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
        DailyScheduleManager.sharedInstance?.fetchInProgress = false
        
        let alert = UIAlertController(title: "Error loading schedules", message: "Please try again.", preferredStyle: .Alert)
        let ok = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(ok)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    //MARK: - Timer stuff
    
    
    func setupClockTimer() {
        self.clock()
        if self.clockTimer != nil {
            if self.clockTimer!.valid == true { self.clockTimer!.invalidate() }
        }
        
        self.clockTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(ScheduleVC.clock), userInfo: nil, repeats: true)
        NSRunLoop.mainRunLoop().addTimer(self.clockTimer!, forMode: NSRunLoopCommonModes)
    }
    
    func setupPeriodTimer() {
        if (DailyScheduleManager.sharedInstance != nil && DailyScheduleManager.sharedInstance?.fetchInProgress == false) {
            DailyScheduleManager.sharedInstance!.currentPeriod = DailyScheduleManager.sharedInstance!.getCurrentPeriod()
            self.tableView.reloadData()
            
            if self.periodTimer != nil {
                if self.periodTimer!.valid == true { self.periodTimer!.invalidate() }
            }
            
            if let currentPeriod = DailyScheduleManager.sharedInstance!.currentPeriod {
                self.performSelector(#selector(ScheduleVC.showPeriodStatusBar), withObject: nil, afterDelay: 1.0)
                //Next period event should be a passing time which occurs immediately after this period is over
                let timeIntervalUntilNextPeriodStart: Double = Double(currentPeriod.endSeconds - DailyScheduleManager.sharedInstance!.secondsFromMidnight())
                
                self.periodTimer = NSTimer.scheduledTimerWithTimeInterval(timeIntervalUntilNextPeriodStart + 1, target: self, selector: #selector(ScheduleVC.setupPeriodTimer), userInfo: nil, repeats: false)
                
                
                //                if currentPeriod.isPassingTime || currentPeriod.isBeforeSchool {
                //
                //                    //If it's currently passing time the next real period event should come into play
                //                    //Will only set up the timer if a 'next period' is available
                //                    //i.e nothing will happen if the day is over
                //                    if let nextPeriod = DailyScheduleManager.sharedInstance!.getNextSchedulePeriodInSchedule() {
                //                        let timeIntervalUntilNextPeriodStart: Double = Double(nextPeriod.startSeconds - DailyScheduleManager.sharedInstance!.secondsFromMidnight())
                //
                //                        //Add in 1 second to the interval to ensure it's the start of a new period and nothing funky happens
                //                        self.periodTimer = NSTimer.scheduledTimerWithTimeInterval(timeIntervalUntilNextPeriodStart + 1, target: self, selector: #selector(ScheduleVC.setupPeriodTimer), userInfo: nil, repeats: false)
                //                    }
                //
                //                } else if !currentPeriod.isAfterSchool {
                //
                //                                    //Next period event should be a passing time which occurs immediately after this period is over
                //                                    let timeIntervalUntilNextPeriodStart: Double = Double(currentPeriod.endSeconds - DailyScheduleManager.sharedInstance!.secondsFromMidnight())
                //
                //                                    self.periodTimer = NSTimer.scheduledTimerWithTimeInterval(timeIntervalUntilNextPeriodStart + 1, target: self, selector: #selector(ScheduleVC.setupPeriodTimer), userInfo: nil, repeats: false)
                //                                }
                //                                else if currentPeriod.isAfterSchool {
                //                                    ///DAY HAS ENDED
                //                                    hidePeriodStatusBar()
                //                                    print("day is now over")
                //                                }
                //            }
                
            }
            else {
                //no current period, hide status bar
                hidePeriodStatusBar()
                
                //This should be for the morning period
                if let nextPeriod = DailyScheduleManager.sharedInstance!.getNextSchedulePeriodInSchedule() {
                    //Currently before ten mins before morning
                    
                    let timeIntervalUntilNextPeriodStart: Double = Double(nextPeriod.startSeconds - DailyScheduleManager.sharedInstance!.secondsFromMidnight())
                    
                    self.periodTimer = NSTimer.scheduledTimerWithTimeInterval(timeIntervalUntilNextPeriodStart, target: self, selector: #selector(ScheduleVC.setupPeriodTimer), userInfo: nil, repeats: false)
                }
            }
            
            if (self.periodTimer != nil) {
                NSRunLoop.mainRunLoop().addTimer(self.periodTimer!, forMode: NSRunLoopCommonModes)
            }
            
        } else {
            //No schedule set
            self.hidePeriodStatusBar()
        }
    }
    
    func hidePeriodStatusBar(withDuration duration: NSTimeInterval = 0.4) {
        self.tableView.reloadData()
        var smallFrame = self.tableView.tableHeaderView?.frame
        smallFrame?.size.height = 0
        self.tableHeaderView.layer.masksToBounds = true
        UIView.animateWithDuration(duration) {
            self.tableHeaderView.frame = smallFrame!
            self.tableView.tableHeaderView = self.tableHeaderView
        }
    }
    
    func showPeriodStatusBar() {
        if isCurrentSchedule {
            var smallFrame = self.tableView.tableHeaderView?.frame
            smallFrame?.size.height = self.tableHeaderViewHeight
            self.tableHeaderView.layer.masksToBounds = true
            UIView.animateWithDuration(0.3) {
                self.tableHeaderView.frame = smallFrame!
                self.tableView.tableHeaderView = self.tableHeaderView
            }
        }
    }
    
    func clock() {
        if (DailyScheduleManager.sharedInstance != nil && DailyScheduleManager.sharedInstance?.fetchInProgress == false) {
            if let currentPeriod = DailyScheduleManager.sharedInstance!.currentPeriod {
                //Update the countdown label and UI components
                let timeRemainingInPeriod = currentPeriod.endSeconds - DailyScheduleManager.sharedInstance!.secondsFromMidnight()
                
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
    
    //MARK: - Date change handling
    
    func setDateToday() {
        self.selectedDate = NSDate()
        self.changeSchedule(withAnimation: kCATransitionFromTop)
    }
    
    @IBAction func dateChosen(sender: AnyObject) {
        let minDate = NSDate(timeIntervalSince1970: 1472688000)
        DatePickerDialog().show(title: "Select Date", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", defaultDate: self.selectedDate, minimumDate: minDate, maximumDate: nil, datePickerMode: UIDatePickerMode.Date) { (date) in
            if (date != nil) {
                self.selectedDate = date!
                self.changeSchedule(withAnimation: kCATransitionFromBottom)
            }
        }
    }
    
    
    func swipeDate(sender: UISwipeGestureRecognizer) {
        if (DailyScheduleManager.sharedInstance?.fetchInProgress == false) {
            print("swipe activated!")
            switch (sender.direction) {
            case UISwipeGestureRecognizerDirection.Left:
                //advance schedule 1 day forward
                self.selectedDate = self.selectedDate.addDay(1)
                self.changeSchedule(withAnimation: kCATransitionFromRight)
            case UISwipeGestureRecognizerDirection.Right:
                //advance schedule 1 day backwards
                self.selectedDate = self.selectedDate.addDay(-1)
                self.changeSchedule(withAnimation: kCATransitionFromLeft)
            default:
                break
            }
        }
        
    }
    
    func changeSchedule(withAnimation animation: String?) {
        self.selectedSchedule = DailyScheduleManager.sharedInstance?.getSchedule(withDate: self.selectedDate)
        if (self.selectedSchedule == DailyScheduleManager.sharedInstance?.currentSchedule && self.selectedSchedule != nil && NSCalendar.currentCalendar().compareDate(self.selectedDate, toDate: NSDate(), toUnitGranularity: .Day) == .OrderedSame) {
            self.isCurrentSchedule = true
            if (DailyScheduleManager.sharedInstance?.getCurrentPeriod() != nil) {
                self.showPeriodStatusBar()
            }
        }
        else {
            self.isCurrentSchedule = false
            self.hidePeriodStatusBar(withDuration: 0)
        }
        
        if (self.selectedSchedule?.isStatic != false) {
            self.navigationItem.prompt = nil
        }
        else {
            self.navigationItem.prompt = "Modified Schedule"
        }
        //        if (animation != nil) {
        //            let range: NSRange!
        //            if (self.isCurrentSchedule) {
        //             range = NSMakeRange(0, 1)
        //            }
        //            else {
        //                range = NSMakeRange(0, 0)
        //            }
        //            let sections = NSIndexSet(indexesInRange: range)
        //            self.tableView.beginUpdates()
        //            self.tableView.reloadSections(sections, withRowAnimation: animation!)
        //            self.tableView.endUpdates()
        //        }
        //        else {
        //        self.tableView.reloadData()
        //        }
        
        
        let transition = CATransition()
        transition.duration = 0.4
        transition.type = kCATransitionPush
        transition.subtype = animation
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionDefault)
        self.view.layer.addAnimation(transition, forKey: "reloadTableView")
        self.tableView.reloadData()
        self.view.layer.removeAnimationForKey("reloadTableView")
        self.setNavTitleForDate(self.selectedDate)
    }
    
    func setNavTitleForDate(date: NSDate) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EEEE, MMMM d, Y"
        self.navigationItem.title = dateFormatter.stringFromDate(date)
        
        if (NSCalendar.currentCalendar().compareDate(self.selectedDate, toDate: NSDate(), toUnitGranularity: .Day) == .OrderedSame) {
            self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "AppleSDGothicNeo-Bold", size: 17)!, NSForegroundColorAttributeName: UIColor.whiteColor()]
        }
        else {
            self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "AppleSDGothicNeo-Medium", size: 17)!, NSForegroundColorAttributeName: UIColor.whiteColor()]
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        if (self.selectedSchedule != nil) {
            if (self.isCurrentSchedule == true) {
                if let nextPeriod = DailyScheduleManager.sharedInstance!.getNextSchedulePeriodInSchedule() {
                    if (nextPeriod.isAfterSchool != true && nextPeriod.isBeforeSchool != true) {
                        return 2
                    }
                }
            }
            return 1
        }
        else {
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let defaultCellHeight = 63
        let minimumCellHeight = 50.0
        
        //Only modify the height for non-current days
        if !isCurrentSchedule {
            let totalHeight = Int(tableView.bounds.height) - Int(navigationController!.navigationBar.frame.height) - 60
            
            if let curSchedule = self.selectedSchedule {
                let newHeight = (Double(1) / Double(curSchedule.periods.count)) * Double(totalHeight)
                
                //Make sure not to go under the minimum
                return (newHeight < minimumCellHeight) ? CGFloat(minimumCellHeight) : CGFloat(newHeight)
            }
        }
        
        return CGFloat(defaultCellHeight)
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.min
        
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (self.isCurrentSchedule == true) {
            if (section == 0) {
                if let nextPeriod = DailyScheduleManager.sharedInstance!.getNextSchedulePeriodInSchedule() {
                    if (nextPeriod.isAfterSchool != true && nextPeriod.isBeforeSchool != true) {
                        return "Up Next"
                    }
                }
            }
        }
        return "Schedule"
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.selectedSchedule != nil) {
            
            if (self.isCurrentSchedule == true) {
                if (section == 0) {
                    if let nextPeriod = DailyScheduleManager.sharedInstance!.getNextSchedulePeriodInSchedule() {
                        if (nextPeriod.isAfterSchool != true && nextPeriod.isBeforeSchool != true) {
                            return 1
                        }
                        else {
                            return (DailyScheduleManager.sharedInstance?.currentSchedule?.periods.count)!
                        }
                    }
                    else {
                        return (DailyScheduleManager.sharedInstance?.currentSchedule?.periods.count)!
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
        
        if (self.isCurrentSchedule == true && indexPath.section == 0 && tableView.numberOfSections == 2) {
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
                cell.userInteractionEnabled = true //allow selection bc of real period
            }
            else {
                //no real period assigned, probs a modified period
                let indexSchedulePeriodName = indexSchedulePeriod!.name ?? "NO NAME"
                cell.periodNumberLabel.text = String(indexSchedulePeriodName.characters.first!)
                cell.classTitleLabel.text = (indexSchedulePeriod!.isCustom) ? indexSchedulePeriod!.name : nil
                cell.teacherLabel.text = nil
                cell.userInteractionEnabled = false //disable selection because no real period
            }
            
            if (indexSchedulePeriod!.isLunchPeriod) {
                if let lunchType = indexSchedulePeriod!.lunchType {
                    cell.lunchNumberLabel?.text = "\(DailyScheduleManager.sharedInstance?.getLunchNumber(withDate: selectedDate, andLunchType: lunchType) ?? 0)"
                    if (lunchType.isLab == true) {
                        cell.labView!.hidden = false
                        cell.teacherLabel.hidden = true
                    }
                    else {
                        cell.labView!.hidden = true
                        cell.teacherLabel.hidden = false
                    }
                }
                else {
                    cell.lunchNumberLabel?.text = "\(indexSchedulePeriod!.lunchNumber)"
                    cell.labView!.hidden = true
                    cell.teacherLabel.hidden = false
                }
            }
            else {
                cell.lunchNumberLabel?.text = nil
                cell.labView!.hidden = true
                cell.teacherLabel.hidden = false
            }
            
            cell.timeLabel!.text = "\(indexSchedulePeriod!.startSeconds.printSecondsToHoursMinutesSeconds())-\(indexSchedulePeriod!.endSeconds.printSecondsToHoursMinutesSeconds())"
        }
        
        if (self.isCurrentSchedule == true) {
            if (DailyScheduleManager.sharedInstance?.secondsFromMidnight() > indexSchedulePeriod?.endSeconds) {
                cell.periodNumberLabel.textColor = UIColor.lightGrayColor()
                cell.classTitleLabel.font = UIFont(name: "HelveticaNeue", size: 17)
            }
            else if (indexSchedulePeriod == DailyScheduleManager.sharedInstance?.currentPeriod) {
                cell.periodNumberLabel.textColor = UIColor(red:0.3, green:0.8, blue:0.13, alpha:1.0)
                cell.classTitleLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 17)
            }
            else {
                cell.periodNumberLabel.textColor = UIColor(red:0.0, green:0.38, blue:0.76, alpha:1.0)
                cell.classTitleLabel.font = UIFont(name: "HelveticaNeue", size: 17)
            }
        }
        else {
            cell.periodNumberLabel.textColor = UIColor(red:0.0, green:0.38, blue:0.76, alpha:1.0)
            cell.classTitleLabel.font = UIFont(name: "HelveticaNeue", size: 17)
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    //MARK: - Segue Handling
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if (segue.identifier == "scheduleClassmatesSegue") {
            self.inDetailVC = true
            let classmatesVC = segue.destinationViewController as! ClassmatesVC
            let selectedIndexPath = self.tableView.indexPathForSelectedRow
            var indexSchedulePeriod: SchedulePeriod?
            
            let backButton = UIBarButtonItem(title: " ", style: .Plain, target: nil, action: nil)
            self.navigationItem.backBarButtonItem = backButton
            
            if (self.isCurrentSchedule == true && selectedIndexPath!.section == 0 && self.tableView.numberOfSections == 2) {
                //get up next period
                if let nextPeriod = DailyScheduleManager.sharedInstance!.getNextSchedulePeriodInSchedule() {
                    indexSchedulePeriod = nextPeriod
                }
                
            }
            else {
                //rest of schedule
                indexSchedulePeriod = self.selectedSchedule?.periods[selectedIndexPath!.row]
            }
            
            let realmPeriod = indexSchedulePeriod?.realPeriod
            classmatesVC.currentClass = realmPeriod?.exchangeForRealPeriod()
            
            self.navigationItem.prompt = nil
            
        }
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if (identifier == "scheduleClassmatesSegue") {
            let selectedIndexPath = self.tableView.indexPathForSelectedRow
            var indexSchedulePeriod: SchedulePeriod?
            
            if (self.isCurrentSchedule == true && selectedIndexPath!.section == 0 && self.tableView.numberOfSections == 2) {
                //get up next period
                if let nextPeriod = DailyScheduleManager.sharedInstance!.getNextSchedulePeriodInSchedule() {
                    indexSchedulePeriod = nextPeriod
                }
                
            }
            else {
                //rest of schedule
                indexSchedulePeriod = self.selectedSchedule?.periods[selectedIndexPath!.row]
            }
            
            let realmPeriod = indexSchedulePeriod?.realPeriod
            if (realmPeriod?.exchangeForRealPeriod() != nil) {
                return true
            }
            else {
                return false
            }
            
        }
        return true
    }
    
    //MARK: - Period Management
    
    func getRealClassPeriods() {
        if (UserManager.sharedInstance != nil) {
            DailyScheduleManager.sharedInstance?.fetchInProgress = true
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
                    
                    if (UserManager.sharedInstance?.currentUser.schedule == nil || UserManager.sharedInstance?.currentUser.schedule?.count == 0) {
                        //if there are no classes, go to classes tab to add one
                        self.navigationController?.tabBarController?.selectedIndex = 1
                    }
                    
                    print("success in view did appear")
                    
                }
                else {
                    print("error getting classes")
                    DailyScheduleManager.sharedInstance?.fetchInProgress = false
                    
                    let alert = UIAlertController(title: "Error retrieving classes", message: "Please check your network connection and try again.", preferredStyle: .Alert)
                    let dismiss = UIAlertAction(title: "Dismiss", style: .Default, handler: nil)
                    alert.addAction(dismiss)
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            })
        }
    }
    
    //MARK: - Sign in handling
    
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
            if error.code == -4 {
                //only do this if error is wrong creds, not for offline
                if !attemptedToPresentLoginVC {
                    attemptedToPresentLoginVC = true
                    logoutUser()
                    self.attemptedToSignIn = false
                }
            }
            else {
                self.attemptedToSignIn = true
            }
        }
    }
    
    func infoPressed() {
        let infoPage = self.storyboard?.instantiateViewControllerWithIdentifier("infoVC") as! UINavigationController
        self.tabBarController?.presentViewController(infoPage, animated: true, completion: nil)
    }
    
    func logoutUser() {
        DailyScheduleManager.destroy()
        GIDSignIn.sharedInstance().delegate = nil
        GIDSignIn.sharedInstance().signOut()
        let loginPage = self.storyboard?.instantiateViewControllerWithIdentifier("loginVC") as! LoginVC
        UIApplication.topViewController()?.presentViewController(loginPage, animated: true, completion: nil)
    }
    
    
}
