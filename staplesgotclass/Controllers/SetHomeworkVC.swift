//
//  SetHomeworkVC.swift
//  staplesgotclass
//
//  Created by Dylan on 8/25/16.
//  Copyright © 2016 Dylan Gleicher. All rights reserved.
//

import UIKit

class SetHomeworkVC: UITableViewController, UITextFieldDelegate {
    
    @IBOutlet weak var assignmentTextField: UITextField!
    @IBOutlet weak var dueDateLabel: UILabel!
    
    var dueDate: NSDate?
    
    //Course has to be set in the segue in
    var periodID: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        assignmentTextField.delegate = self
    }
    
    //MARK: IBActions
    
    @IBAction func save(sender: AnyObject) {
        if let date = dueDate {
            if assignmentTextField.text != nil && assignmentTextField.text != "" {
                if let currentPeriod = self.periodID {
                    HomeworkManager.setHomework(forPeriod: currentPeriod, assignment: assignmentTextField.text!, dueDate: date)
                    
                    self.dismissViewControllerAnimated(true, completion: nil)
                    
                } else {
                    presentAlert(withTitle: "Error", text: "Corrupt period data")
                }
                
            } else {
                presentAlert(withTitle: "Error", text: "Please input an assignment")
            }
        } else {
            presentAlert(withTitle: "Error", text: "Please set a valid date")
        }
    }
    
    @IBAction func cancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK: Table View Delegate Functions
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 1 {
            //Date row picked
            datePickerPressed()
        }
    }
    
    //MARK: Text Field Delegate Functions
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    //MARK: Misc functions
    
    func datePickerPressed() {
        DatePickerDialog().show(title: "Due Date", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", datePickerMode: .Date) {
            (date) -> Void in
            self.dueDate = date
            self.dueDateLabel.text = "\(date)"
        }
    }
    
    func presentAlert(withTitle title: String, text: String) {
        let alert = UIAlertController(title: title, message: text, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
        
        presentViewController(alert, animated: true, completion: nil)
    }
}