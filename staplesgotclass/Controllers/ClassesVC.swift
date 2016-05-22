//
//  ClassesVC.swift
//  staplesgotclass
//
//  Created by Dylan Diamond on 5/21/16.
//  Copyright © 2016 Dylan Diamond. All rights reserved.
//

import UIKit

class ClassesVC: UITableViewController {
    var myClasses: [Period]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barTintColor = UIColor(red:0.13, green:0.43, blue:0.81, alpha:1.0)
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "HelveticaNeue-Light", size: 16)!, NSForegroundColorAttributeName: UIColor.whiteColor()]
        UIApplication.sharedApplication().statusBarStyle = .LightContent

        
        if (UserManager.sharedInstance == nil) {
            let loginPage = self.storyboard?.instantiateViewControllerWithIdentifier("loginVC") as! LoginVC
            self.tabBarController?.presentViewController(loginPage, animated: true, completion: nil)
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        print("view did appear")
        if (UserManager.sharedInstance != nil) {
            UserManager.sharedInstance?.currentUser.getClassmates({ (success: Bool) in
                if (success) {
                    print("success in view did appear")
                    self.myClasses = UserManager.sharedInstance?.currentUser.schedule
                    self.tableView.reloadData()
                }
            })
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if (self.myClasses != nil) {
            print("not nil count: \(self.myClasses!.count)")
            return self.myClasses!.count
        }
        else {
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("classCell", forIndexPath: indexPath) as! ClassCell
        
        cell.classTitleLabel.text = self.myClasses![indexPath.row].name
        cell.periodNumberLabel.text = "\(self.myClasses![indexPath.row].periodNumber)"
        cell.quarterLabel.text = "\(self.myClasses![indexPath.row].quarters)"
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let height = Double(self.tableView.frame.height - 55) / Double((self.myClasses?.count)!)
        if (height < 44) {
            return 44
        }
        else {
            return CGFloat(height)
        }
        
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
        if (segue.identifier == "showClassmates") {
            let newView = segue.destinationViewController as! ClassmatesVC
            newView.currentClass = self.myClasses![(self.tableView.indexPathForSelectedRow?.row)!]
            let backButton = UIBarButtonItem(title: " ", style: .Plain, target: nil, action: nil)
            
            self.navigationItem.backBarButtonItem = backButton
            self.tableView.deselectRowAtIndexPath(self.tableView.indexPathForSelectedRow!, animated: true)
            
        }
     }
 
    
}
