//
//  ProfileVC.swift
//  staplesgotclass
//
//  Created by Dylan Diamond on 5/21/16.
//  Copyright © 2016 Dylan Diamond. All rights reserved.
//

import UIKit
import MessageUI

class ProfileVC: UITableViewController, MFMailComposeViewControllerDelegate {
    @IBOutlet var loadingSpinner: UIActivityIndicatorView!
    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var emailLabel: UIButton!
    @IBOutlet var initialLabel: UILabel!
    @IBOutlet var initialView: UIView!
    var currentUser: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.emailLabel.titleLabel!.numberOfLines = 1
        self.emailLabel.titleLabel!.adjustsFontSizeToFitWidth = true
        self.emailLabel.titleLabel!.lineBreakMode = NSLineBreakMode.ByClipping
        
        if (currentUser != nil) {
            self.navigationItem.title = "PROFILE"
            self.nameLabel.text = currentUser!.name
            self.emailLabel.setTitle(currentUser!.email, forState: .Normal)
            
            self.profileImageView.clipsToBounds = true
            self.profileImageView.layer.cornerRadius = self.profileImageView.frame.width / 2
            
            if (currentUser?.profilePicURL != nil && currentUser?.profilePic == nil) {
                profileImageView.downloadedFrom(link: currentUser!.profilePicURL!, contentMode: UIViewContentMode.ScaleAspectFit, userImage: currentUser!)
                self.initialView.hidden = true
                self.profileImageView.hidden = false
            }
            else if (currentUser?.profilePic != nil) {
                profileImageView.image = currentUser!.profilePic!
            }
            else if (currentUser?.profilePicURL == nil) {
                print("setting default pic")
                
                self.initialView.clipsToBounds = true
                self.initialView.layer.cornerRadius = self.initialView.frame.width / 2
                
                let names: [String] = currentUser!.name.componentsSeparatedByString(" ")
                if (names.count >= 3) {
                    self.initialLabel.text = "\(names[0][0].uppercaseString)\(names[1][0].uppercaseString)\(names[2][0].uppercaseString)"
                }
                else if (names.count == 2) {
                    self.initialLabel.text = "\(names[0][0].uppercaseString)\(names[1][0].uppercaseString)"
                    
                }
                else if (names.count == 1) {
                    self.initialLabel.text = "\(names[0][0].uppercaseString))"
                }
                else {
                    self.initialLabel.text = nil
                }
                
                self.profileImageView.hidden = true
                self.initialView.hidden = false
            }
            if (currentUser?.schedule == nil) {
                self.loadingSpinner.startAnimating()
            }
            currentUser?.getClassmates({ (success: Bool) in
                if (success) {
                    self.loadingSpinner.stopAnimating()
                    self.tableView.reloadData()
                    print("schedule count: \(self.currentUser?.schedule?.count)")
                }
                else {
                    print("error getting user's classes")
                    let alert = UIAlertController(title: "Error retrieving classes", message: "Please check your network connection and try again.", preferredStyle: .Alert)
                    let dismiss = UIAlertAction(title: "Dismiss", style: .Default, handler: nil)
                    alert.addAction(dismiss)
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            })
            
        }
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "ProfileView")
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject: AnyObject])
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (currentUser?.schedule != nil) {
            return currentUser!.schedule!.count
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 55
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Schedule"
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("profileClassCell", forIndexPath: indexPath) as! ClassCell
        
        cell.classTitleLabel.text = currentUser!.schedule![indexPath.row].name
        cell.periodNumberLabel.text = "\(currentUser!.schedule![indexPath.row].periodNumber)"
        cell.quarterLabel.text = "\(currentUser!.schedule![indexPath.row].quarters)"
        cell.teacherLabel.text = currentUser!.schedule![indexPath.row].teacherName
        
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let classmatesVC = self.storyboard?.instantiateViewControllerWithIdentifier("classmatesVC") as! ClassmatesVC
        classmatesVC.currentClass = self.currentUser!.schedule![indexPath.row]
        let backButton = UIBarButtonItem(title: " ", style: .Plain, target: nil, action: nil)
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.navigationItem.backBarButtonItem = backButton
        self.navigationController?.pushViewController(classmatesVC, animated: true)
    }
    
    @IBAction func emailUser(sender: AnyObject) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients([self.currentUser!.email])
            mail.setSubject("StaplesGotClass Email")
            presentViewController(mail, animated: true, completion: nil)
        } else {
            // show failure alert
        }
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
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
