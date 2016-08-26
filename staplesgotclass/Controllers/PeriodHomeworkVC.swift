//
//  PeriodHomeworkVC.swift
//  staplesgotclass
//
//  Created by Dylan on 8/26/16.
//  Copyright © 2016 Dylan Diamond. All rights reserved.
//

import UIKit

class PeriodHomeworkVC: UITableViewController, HomeworkManagerDelegate {
    
    //Has to be set in the segue in
    var periodNumber: Int?
    
    var homework = [Homework]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //If the current periodNumber is not set, alert then dismiss the controller cuz everythings gonna be fubar'd
        if periodNumber == nil {
            let alert = UIAlertController(title: "ERROR", message: "Failed to set periodNumber", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { Void in
                self.dismissViewControllerAnimated(true, completion: nil)
            }))
            
            presentViewController(alert, animated: true, completion: nil)
        }
        
        self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        HomeworkManager.setup(self)
        HomeworkManager.sharedInstance?.loadSavedData()
    }
    
    //MARK: IBActions
    
    @IBAction func done(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK: Homework Manager Delegate Functions
    func homeworkDidLoad() {
        if let period = periodNumber {
            self.homework = HomeworkManager.sharedInstance?.getHomework(forPeriod: period) ?? [Homework]()
            self.tableView.reloadData()
        }
    }
    
    //MARK: Table View Delegate Functions
    
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: true)
        
        if (editing) {
            //self.tableView.allowsSelectionDuringEditing = true
            self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: self.homework.count, inSection: 0)], withRowAnimation: .Automatic)
        }
        else {
            if (self.tableView.numberOfRowsInSection(0) > self.homework.count) {
                self.tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: self.homework.count, inSection: 0)], withRowAnimation: .Automatic)
            }
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //If editing add a row for the add homework row
        return (self.editing) ? homework.count + 1 : homework.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (self.editing == true && indexPath.row == self.homework.count) {
            let cell = tableView.dequeueReusableCellWithIdentifier("newRowCell", forIndexPath: indexPath)
            cell.textLabel?.text = "Add Homework"
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier("homeworkCell", forIndexPath: indexPath)
        cell.textLabel!.text = homework[indexPath.row].assignment ?? "CORRUPT ASSIGNMENT DATA"
        
        return cell
    }
    
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        if indexPath.row == homework.count {
            return .Insert
        }
        
        return .Delete
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == .Insert) {
            addHomework()
        }
    }
    
    //MARK: Misc Functions
    
    func addHomework() {
        self.performSegueWithIdentifier("addHomeworkSegue", sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "addHomeworkSegue" {
            let setHomeworkView = (segue.destinationViewController as! UINavigationController).topViewController as! SetHomeworkVC
            
            setHomeworkView.periodNumber = self.periodNumber
        }
    }
    
}