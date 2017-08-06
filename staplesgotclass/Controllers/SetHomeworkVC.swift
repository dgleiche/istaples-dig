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
    
    var dueDate: Date?
    
    //Course has to be set in the segue in
    var periodNumber: Int?
    
    //Set if it's in edit mode
    var curHomework: Homework?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        assignmentTextField.delegate = self
        
        if let homework = curHomework {
            assignmentTextField.text = homework.assignment
            dueDate = homework.dueDate as! Date
            
            updateDueDateLabel()
        }
    }
    
    //MARK: IBActions
    
    @IBAction func save(_ sender: AnyObject) {
        if let date = dueDate {
            if assignmentTextField.text != nil && assignmentTextField.text != "" {
                if let currentPeriod = self.periodNumber {
                    
                    if self.curHomework != nil {
                        HomeworkManager.update(homework: curHomework!, assignment: assignmentTextField.text!, dueDate: date)
                    } else {
                        HomeworkManager.setHomework(forPeriod: currentPeriod, assignment: assignmentTextField.text!, dueDate: date)
                    }
                    
                    self.dismiss(animated: true, completion: nil)
                    
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
    
    @IBAction func cancel(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: Table View Delegate Functions
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 1 {
            //Date row picked
            datePickerPressed()
        }
    }
    
    //MARK: Text Field Delegate Functions
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    //MARK: Misc functions
    
    func datePickerPressed() {
        DatePickerDialog().show(title: "Due Date", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", datePickerMode: .date) {
            (pickedDate) -> Void in
            if let date = pickedDate {
                self.dueDate = date as Date
                
                self.updateDueDateLabel()
            }
        }
    }
    
    func updateDueDateLabel() {
        if let date = dueDate {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "E MMM dd, yyyy"
            
            dueDateLabel.text = dateFormatter.string(from: date)
        }
    }
    
    func presentAlert(withTitle title: String, text: String) {
        let alert = UIAlertController(title: title, message: text, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
}
