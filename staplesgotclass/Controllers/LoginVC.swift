//
//  ViewController.swift
//  staplesgotclass
//
//  Created by Dylan Diamond on 5/18/16.
//  Copyright © 2016 Dylan Diamond. All rights reserved.
//

import UIKit
import Alamofire

class LoginVC: UIViewController, GIDSignInUIDelegate, GIDSignInDelegate, UIPageViewControllerDataSource {
    @IBOutlet var signInButton: GIDSignInButton!
    @IBOutlet var pageVCHolder: UIView!
    
    var pageVC: UIPageViewController!
    var pageTitles: [String]!
    var imageNames: [String]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().signInSilently()
        
        self.pageVC = self.storyboard?.instantiateViewControllerWithIdentifier("LoginPageVC") as! UIPageViewController
        self.pageVC.dataSource = self
        
        self.pageTitles = ["Page 1", "Page 2", "Page 3"]
        self.imageNames = ["shs.jpg"]
        
        let firstPageContentVC = self.viewControllerAtIndex(0)
        let pageViewControllers: [UIViewController] = [firstPageContentVC!]
        self.pageVC.setViewControllers(pageViewControllers, direction: UIPageViewControllerNavigationDirection.Forward, animated: true, completion: nil)
        self.pageVC.view.frame = self.pageVCHolder.frame
        self.addChildViewController(self.pageVC)
        self.pageVCHolder.addSubview(self.pageVC.view)
        self.pageVC.didMoveToParentViewController(self)
        
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "SignIn")
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject: AnyObject])
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Page VC Delegates
    
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        
        let vc = viewController as! PageContentVC
        var index = vc.pageIndex!
        
        
        if ((index == 0) || (index == NSNotFound)) {
            return nil;
        }
        
        index -= 1
        return self.viewControllerAtIndex(index)
        
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        
        let vc = viewController as! PageContentVC
        var index = vc.pageIndex!
        
        
        if (index == NSNotFound) {
            return nil;
        }
        index += 1
        
        if (index == self.pageTitles.count) {
            return nil
        }
        
        return self.viewControllerAtIndex(index)
        
    }
    
    func viewControllerAtIndex(index: Int) -> PageContentVC? {
        if ((self.pageTitles.count == 0) || (index >= self.pageTitles.count)) {
            return nil;
        }
        
        let newPageVC = self.storyboard?.instantiateViewControllerWithIdentifier("PageContentVC") as! PageContentVC
        if self.imageNames.count > index {
        newPageVC.imageName = self.imageNames[index]
        }
        newPageVC.titleText = self.pageTitles[index]
        print("title: \(self.pageTitles[index])")
        newPageVC.pageIndex = index
        
        return newPageVC
        
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return self.pageTitles.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
    func signIn(signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!,
                withError error: NSError!) {
        if (error == nil) {
            print("email: \(user.profile.email)")
            // Perform any operations on signed in user here.
            //            let userId = user.userID                  // For client-side use only!
            //            let idToken = user.authentication.idToken // Safe to send to the server
            //            let fullName = user.profile.name
            //            let givenName = user.profile.givenName
            //            let familyName = user.profile.familyName
            //            let email = user.profile.email
            // ...
            
            let emailDomain = user.profile.email.componentsSeparatedByString("@").last
            if (emailDomain?.containsString("westport.k12.ct.us") == true) {
                print("confirmed wepo")
                
                //                Alamofire.request(.POST, "http://localhost:9292/api/validateUser", parameters: ["token": user.authentication.idToken])
                //
                //                    .responseJSON { response in
                //                        print(response.request)  // original URL request
                //                        print(response.response) // URL response
                //                        print(response.data)     // server data
                //                        print(response.result)   // result of response serialization
                //                        print(response.result.error)
                //                        if let JSON = response.result.value {
                //                            print("JSON: \(JSON)")
                //                        }
                //                }
                
                    let profilePicURL = user.profile.imageURLWithDimension(250).absoluteString
                    print(profilePicURL)
                                    
                UserManager.createCurrentUser(user.profile.name, email: user.profile.email, token: user.authentication.idToken, profilePicURL: profilePicURL, completion: { (success: Bool) in
                    if (success) {
                        print("success!")
                        self.dismissViewControllerAnimated(true, completion: nil)
                        
                    }
                    else {
                        print("error...:(")
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
            print("\(error.localizedDescription)")
        }
    }
    
    
    func signIn(signIn: GIDSignIn!, didDisconnectWithUser user:GIDGoogleUser!,
                withError error: NSError!) {
        // Perform any operations when the user disconnects from app here.
        // ...
    }
    
    
}

