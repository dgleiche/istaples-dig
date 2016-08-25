//
//  SetHomeworkVC.swift
//  staplesgotclass
//
//  Created by Dylan on 8/25/16.
//  Copyright © 2016 Dylan Gleicher. All rights reserved.
//

import UIKit

class SetHomeworkVC: UITableViewController {
    
    @IBOutlet weak var assignmentTextField: UITextField!
    @IBOutlet weak var dueDateLabel: UILabel!
    
    var dueDate: NSDate?
    
    //Course has to be set in the segue in
    var course: Course?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func save(sender: AnyObject) {
        if let date = dueDate {
            if assignmentTextField.text != nil && assignmentTextField.text != "" {
                if let currentCourse = self.course {
                    
                }
                //HomeworkManager.sharedInstance?.setHomework(forCourse: <#T##Course#>, assignment: <#T##String#>, dueDate: <#T##NSDate#>)
                
            } else {
                //TODO: Alert
                print("ASSIGNMENT TEXT NOT SET SHOW ALERT")
            }
        } else {
            //TODO: Alert
            print("DATE NOT SET SHOW ALERT")
        }
    }
}