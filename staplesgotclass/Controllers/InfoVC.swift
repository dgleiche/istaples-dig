//
//  InfoVC.swift
//  staplesgotclass
//
//  Created by Dylan on 5/30/16.
//  Copyright © 2016 Dylan Diamond. All rights reserved.
//

import UIKit
import MessageUI

class InfoVC: UITableViewController, MFMailComposeViewControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.barTintColor = UIColor(red:0.13, green:0.42, blue:0.81, alpha:1.0)
        self.navigationController?.navigationBar.translucent = false
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "AppleSDGothicNeo-UltraLight", size: 15)!, NSForegroundColorAttributeName: UIColor.whiteColor()]
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        let backButton = UIBarButtonItem(title: " ", style: .Plain, target: nil, action: nil)
        
        self.navigationItem.backBarButtonItem = backButton

        self.navigationItem.title = "INFO"
    }
    
    func logout() {
        self.dismissViewControllerAnimated(true, completion: nil)
        NSNotificationCenter.defaultCenter().postNotificationName("logout", object: nil)
    }
    
    func sendMail(address: String) {
        let toRecipents = [address]
        let mc: MFMailComposeViewController = MFMailComposeViewController()
        mc.mailComposeDelegate = self
        mc.setToRecipients(toRecipents)
        mc.setSubject("Staples Got Class App")
        mc.setMessageBody("\n\nFrom,\n\(UserManager.sharedInstance!.currentUser.name)", isHTML: false)
        
        self.presentViewController(mc, animated: true, completion: nil)
    }
    
    func mailComposeController(controller:MFMailComposeViewController, didFinishWithResult result:MFMailComposeResult, error:NSError?) {
        switch result {
        case MFMailComposeResultCancelled:
            print("Mail cancelled")
        case MFMailComposeResultSaved:
            print("Mail saved")
        case MFMailComposeResultSent:
            print("Mail sent")
        case MFMailComposeResultFailed:
            print("Mail sent failure: \(error?.localizedDescription)")
        default:
            break
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK: Table View Functions
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1 && indexPath.row == 0 {
            UIApplication.sharedApplication().openURL(NSURL(string: "http://staplesgotclass.com")!)
        }
        else if indexPath.section == 2 {
            switch indexPath.row {
            case 0:
                print("Email Diamond")
                sendMail("dylan@dcdwebdesign.com")
            case 1:
                print("Email Gleicher")
                sendMail("dgleiche@me.com")
            case 2:
                print("Email Neal")
                sendMail("ns51387@students.westport.k12.ct.us")
            default:
                break
            }
        }
        
        else if indexPath.section == 3 {
            //Log out button
            print("logout")
            logout()
        }
        
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    //MARK: Navigation
    
    
    @IBAction func donePressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    //Set the text for the two info things
    
    let aboutText = "Staples Got Class allows students of Staples High School to track their classes and their classmates. This app is designed to be easier and more mobile than the web interface, staplesgotclass.com. You can also view your friends' schedules, along with their classmates."
    
    let securityText = "This app works by logging you in to our servers through a token generated by a Google OAuth login. As Google OAuth is utilized, passwords are NOT NOR COULD BE at any time stored or accessed by this app. Google handles all credentials, thus the security of this app is the security of a Google log in. \n \nBy using this app, you agree that anonymous analytic data may be collected to help improve future use of Staples Got Class."
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "aboutSegue" {
            let newView = segue.destinationViewController as! AboutVC
            
            newView.title = "About SHS Got Class"
            newView.text = aboutText
        }
        
        else if segue.identifier == "securitySegue" {
            let newView = segue.destinationViewController as! AboutVC
            
            newView.title = "Security Information"
            newView.text = securityText
        }
    }
}
