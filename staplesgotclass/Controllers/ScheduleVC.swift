//
//  ScheduleVC.swift
//  staplesgotclass
//
//  Created by Dylan Diamond on 8/11/16.
//  Copyright © 2016 Dylan Diamond. All rights reserved.
//

import UIKit
import RealmSwift
import KDCircularProgress
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class ScheduleVC: UITableViewController, DailyScheduleManagerDelegate, GIDSignInDelegate {

    @IBOutlet var timeLeftRing: KDCircularProgress!
    @IBOutlet var timeElapsedRing: KDCircularProgress!
    @IBOutlet var timeRemainingLabel: UILabel!
    @IBOutlet var timeElapsedLabel: UILabel!
    @IBOutlet var percentDoneLabel: UILabel!
    @IBOutlet var currentPeriodNumberLabel: UILabel!
    @IBOutlet var currentPeriodTitleLabel: UILabel!
    @IBOutlet var currentLunchLabel: UILabel!
    
    var tableHeaderView: UIView!
    var tableHeaderViewHeight: CGFloat!
    
    var selectedSchedule: Schedule?
    var isCurrentSchedule = true
    var selectedDate = Date()
    
    var timer: Timer?
    
    var clockTimer: Timer?
    var periodTimer: Timer?
    
    var spinnerSetup = false
    
    var inDetailVC = false
    
    var attemptedToPresentLoginVC = false
    var attemptedToSignIn = false
    
    var lastUpdateAttempt = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableHeaderView = tableView.tableHeaderView
        tableHeaderViewHeight = tableView.tableHeaderView?.frame.size.height
        
        
        let sweetBlue = UIColor(red:0.13, green:0.42, blue:0.81, alpha:1.0)
        self.setNavTitleForDate(Date())
        
        //Info bar button
        let infoButton = UIButton(type: .infoLight)
        infoButton.addTarget(self, action: #selector(ScheduleVC.infoPressed), for: .touchUpInside)
        let infoBarButtonItem = UIBarButtonItem(customView: infoButton)
        navigationItem.leftBarButtonItem = infoBarButtonItem
        
        self.navigationController?.view.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.barTintColor = sweetBlue
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "AppleSDGothicNeo-Bold", size: 17)!, NSForegroundColorAttributeName: UIColor.white]
        UIApplication.shared.statusBarStyle = .lightContent
        
        for item in (self.tabBarController?.tabBar.items)! as [UITabBarItem] {
            if let image = item.image {
                item.image = image.imageWithColor(sweetBlue).withRenderingMode(.alwaysOriginal)
                item.selectedImage = item.selectedImage!.imageWithColor(sweetBlue).withRenderingMode(.alwaysOriginal)
                
            }
        }
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: sweetBlue], for:UIControlState())
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: sweetBlue], for:.selected)
        
        self.timeLeftRing.angle = 0
        self.timeElapsedRing.angle = 360
        
        let rightSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(ScheduleVC.swipeDate(_:)))
        rightSwipeGestureRecognizer.direction = .right
        
        let leftSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(ScheduleVC.swipeDate(_:)))
        leftSwipeGestureRecognizer.direction = .left
        
        
        self.tableView.addGestureRecognizer(rightSwipeGestureRecognizer)
        self.tableView.addGestureRecognizer(leftSwipeGestureRecognizer)
        
        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(setDateToday))
        doubleTapRecognizer.numberOfTapsRequired = 2
        doubleTapRecognizer.delaysTouchesEnded = false
        self.navigationController?.navigationBar.addGestureRecognizer(doubleTapRecognizer)
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: "Schedule")
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker?.send(builder?.build() as! [AnyHashable: Any])
        
        //Create the listener for log outs
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "logout"), object: nil, queue: nil) { note in
            GIDSignIn.sharedInstance().signOut()
            GIDSignIn.sharedInstance().delegate = nil
            self.navigationController?.tabBarController!.selectedIndex = 0
            DailyScheduleManager.destroy()
            UserManager.destroy()
            let loginPage = self.storyboard?.instantiateViewController(withIdentifier: "loginVC") as! LoginVC
            loginPage.modalTransitionStyle = .flipHorizontal
            self.tabBarController?.present(loginPage, animated: true, completion: nil)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(ScheduleVC.callSetup), name: NSNotification.Name(rawValue: "loggedIn"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ScheduleVC.applicationDidBecomeActive), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        GIDSignIn.sharedInstance().delegate = self
        print("view did load setup")
        self.hidePeriodStatusBar(withDuration: 0)
        DailyScheduleManager.setup(self)
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
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
        print("setup timers in view did appear")
    }
    
    func callSetup() {
        print("calling setup")
        DailyScheduleManager.setup(self)
    }
    
    func applicationDidBecomeActive() {
        setupClockTimer()
        setupPeriodTimer()
        print("setup timers in didbecomeactive")
        if (DailyScheduleManager.sharedInstance != nil && GIDSignIn.sharedInstance().currentUser != nil && self.inDetailVC == false && DailyScheduleManager.sharedInstance?.fetchInProgress == false && (Calendar.current as NSCalendar).compare(self.lastUpdateAttempt, to: Date(), toUnitGranularity: .day) != .orderedSame) {
            print("CALLING ACTIVE")
            DailyScheduleManager.setup(self)
            self.lastUpdateAttempt = Date()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Daily Schedule Manager Delegate Methods
    
    func didFetchSchedules(_ offline: Bool) {
        print("delegate called")
        if DailyScheduleManager.sharedInstance != nil {
            print("staticScheduleCount: \(String(describing: DailyScheduleManager.sharedInstance?.staticSchedules.count))")
            print("modScheduleCount: \(String(describing: DailyScheduleManager.sharedInstance?.modifiedSchedules.count))")
            
            DailyScheduleManager.sharedInstance?.fetchInProgress = false
            
            DailyScheduleManager.sharedInstance?.currentSchedule = DailyScheduleManager.sharedInstance!.getSchedule(withDate: Date())
            //            print("current schedule: \(DailyScheduleManager.sharedInstance?.currentSchedule)")
            
            //Setup the current period
            DailyScheduleManager.sharedInstance?.currentPeriod = DailyScheduleManager.sharedInstance!.getCurrentPeriod()
            
            self.isCurrentSchedule = true
            self.selectedDate = Date()
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
        
        let alert = UIAlertController(title: "Error loading schedules", message: "Please try again.", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Timer stuff
    
    
    func setupClockTimer() {
        self.clock()
        if self.clockTimer != nil {
            if self.clockTimer!.isValid == true { self.clockTimer!.invalidate() }
        }
        
        self.clockTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(ScheduleVC.clock), userInfo: nil, repeats: true)
        RunLoop.main.add(self.clockTimer!, forMode: RunLoopMode.commonModes)
    }
    
    func setupPeriodTimer() {
        print("setup period timer called")
        if (DailyScheduleManager.sharedInstance != nil && DailyScheduleManager.sharedInstance?.fetchInProgress == false) {
            DailyScheduleManager.sharedInstance!.currentPeriod = DailyScheduleManager.sharedInstance!.getCurrentPeriod()
            self.tableView.reloadData()
            
            if self.periodTimer != nil {
                if self.periodTimer!.isValid == true { self.periodTimer!.invalidate() }
            }
            
            if let currentPeriod = DailyScheduleManager.sharedInstance!.currentPeriod {
                self.perform(#selector(ScheduleVC.showPeriodStatusBar), with: nil, afterDelay: 1.0)
                //Next period event should be a passing time which occurs immediately after this period is over
                let timeIntervalUntilNextPeriodStart: Double = Double(currentPeriod.endSeconds - DailyScheduleManager.sharedInstance!.secondsFromMidnight())
                
                self.periodTimer = Timer.scheduledTimer(timeInterval: timeIntervalUntilNextPeriodStart + 1, target: self, selector: #selector(ScheduleVC.setupPeriodTimer), userInfo: nil, repeats: false)
                
                
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
                    
                    self.periodTimer = Timer.scheduledTimer(timeInterval: timeIntervalUntilNextPeriodStart, target: self, selector: #selector(ScheduleVC.setupPeriodTimer), userInfo: nil, repeats: false)
                }
            }
            
            if (self.periodTimer != nil) {
                RunLoop.main.add(self.periodTimer!, forMode: RunLoopMode.commonModes)
            }
            
        } else {
            //No schedule set
            self.hidePeriodStatusBar()
        }
    }
    
    func hidePeriodStatusBar(withDuration duration: TimeInterval = 0.4) {
        self.tableView.reloadData()
        var smallFrame = self.tableView.tableHeaderView?.frame
        smallFrame?.size.height = 0
        self.tableHeaderView.layer.masksToBounds = true
        UIView.animate(withDuration: duration, animations: {
            self.tableHeaderView.frame = smallFrame!
            self.tableView.tableHeaderView = self.tableHeaderView
        }) 
    }
    
    func showPeriodStatusBar() {
        if isCurrentSchedule {
            var smallFrame = self.tableView.tableHeaderView?.frame
            smallFrame?.size.height = self.tableHeaderViewHeight
            self.tableHeaderView.layer.masksToBounds = true
            UIView.animate(withDuration: 0.3, animations: {
                self.tableHeaderView.frame = smallFrame!
                self.tableView.tableHeaderView = self.tableHeaderView
            }) 
        }
    }
    
    func clock() {
        if (DailyScheduleManager.sharedInstance != nil) {
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
                self.timeElapsedRing.animate(toAngle: Double(360*percentDone), duration: 1.0, completion: { (success: Bool) in
                    if (success) {
                        //progress ring successfully animated
                        
                    }
                })
                
                self.timeLeftRing.animate(toAngle: Double(360*(1-percentDone)), duration: 1.0, completion: { (success: Bool) in
                    if (success) {
                        //progress ring successfully animated
                        
                    }
                })
                
                if (currentPeriod.realPeriod != nil) {
                    //real period set
                    self.currentPeriodNumberLabel.text = "\(currentPeriod.realPeriod!.periodNumber)"
                    self.currentPeriodTitleLabel.text = currentPeriod.realPeriod!.name
                    if (currentPeriod.isLunch) {
                        if (currentPeriod.lunchNumber != 0) {
                            self.currentLunchLabel.text = "\(currentPeriod.lunchNumber)"
                        }
                        else {
                            self.currentLunchLabel.text = nil
                        }
                        if (currentPeriod.isLunchPeriod) {
                            if let lunchType = currentPeriod.lunchType {
                                if (lunchType.isLab) {
                                    self.currentPeriodTitleLabel.text = "Lab Lunch"
                                }
                                else {
                                    self.currentPeriodTitleLabel.text = "Lunch"
                                }
                            }
                        }
                    }
                    else {
                        self.currentLunchLabel.text = nil
                    }
                }
                else {
                    //no real period, probs modified
                    self.currentPeriodNumberLabel.text = String(currentPeriod.name!.characters.first!)
                    self.currentPeriodTitleLabel.text = currentPeriod.name!
                    self.currentLunchLabel.text = nil
                }
                
            }
        }
    }
    
    //MARK: - Date change handling
    
    func setDateToday() {
        self.selectedDate = Date()
        self.changeSchedule(withAnimation: kCATransitionFromTop)
    }
    
    @IBAction func dateChosen(_ sender: AnyObject) {
        let minDate = Date(timeIntervalSince1970: 1472688000)
        DatePickerDialog().show(title: "Select Date", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", defaultDate: self.selectedDate, minimumDate: minDate, maximumDate: nil, datePickerMode: UIDatePickerMode.date) { (date) in
            if (date != nil) {
                self.selectedDate = date!
                self.changeSchedule(withAnimation: kCATransitionFromBottom)
            }
        }
    }
    
    
    func swipeDate(_ sender: UISwipeGestureRecognizer) {
        if (DailyScheduleManager.sharedInstance?.fetchInProgress == false) {
            print("swipe activated!")
            switch (sender.direction) {
            case UISwipeGestureRecognizerDirection.left:
                //advance schedule 1 day forward
                self.selectedDate = self.selectedDate.addDay(1)
                self.changeSchedule(withAnimation: kCATransitionFromRight)
            case UISwipeGestureRecognizerDirection.right:
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
        print("selectected schedule: \(String(describing: self.selectedSchedule))")
        if (self.selectedSchedule == DailyScheduleManager.sharedInstance?.currentSchedule && self.selectedSchedule != nil && (Calendar.current as NSCalendar).compare(self.selectedDate, to: Date(), toUnitGranularity: .day) == .orderedSame) {
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
        self.view.layer.add(transition, forKey: "reloadTableView")
        self.tableView.reloadData()
        self.view.layer.removeAnimation(forKey: "reloadTableView")
        self.setNavTitleForDate(self.selectedDate)
    }
    
    func setNavTitleForDate(_ date: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMMM d, Y"
        self.navigationItem.title = dateFormatter.string(from: date)
        
        if ((Calendar.current as NSCalendar).compare(self.selectedDate, to: Date(), toUnitGranularity: .day) == .orderedSame) {
            self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "AppleSDGothicNeo-Bold", size: 17)!, NSForegroundColorAttributeName: UIColor.white]
        }
        else {
            self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "AppleSDGothicNeo-Medium", size: 17)!, NSForegroundColorAttributeName: UIColor.white]
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        self.tableView.backgroundView = nil
        if (self.selectedSchedule != nil && DailyScheduleManager.sharedInstance != nil) {
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
            if (DailyScheduleManager.sharedInstance?.staticSchedules.count > 0) {
            TableViewHelper.EmptyMessage("Enjoy the weekend!", viewController: self)
            }
            else {
                TableViewHelper.EmptyMessage("Loading schedules...", viewController: self)

            }
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
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
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
        
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
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
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "scheduleCell", for: indexPath) as! ClassCell
        
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
                cell.isUserInteractionEnabled = true //allow selection bc of real period
            }
            else {
                //no real period assigned, probs a modified period
                let indexSchedulePeriodName = indexSchedulePeriod!.name ?? "NO NAME"
                cell.periodNumberLabel.text = String(indexSchedulePeriodName.characters.first!)
                cell.classTitleLabel.text = (indexSchedulePeriod!.isCustom) ? indexSchedulePeriod!.name : nil
                cell.teacherLabel.text = nil
                cell.isUserInteractionEnabled = false //disable selection because no real period
            }
            
            if (indexSchedulePeriod!.isLunchPeriod) {
                if let lunchType = indexSchedulePeriod!.lunchType {
                    cell.lunchNumberLabel?.text = "\(DailyScheduleManager.sharedInstance?.getLunchNumber(withDate: selectedDate, andLunchType: lunchType) ?? 0)"
                    cell.classTitleLabel.text = "Lunch"
                    cell.teacherLabel.isHidden = true
                    if (lunchType.isLab == true) {
                        cell.labView!.isHidden = false
                    }
                    else {
                        cell.labView!.isHidden = true
                    }
                }
                else {
                    cell.lunchNumberLabel?.text = "\(indexSchedulePeriod!.lunchNumber)"
                    cell.labView!.isHidden = true
                    cell.teacherLabel.isHidden = false
                }
            }
            else if (indexSchedulePeriod!.isLunch) {
                if (indexSchedulePeriod!.lunchNumber != 0) {
                    cell.lunchNumberLabel?.text = "\(indexSchedulePeriod!.lunchNumber)"
                }
                else {
                    cell.lunchNumberLabel?.text = nil
                }
                cell.labView!.isHidden = true
                cell.teacherLabel.isHidden = false
            }
            else {
                cell.lunchNumberLabel?.text = nil
                cell.labView!.isHidden = true
                cell.teacherLabel.isHidden = false
            }
            
            cell.timeLabel!.text = "\(indexSchedulePeriod!.startSeconds.printSecondsToHoursMinutesSeconds())-\(indexSchedulePeriod!.endSeconds.printSecondsToHoursMinutesSeconds())"
        }
        
        if (self.isCurrentSchedule == true) {
            if (DailyScheduleManager.sharedInstance?.secondsFromMidnight() > indexSchedulePeriod?.endSeconds) {
                cell.periodNumberLabel.textColor = UIColor.lightGray
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: - Segue Handling
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "scheduleClassmatesSegue") {
            self.inDetailVC = true
            let classmatesVC = segue.destination as! ClassmatesVC
            let selectedIndexPath = self.tableView.indexPathForSelectedRow
            var indexSchedulePeriod: SchedulePeriod?
            
            let backButton = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
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
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
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
                if (indexSchedulePeriod?.isLunchPeriod == true) {
                    return false
                }
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
                    
                    DailyScheduleManager.sharedInstance?.realmPeriodsToDelete = Array(realm.objects(RealmPeriod.self))
                    
                    DailyScheduleManager.sharedInstance?.currentUser = nil
                    
                    let realmUser = RealmUser()
                    
                    for period in UserManager.sharedInstance!.currentUser.schedule! {
                        let realmPeriod = RealmPeriod()
                        
                        realmPeriod.setPeriod(period)
                        
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
                    
                    let alert = UIAlertController(title: "Error retrieving classes", message: "Please check your network connection and try again.", preferredStyle: .alert)
                    let dismiss = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
                    alert.addAction(dismiss)
                    self.present(alert, animated: true, completion: nil)
                }
            })
        }
    }
    
    //MARK: - Sign in handling
    
    
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {
        if (error == nil) {
            print("email: \(user.profile.email)")
            let emailDomain = user.profile.email.components(separatedBy: "@").last
            if (emailDomain?.contains("westport.k12.ct.us") == true || emailDomain?.contains("westportps.org") == true || emailDomain?.contains("dcdwebdesign.com") == true) {
                print("confirmed wepo")
                
                var profilePicURL: String?
                
                if (user.profile.hasImage) {
                    profilePicURL = user.profile.imageURL(withDimension: 250).absoluteString
                    print(profilePicURL as Any)
                }
                
                UserManager.createCurrentUser(user.profile.name, email: user.profile.email, token: user.authentication.idToken, profilePicURL: profilePicURL, completion: { (success: Bool) in
                    if (success) {
                        print("success!")
                        self.getRealClassPeriods()
                    }
                    else {
                        print("error signing in")
                        let alert = UIAlertController(title: "Error signing you in", message: "Please check your network connection and try again.", preferredStyle: .alert)
                        let dismiss = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
                        alert.addAction(dismiss)
                        self.present(alert, animated: true, completion: nil)
                    }
                })
                //self.performSegueWithIdentifier("logIn", sender: self)
                
            }
            else {
                GIDSignIn.sharedInstance().signOut()
                let alert = UIAlertController(title: "Not Westport Account", message: "Please sign in using your Westport Google account and try again.", preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(ok)
                self.present(alert, animated: true, completion: nil)
            }
            
        } else {
            print("error signing in:( \(error)")
            if (error as NSError?)?.code == -4 {
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
        let infoPage = self.storyboard?.instantiateViewController(withIdentifier: "infoVC") as! UINavigationController
        self.tabBarController?.present(infoPage, animated: true, completion: nil)
    }
    
    func logoutUser() {
        DailyScheduleManager.destroy()
        GIDSignIn.sharedInstance().delegate = nil
        GIDSignIn.sharedInstance().signOut()
        let loginPage = self.storyboard?.instantiateViewController(withIdentifier: "loginVC") as! LoginVC
        UIApplication.topViewController()?.present(loginPage, animated: true, completion: nil)
    }
    
    
}
