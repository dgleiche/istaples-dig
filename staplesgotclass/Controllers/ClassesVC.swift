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
    
    var curPeriod: Period?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barTintColor = UIColor(red:0.17, green:0.28, blue:0.89, alpha:1.0)
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "HelveticaNeue-Light", size: 16)!, NSForegroundColorAttributeName: UIColor.whiteColor()]
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        self.navigationItem.title = "STAPLES GOT CLASS"

        
        if (UserManager.sharedInstance == nil) {
            let loginPage = self.storyboard?.instantiateViewControllerWithIdentifier("loginVC") as! LoginVC
            self.tabBarController?.presentViewController(loginPage, animated: true, completion: nil)
        }
        
        self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        print("view did appear")
        
        //Resets this as to not save the last edited per
        curPeriod = nil
        
        if (UserManager.sharedInstance != nil) {
            UserManager.sharedInstance?.currentUser.getClassmates({ (success: Bool) in
                if (success) {
                    print("success in view did appear")
                    self.myClasses = UserManager.sharedInstance?.currentUser.schedule
                    if (self.myClasses?.count == 0) {
                        let alert = UIAlertController(title: "No Classes!", message: "You have no classes. Please set up your schedule to view your classmates.", preferredStyle: .Alert)
                        let ok = UIAlertAction(title: "OK", style: .Default, handler: nil)
                        alert.addAction(ok)
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
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
    
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: true)
        if (editing) {
            self.tableView.allowsSelectionDuringEditing = true
        self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: self.myClasses!.count, inSection: 0)], withRowAnimation: .Automatic)
        }
        else {
            if (self.tableView.numberOfRowsInSection(0) > self.myClasses!.count) {
            self.tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: self.myClasses!.count, inSection: 0)], withRowAnimation: .Automatic)
            }
        }
    }

    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if (self.myClasses != nil) {
            print("not nil count: \(self.myClasses!.count)")
            if (self.tableView.editing) {
            return self.myClasses!.count + 1
            }
            else {
                return self.myClasses!.count
            }
        }
        else {
            if (self.tableView.editing) {
                return 1
            }
            else {
            return 0
            }
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if (self.editing && indexPath.row == self.myClasses!.count) {
            let cell = tableView.dequeueReusableCellWithIdentifier("newRowCell", forIndexPath: indexPath)
            cell.textLabel?.text = "Add Class"
            return cell
        }
        else {
        let cell = tableView.dequeueReusableCellWithIdentifier("classCell", forIndexPath: indexPath) as! ClassCell
        cell.classTitleLabel.text = self.myClasses![indexPath.row].name
        cell.periodNumberLabel.text = "\(self.myClasses![indexPath.row].periodNumber)"
        cell.quarterLabel.text = "\(self.myClasses![indexPath.row].quarters)"
        cell.teacherLabel.text = self.myClasses![indexPath.row].teacherName
        
        return cell
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (self.tableView.editing && indexPath.row == self.myClasses!.count) {
//            let alert = UIAlertController(title: "Add class", message: nil, preferredStyle: .Alert)
//            let ok = UIAlertAction(title: "OK", style: .Default, handler: nil)
//            alert.addAction(ok)
//            self.presentViewController(alert, animated: true, completion: nil)
            
            
        }
        else if (self.tableView.editing) {
            
        }
    }
    
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        if self.editing == false {
            return .Delete
        }
        else if self.editing && indexPath.row == (self.myClasses!.count) {
            return .Insert
        }
        else {
            return .Delete
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let height = Double(self.tableView.frame.height - 55) / Double((self.myClasses?.count)!)
        if (height < 55) {
            return 55
        }
        else {
            return CGFloat(height)
        }
        
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        //Here we define the buttons for the table cell swipe
        let edit = UITableViewRowAction(style: .Normal, title: "Edit") { action, index in
            self.curPeriod = self.myClasses![indexPath.row]
            
            print("Edit \(self.curPeriod!.name)")
            
            //Segue to the edit class vc
            self.tableView.editing = false
            self.performSegueWithIdentifier("periodSegue", sender: nil)
        }
        edit.backgroundColor = UIColor.blueColor()
        
        let delete = UITableViewRowAction(style: .Normal, title: "Delete") { action, index in
            let period: Period = self.myClasses![indexPath.row]
            
            print("Delete \(period.name)")
            
            //Delete the class. TODO: Add a confirm
            //Send the delete request to the server
            
            //Upon completion of the delete request reload the table 
        }
        delete.backgroundColor = UIColor.redColor()
        
        return [delete, edit]
    }
    
    //These methods allows the swipes to occur
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    }
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
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
//            self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "HelveticaNeue-Light", size: 16)!, NSForegroundColorAttributeName: UIColor.whiteColor()]

            
        } else if (segue.identifier == "periodSegue") {
            if curPeriod != nil {
                let newView = (segue.destinationViewController as! UINavigationController).topViewController as! EditPeriodVC
                newView.currentClass = self.curPeriod!
            }
        }
     }
    
    //Allow cancel button to segue back here
    @IBAction func unwindToClassesView(sender: UIStoryboardSegue) {
        
    }
 
    
}
