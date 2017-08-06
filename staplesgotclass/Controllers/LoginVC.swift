//
//  ViewController.swift
//  staplesgotclass
//
//  Created by Dylan Diamond on 5/18/16.
//  Copyright © 2016 Dylan Diamond. All rights reserved.
//

import UIKit
import Alamofire

class LoginVC: UIViewController, GIDSignInUIDelegate, GIDSignInDelegate, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        //<#code#>
    }

    @IBOutlet var signInButton: GIDSignInButton!
    @IBOutlet var pageVCHolder: UIView!
    @IBOutlet var pageVCIndicator: UIPageControl!
    
    var pageVC: UIPageViewController!
    var pageTitles: [String]!
    var pageDescriptions: [String]!
    var imageNames: [String]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barTintColor = UIColor(red:0.17, green:0.28, blue:0.89, alpha:1.0)
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "HelveticaNeue-Light", size: 16)!, NSForegroundColorAttributeName: UIColor.white]
        UIApplication.shared.statusBarStyle = .lightContent
        
        GIDSignIn.sharedInstance().delegate = nil
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
//        GIDSignIn.sharedInstance().signInSilently()
        
        
        self.pageVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginPageVC") as! UIPageViewController
        self.pageVC.dataSource = self
        self.pageVC.delegate = self
        
        self.pageTitles = ["iStaples", "Discover", "Compare", "Explore"]
        self.pageDescriptions = ["", "Discover new people and find your future classmates.", "After setting up your account, visit the Classmates page to compare your classes with the classes of your friends.", "To start, add your class schedule information to your profile after signing in with your school Google account."]
        self.imageNames = ["appIcon.png", "globe.png", "sync.png", "profile.png"]
        self.pageVCIndicator.numberOfPages = self.pageTitles.count
        self.pageVCIndicator.currentPage = 0
        
        let firstPageContentVC = self.viewControllerAtIndex(0)
        let pageViewControllers: [UIViewController] = [firstPageContentVC!]
        self.pageVC.setViewControllers(pageViewControllers, direction: UIPageViewControllerNavigationDirection.forward, animated: true, completion: nil)
        self.pageVC.view.frame = self.pageVCHolder.frame
        self.addChildViewController(self.pageVC)
        self.pageVCHolder.addSubview(self.pageVC.view)
        self.pageVC.didMove(toParentViewController: self)
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: "SignIn")
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker?.send(builder?.build() as! [AnyHashable: Any])
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Page VC Delegates
    
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        let vc = viewController as! PageContentVC
        var index = vc.pageIndex!
        
        
        if ((index == 0) || (index == NSNotFound)) {
            return nil;
        }
        
        index -= 1
        return self.viewControllerAtIndex(index)
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
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
    
    func viewControllerAtIndex(_ index: Int) -> PageContentVC? {
        if ((self.pageTitles.count == 0) || (index >= self.pageTitles.count)) {
            return nil;
        }
        
        let newPageVC = self.storyboard?.instantiateViewController(withIdentifier: "PageContentVC") as! PageContentVC
        if self.imageNames.count > index {
        newPageVC.imageName = self.imageNames[index]
        }
        newPageVC.titleText = self.pageTitles[index]
        print("title: \(self.pageTitles[index])")
        newPageVC.pageIndex = index
        
        newPageVC.descriptionText = self.pageDescriptions[index]
        
        return newPageVC
        
    }
    
//    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
//        return self.pageTitles.count
//    }
//    
//    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
//        return 0
//    }
//    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        // If user bailed our early from the gesture,
        // we have to revert page control to previous position
        if !completed {
            let pageContentView = previousViewControllers[0] as! PageContentVC;
            self.pageVCIndicator.currentPage = pageContentView.pageIndex!;
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        let pageContentView: PageContentVC = (pendingViewControllers[0] as! PageContentVC)
        self.pageVCIndicator.currentPage = pageContentView.pageIndex!
    }
    
    // Present a view that prompts the user to sign in with Google
    func sign(_ signIn: GIDSignIn!,
                present viewController: UIViewController!) {
        print("sign in ui delegate")
        self.present(viewController, animated: true, completion: nil)
    }
    
    // Dismiss the "Sign in with Google" view
    func sign(_ signIn: GIDSignIn!,
                dismiss viewController: UIViewController!) {
        self.dismiss(animated: true, completion: nil)
    }

    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
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
            
            let emailDomain = user.profile.email.components(separatedBy: "@").last
            if (emailDomain?.contains("westport.k12.ct.us") == true) {
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
                
                
                var profilePicURL: String?
                
                if (user.profile.hasImage) {
                    profilePicURL = user.profile.imageURL(withDimension: 250).absoluteString
                    print(profilePicURL as Any)
                }

                UserManager.createCurrentUser(user.profile.name, email: user.profile.email, token: user.authentication.idToken, profilePicURL: profilePicURL, completion: { (success: Bool) in
                    if (success) {
                        print("success in login screen!")
                        GIDSignIn.sharedInstance().delegate = nil
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "loggedIn"), object: nil)
                        self.dismiss(animated: true, completion: nil)
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
            print("\(error.localizedDescription)")
            let alert = UIAlertController(title: "Error signing in", message: "Please try again.", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user:GIDGoogleUser!,
                withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // ...
    }
    
    
}

