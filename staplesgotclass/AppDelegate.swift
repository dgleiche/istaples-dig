//
//  AppDelegate.swift
//  staplesgotclass
//
//  Created by Dylan Diamond on 5/18/16.
//  Copyright © 2016 Dylan Diamond. All rights reserved.
//

import UIKit
import Parse
import RealmSwift
import WatchConnectivity
import UserNotifications
import GoogleMobileAds



@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    var defaults = UserDefaults.standard
    
    var session: WCSession? {
        didSet {
            if let session = session {
                session.delegate = self
                session.activate()
            }
        }
    }
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        var configureError: NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google services: \(String(describing: configureError))")
        
        GADMobileAds.configure(withApplicationID: "ca-app-pub-9482699020493042~4926142487")

        
        let configuration = ParseClientConfiguration {
            $0.applicationId = "ZgeDasDpmqNAakqJcK0C"
            $0.clientKey = "FXPR1dw5x9jbPyFJw53y"
            $0.server = "https://staplesscheduleserver.herokuapp.com/parse"
            $0.networkRetryAttempts = 2
        }
        Parse.initialize(with: configuration)
        
        // Inside your application(application:didFinishLaunchingWithOptions:)
        
        let config = Realm.Configuration(
            // Set the new schema version. This must be greater than the previously used
            // version (if you've never set a schema version before, the version is 0).
            schemaVersion: 9,
            
            // Set the block which will be called automatically when opening a Realm with
            // a schema version lower than the one set above
            migrationBlock: { migration, oldSchemaVersion in
                // We haven’t migrated anything yet, so oldSchemaVersion == 0
                if (oldSchemaVersion < 1) {
                    // Nothing to do!
                    // Realm will automatically detect new properties and removed properties
                    // And will update the schema on disk automatically
                }
        })
        
        // Tell Realm to use this new configuration object for the default Realm
        Realm.Configuration.defaultConfiguration = config
        
        // Now that we've told Realm how to handle the schema change, opening the file
        // will automatically perform the migration
        _ = try! Realm()
        
        
        if WCSession.isSupported() {
            session = WCSession.default()
        }
        registerForPushNotifications()
        StoreManager.shared.setup()
        return true
    }
    
    func application(_ application: UIApplication,
                     open url: URL, options: [UIApplicationOpenURLOptionsKey: Any]) -> Bool {
            return GIDSignIn.sharedInstance().handle(url,
                                                        sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
                                                        annotation: options[UIApplicationOpenURLOptionsKey.annotation])
        
    }
    
    func application(_ application: UIApplication,
                     open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return GIDSignIn.sharedInstance().handle(url,
                                                    sourceApplication: sourceApplication,
                                                    annotation: annotation)
    }
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }
        
        let token = tokenParts.joined()
        print("Device Token: \(token)")
    }
    
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)")
    }
    
    
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    func registerForPushNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
            (granted, error) in
            print("Permission granted: \(granted)")
            
            guard granted else { return }
            self.getNotificationSettings()
        }
    }
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            print("Notification settings: \(settings)")
            guard settings.authorizationStatus == .authorized else { return }
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
    
    
}

extension AppDelegate: WCSessionDelegate {
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    @available(iOS 9.3, *)
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        DispatchQueue.main.async {
            if (message["purpose"] as? String == "getSchedule") {
                //get the current schedule and associated periods
                if (DailyScheduleManager.sharedInstance != nil) {
                    if let currentSchedule = DailyScheduleManager.sharedInstance?.currentSchedule {
                        var replyDictionary = [String : AnyObject]()
                        replyDictionary["name"] = currentSchedule.name as AnyObject
                        replyDictionary["noSchedule"] = false as AnyObject
                        var periodsArray = [AnyObject]()
                        for period in currentSchedule.periods {
                            var newPeriodDict = [String : AnyObject]()
                            newPeriodDict["name"] = period.name as AnyObject
                            newPeriodDict["isCustom"] = period.isCustom as AnyObject
                            newPeriodDict["id"] = period.id as AnyObject
                            newPeriodDict["isLunch"] = period.isLunch as AnyObject
                            newPeriodDict["isPassingTime"] = period.isPassingTime as AnyObject
                            newPeriodDict["isBeforeSchool"] = period.isBeforeSchool as AnyObject
                            newPeriodDict["isAfterSchool"] = period.isAfterSchool as AnyObject
                            newPeriodDict["startSeconds"] = period.startSeconds as AnyObject
                            newPeriodDict["endSeconds"] = period.endSeconds as AnyObject
                            newPeriodDict["isLunchPeriod"] = period.isLunchPeriod as AnyObject
                            newPeriodDict["lunchNumber"] = period.lunchNumber as AnyObject
                            if let realPeriod = period.realPeriod {
                                var realPeriodDict = [String : AnyObject]()
                                realPeriodDict["name"] = realPeriod.name as AnyObject
                                realPeriodDict["periodNumber"] = realPeriod.periodNumber as AnyObject
                                realPeriodDict["teacherName"] = realPeriod.teacherName as AnyObject
                                realPeriodDict["quarters"] = realPeriod.quarters as AnyObject
                                realPeriodDict["id"] = realPeriod.id as AnyObject
                                newPeriodDict["realPeriod"] = realPeriodDict as AnyObject
                            }
                            periodsArray.append(newPeriodDict as AnyObject)
                        }
                        replyDictionary["periods"] = periodsArray as AnyObject
                        print("sending reply: \(replyDictionary)")
                        replyHandler(replyDictionary)
                    }
                    else {
                        replyHandler(["noSchedule" : true])
                    }
                    
                }
                else {
                    replyHandler(["noSchedule" : true])
                }
            }
        }
    }
    
}


extension UIApplication {
    class func topViewController(_ base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        
        if let nav = base as? UINavigationController {
            return topViewController(nav.visibleViewController)
        }
        
        if let tab = base as? UITabBarController {
            let moreNavigationController = tab.moreNavigationController
            
            if let top = moreNavigationController.topViewController, top.view.window != nil {
                return topViewController(top)
            } else if let selected = tab.selectedViewController {
                return topViewController(selected)
            }
        }
        
        if let presented = base?.presentedViewController {
            return topViewController(presented)
        }
        
        return base
    }
}
