//
//  ClassmatesVC.swift
//  staplesgotclass
//
//  Created by Dylan Diamond on 5/21/16.
//  Copyright © 2016 Dylan Diamond. All rights reserved.
//

import UIKit
import SDWebImage

class ClassmatesVC: UITableViewController {
    @IBOutlet var teacherNameLabel: UILabel!
    @IBOutlet var quarterLabel: UILabel!
    var currentClass: Period?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (currentClass != nil) {
            self.navigationItem.title = currentClass!.name.uppercaseString
            self.teacherNameLabel.text = currentClass!.teacherName
            self.quarterLabel.text = "\(currentClass!.periodNumber) • Marking Periods: \(currentClass!.quarters)"
            self.tableView.reloadData()
        }
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "ClassmatesView")
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject: AnyObject])
    }
    
    //    override func viewWillDisappear(animated: Bool) {
    //        self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "HelveticaNeue-Medium", size: 20)!, NSForegroundColorAttributeName: UIColor.whiteColor()]
    //
    //    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (self.currentClass != nil) {
            return "\(self.currentClass!.users.count) Classmates"
        }
        return nil
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if (currentClass?.users != nil) {
            return currentClass!.users.count
        }
        return 0
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("classmatesCell", forIndexPath: indexPath) as! ClassmateCell
        
        cell.nameLabel.text = self.currentClass?.users[indexPath.row].name
        
        cell.contentView.layoutIfNeeded()

        cell.classmateImageView.clipsToBounds = true
        cell.classmateImageView.layer.cornerRadius = cell.classmateImageView.frame.width / 2
        
        cell.initialView.clipsToBounds = true
        cell.initialView.layer.cornerRadius = cell.initialView.frame.width / 2
        
        if (self.currentClass!.users[indexPath.row].profilePicURL != nil) {
            cell.classmateImageView.sd_setImageWithURL(NSURL(string:self.currentClass!.users[indexPath.row].profilePicURL!), completed: { (image: UIImage!, error: NSError!, cacheType: SDImageCacheType, url: NSURL!) in
                if (error == nil && image != nil) {
                    //now that image is downloaded, set current user prof pic
                    self.currentClass!.users[indexPath.row].profilePic = image
                    if (image.images?.count > 1) {
                        cell.classmateImageView.image = image.images?.first
                    }
                }
                else {
                    print("sd web image error: \(error)")
                }
            })
            
            cell.classmateImageView.hidden = false
            cell.initialView.hidden = true
        }
        else {
            let names: [String] = self.currentClass!.users[indexPath.row].name.componentsSeparatedByString(" ")
            if (names.count >= 3) {
                cell.initialLabel.text = "\(names[0][0].uppercaseString)\(names[1][0].uppercaseString)\(names[2][0].uppercaseString)"
            }
            else if (names.count == 2) {
                cell.initialLabel.text = "\(names[0][0].uppercaseString)\(names[1][0].uppercaseString)"
                
            }
            else if (names.count == 1) {
                cell.initialLabel.text = "\(names[0][0].uppercaseString)"
            }
            else{
                cell.initialLabel.text = nil
            }
            cell.classmateImageView.hidden = true
            cell.initialView.hidden = false
        }
        
        
        // Configure the cell...
        
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
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "showProfile") {
            let newView = segue.destinationViewController as! ProfileVC
            let selectedIndexPath = self.tableView.indexPathForSelectedRow
            newView.currentUser = self.currentClass?.users[(selectedIndexPath?.row)!]
            [(self.tableView.indexPathForSelectedRow?.row)!]
            
            let backButton = UIBarButtonItem(title: " ", style: .Plain, target: nil, action: nil)
            
            self.navigationItem.backBarButtonItem = backButton
            
            self.tableView.deselectRowAtIndexPath(self.tableView.indexPathForSelectedRow!, animated: true)
            
        }
        
    }
    
    
}
