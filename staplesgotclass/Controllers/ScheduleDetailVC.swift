//
//  ScheduleDetailVC.swift
//  staplesgotclass
//
//  Created by Dylan Diamond on 8/26/16.
//  Copyright © 2016 Dylan Diamond. All rights reserved.
//

import UIKit

class ScheduleDetailVC: UITableViewController, HomeworkManagerDelegate {
    @IBOutlet var teacherNameLabel: UILabel!
    @IBOutlet var markingPeriodsLabel: UILabel!
    @IBOutlet var assignmentsCountBadgeLabel: UILabel!
    @IBOutlet var assignmentsBadgeView: UIView!
    
    var realmPeriod: RealmPeriod!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = self.realmPeriod.name!
        self.teacherNameLabel.text = self.realmPeriod.teacherName!
        self.markingPeriodsLabel.text = "Marking Periods: \(self.realmPeriod.quarters!)"
        self.assignmentsBadgeView.layer.cornerRadius = 10
        
//        HomeworkManager.setup(self)
        self.view.setNeedsLayout()
    }
    
    override func viewDidAppear(animated: Bool) {
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func homeworkDidLoad() {
        //homework has loaded
        
        
    }



    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "scheduleDetailClassmatesSegue") {
            let newView = segue.destinationViewController as! ClassmatesVC
            newView.currentClass = self.realmPeriod.exchangeForRealPeriod()
            let backButton = UIBarButtonItem(title: " ", style: .Plain, target: nil, action: nil)
            
            self.navigationItem.backBarButtonItem = backButton
            self.tableView.deselectRowAtIndexPath(self.tableView.indexPathForSelectedRow!, animated: true)
            
        }
        else if (segue.identifier == "assignmentsSegue") {
            let newView = segue.destinationViewController as! PeriodHomeworkVC
            newView.periodNumber = self.realmPeriod.periodNumber
        }
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if (identifier == "scheduleDetailClassmatesSegue" && self.realmPeriod.exchangeForRealPeriod() != nil) {
            return true
        }
        else if (identifier == "assignmentsSegue") {
            return true
        }
        else {
            return false
        }
    }
 
}
