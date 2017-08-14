//
//  ExtensionDelegate.swift
//  staplesWatchApp Extension
//
//  Created by Dylan Diamond on 9/5/16.
//  Copyright © 2016 Dylan Diamond. All rights reserved.
//

import WatchKit
import WatchConnectivity

class ExtensionDelegate: NSObject, WKExtensionDelegate, WCSessionDelegate {
    var session: WCSession? {
        didSet {
            if let session = session {
                session.delegate = self
                session.activate()
            }
        }
    }
    
    
    func applicationDidFinishLaunching() {
        // Perform any final initialization of your application.
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        self.updateData(nil)
    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        if (session.isReachable) {
        self.updateData(nil)
        }
    }
    
    @available(watchOSApplicationExtension 3.0, *)
    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        for task in backgroundTasks {
            print("received background task: ", task)
            // only handle these while running in the background
            if (WKExtension.shared().applicationState == .background) {
                if task is WKApplicationRefreshBackgroundTask {
                    self.updateData(task)
                }
                else if task is WKSnapshotRefreshBackgroundTask {
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "scheduleReceived"), object: nil)
                    task.setTaskCompleted()
                }
            }
            
            // make sure to complete all tasks, even ones you don't handle
            task.setTaskCompleted()
        }
    }
    
    
    func applicationDidBecomeActive() {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        //Write code to get current schedule using watch connectivity
        print("application becoming active")
        if session == nil || session?.activationState != WCSessionActivationState.activated {
            session = WCSession.default()
        }
        else if (session != nil && session!.isReachable) {
            self.updateData(nil)
        }
        self.scheduleBackgroundUpdate()
    }
    
    func updateData(_ task: AnyObject?) {
        session?.sendMessage(["purpose" : "getSchedule"], replyHandler: { (schedule: [String : Any]) in
            print("schedule received")
            if ((schedule["noSchedule"] as AnyObject).boolValue != true) {
                let newSchedule = WatchSchedule()
                newSchedule.name = schedule["name"] as? String
                
                for period in schedule["periods"] as! [[String : AnyObject]] {
                    let newPeriod = WatchSchedulePeriod()
                    newPeriod.name = period["name"] as? String
                    newPeriod.isCustom = period["isCustom"] as! Bool
                    newPeriod.id = period["id"] as! Int
                    newPeriod.isLunch = period["isLunch"] as! Bool
                    newPeriod.isPassingTime = period["isPassingTime"] as! Bool
                    newPeriod.isBeforeSchool = period["isBeforeSchool"] as! Bool
                    newPeriod.isAfterSchool = period["isAfterSchool"] as! Bool
                    newPeriod.startSeconds = period["startSeconds"] as! Int
                    newPeriod.endSeconds = period["endSeconds"] as! Int
                    newPeriod.isLunchPeriod = period["isLunchPeriod"] as! Bool
                    newPeriod.lunchNumber = period["lunchNumber"] as! Int
                    if let realPeriod = period["realPeriod"] as? [String : AnyObject] {
                        let newRealPeriod = WatchPeriod()
                        newRealPeriod.name = realPeriod["name"] as? String
                        newRealPeriod.periodNumber = realPeriod["periodNumber"] as! Int
                        newRealPeriod.teacherName = realPeriod["teacherName"] as? String
                        newRealPeriod.quarters = realPeriod["quarters"] as? String
                        newRealPeriod.id = realPeriod["id"] as! Int
                        newPeriod.realPeriod = newRealPeriod
                    }
                    newSchedule.periods.append(newPeriod)
                }
                WatchAppDailyScheduleManager.sharedInstance.currentSchedule = newSchedule
            }
            else {
                WatchAppDailyScheduleManager.sharedInstance.currentSchedule = nil
            }
            WatchAppDailyScheduleManager.sharedInstance.scheduleSet = true
            NotificationCenter.default.post(name: Notification.Name(rawValue: "scheduleReceived"), object: nil)
            if #available(watchOSApplicationExtension 3.0, *) {
                if task is WKApplicationRefreshBackgroundTask {
                    WKExtension.shared().scheduleSnapshotRefresh(withPreferredDate: Date(), userInfo: nil, scheduledCompletion: { (error: Error?) in
                        if (error == nil) {
                            print("successfully scheduled snapshot update")
                        }
                    })
                    self.scheduleBackgroundUpdate()
                    task?.setTaskCompleted()
                }
            }
            }, errorHandler: { (error: Error?) in
                print("error getting current schedule \(String(describing: error))")
        })
    }
    
    func scheduleBackgroundUpdate() {
        if #available(watchOSApplicationExtension 3.0, *) {
            WKExtension.shared().scheduleBackgroundRefresh(withPreferredDate: Date.init(timeIntervalSinceNow: 10800), userInfo: nil, scheduledCompletion: { (error: Error?) in
                if (error == nil) {
                    print("successfully scheduled background update")
                }
            })
        } else {
            // Fallback on earlier versions
        }
        
    }
    
    func applicationWillResignActive() {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, etc.
    }
    
}
