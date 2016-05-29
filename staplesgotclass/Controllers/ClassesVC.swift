//
//  ClassesVC.swift
//  staplesgotclass
//
//  Created by Dylan Diamond on 5/21/16.
//  Copyright © 2016 Dylan Diamond. All rights reserved.
//

import UIKit
import Alamofire

class ClassesVC: UITableViewController {
    var myClasses: [Period]?
    var swipeMode = false
    
    var curPeriod: Period?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let sweetBlue = UIColor(red:0.17, green:0.28, blue:0.89, alpha:1.0)
        
        //Turn off extra lines in the table view
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        
        self.navigationController?.navigationBar.barTintColor = sweetBlue
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "HelveticaNeue-Light", size: 16)!, NSForegroundColorAttributeName: UIColor.whiteColor()]
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        self.navigationItem.title = "STAPLES GOT CLASS"
        
        
        if (UserManager.sharedInstance == nil) {
            let loginPage = self.storyboard?.instantiateViewControllerWithIdentifier("loginVC") as! LoginVC
            let nav = UINavigationController(rootViewController: loginPage)
            self.tabBarController?.presentViewController(nav, animated: true, completion: nil)
        }
        
        self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        for item in (self.tabBarController?.tabBar.items)! as [UITabBarItem] {
            if let image = item.image {
                item.image = image.imageWithColor(sweetBlue).imageWithRenderingMode(.AlwaysOriginal)
                item.selectedImage = item.selectedImage!.imageWithColor(sweetBlue).imageWithRenderingMode(.AlwaysOriginal)
                
            }
        }
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: sweetBlue], forState:.Normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: sweetBlue], forState:.Selected)
        
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
                    //                    if (self.myClasses?.count == 0) {
                    //                        let alert = UIAlertController(title: "No Classes!", message: "You have no classes. Please set up your schedule to view your classmates.", preferredStyle: .Alert)
                    //                        let ok = UIAlertAction(title: "OK", style: .Default, handler: nil)
                    //                        alert.addAction(ok)
                    //                        self.presentViewController(alert, animated: true, completion: nil)
                    //                    }
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
        print("set editing \(editing)")
        super.setEditing(editing, animated: true)
        if (!self.swipeMode) {
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
    }
    
    override func tableView(tableView: UITableView, willBeginEditingRowAtIndexPath indexPath: NSIndexPath) {
        self.swipeMode = true
    }
    
    override func tableView(tableView: UITableView, didEndEditingRowAtIndexPath indexPath: NSIndexPath) {
        self.swipeMode = false
    }
    
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        if self.myClasses?.count != 0 {
            self.tableView.separatorStyle = .SingleLine
            self.tableView.backgroundView = nil
            self.navigationItem.rightBarButtonItem?.enabled = true
            return 1
        }
        else {
            // Display a message when the table is empty
            
            let newView: UIView = UIView(frame: CGRectMake(0, 0, self.tableView.frame.width, self.tableView.frame.height))
            
            let coursesIcon: UIImageView = UIImageView(frame: CGRectMake(0, newView.center.y - 150, 100, 100))
            coursesIcon.image = UIImage(named: "coursesPic.png")
            coursesIcon.center.x = newView.center.x
            
            let messageLabel: UILabel = UILabel(frame: CGRectMake(0, newView.center.y - 20, newView.frame.width - 20, 50))
            messageLabel.text = "You have no classes. To create a new one, please tap below."
            messageLabel.textColor = UIColor.blackColor()
            messageLabel.numberOfLines = 0
            messageLabel.textAlignment = .Center
            messageLabel.center.x = newView.center.x
            messageLabel.font = UIFont(name: "Palatino-Italic", size: 20)
            
            let newClassButton: UIButton = UIButton(frame: CGRectMake(0, newView.center.y + 50, 200, 50))
            newClassButton.backgroundColor = UIColor.purpleColor()
            newClassButton.center.x = newView.center.x
            newClassButton.setTitle("New Class", forState: .Normal)
            newClassButton.titleLabel?.textAlignment = .Center
            newClassButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Light", size: 25)
            newClassButton.addTarget(self, action: #selector(ClassesVC.addClass), forControlEvents: .TouchUpInside)
            
            
            newView.addSubview(coursesIcon)
            newView.addSubview(messageLabel)
            newView.addSubview(newClassButton)
            
            self.tableView.backgroundView = newView
            self.tableView.separatorStyle = .None
            self.navigationItem.rightBarButtonItem?.enabled = false
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if (self.myClasses != nil) {
            if (self.editing == true) {
                return self.myClasses!.count + 1
            }
            else {
                return self.myClasses!.count
            }
        }
        else {
            if (self.editing) {
                return 1
            }
            else {
                return 0
            }
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if (self.editing == true && indexPath.row == self.myClasses!.count) {
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
    
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        if self.editing == false {
            print("editing false")
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
        //Smaller row for add class
        if (self.editing && indexPath.row == self.myClasses!.count) {
            return 50
        }
        
        return 70
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        //Here we define the buttons for the table cell swipe
        let edit = UITableViewRowAction(style: .Normal, title: "Edit") { action, index in
            self.curPeriod = self.myClasses![indexPath.row]
            
            print("Edit \(self.curPeriod!.name)")
            
            //Segue to the edit class vc
            self.editing = false
            self.performSegueWithIdentifier("periodSegue", sender: nil)
        }
        edit.backgroundColor = UIColor.orangeColor()
        
        let delete = UITableViewRowAction(style: .Normal, title: "Delete") { action, index in
            let period: Period = self.myClasses![indexPath.row]
            
            print("Delete \(period.name)")
            
            //Delete the class
            //Send the delete request to the server
            
            UserManager.sharedInstance?.currentUser.network.performRequest(withMethod: "POST", endpoint: "delete", parameters: ["id": "\(period.id)"], headers: nil, completion: { (response: Response<AnyObject, NSError>) in
                
                if (response.response?.statusCode == 200) {
                    print("successfully deleted period")
                    
                    self.myClasses?.removeAtIndex(indexPath.row)
                    if (self.myClasses?.count > 0) {
                        self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                        if (self.editing == false) {
                            self.setEditing(false, animated: true)
                        }
                    }
                    else {
                        self.tableView.deleteSections(NSIndexSet(index: 0), withRowAnimation: .None)
                    }
                }
            })
            
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
        if (editingStyle == .Insert) {
            self.performSegueWithIdentifier("periodSegue", sender: nil)
        }
    }
    @IBAction func logout(sender: AnyObject) {
        let loginPage = self.storyboard?.instantiateViewControllerWithIdentifier("loginVC") as! LoginVC
        let nav = UINavigationController(rootViewController: loginPage)
        self.tabBarController?.presentViewController(nav, animated: true, completion: nil)
        
        GIDSignIn.sharedInstance().signOut()
        
    }
    
    func addClass() {
        self.performSegueWithIdentifier("periodSegue", sender: nil)
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
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if (identifier == "showClassmates" && self.editing) {
            let editVC = self.storyboard?.instantiateViewControllerWithIdentifier("editVC") as! EditPeriodVC
            editVC.currentClass = self.myClasses![self.tableView.indexPathForSelectedRow!.row]
            let nav = UINavigationController(rootViewController: editVC)
            self.presentViewController(nav, animated: true, completion: nil)
            return false
        }
        return true
    }
    
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
