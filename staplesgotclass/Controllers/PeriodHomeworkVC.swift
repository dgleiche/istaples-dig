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
            let alert = UIAlertController(title: "ERROR", message: "Failed to set periodNumber", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { Void in
                self.dismiss(animated: true, completion: nil)
            }))
            
            present(alert, animated: true, completion: nil)
        }
        
        self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        HomeworkManager.setup(delegate: self)
        HomeworkManager.sharedInstance?.loadSavedData()
    }
    
    //MARK: Homework Manager Delegate Functions
    func homeworkDidLoad() {
        if let period = periodNumber {
            self.homework = HomeworkManager.sharedInstance?.getHomework(forPeriod: period) ?? [Homework]()
            self.tableView.reloadData()
        }
    }
    
    //MARK: Table View Delegate Functions
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: true)
        
        if (editing) {
            //self.tableView.allowsSelectionDuringEditing = true
            self.tableView.insertRows(at: [IndexPath(row: self.homework.count, section: 0)], with: .automatic)
        }
        else {
            if (self.tableView.numberOfRows(inSection: 0) > self.homework.count) {
                self.tableView.deleteRows(at: [IndexPath(row: self.homework.count, section: 0)], with: .automatic)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //If editing add a row for the add homework row
        return (self.isEditing) ? homework.count + 1 : homework.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (self.isEditing == true && indexPath.row == self.homework.count) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "newRowCell", for: indexPath)
            cell.textLabel?.text = "Add Homework"
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "homeworkCell", for: indexPath)
        cell.textLabel!.text = homework[indexPath.row].assignment ?? "CORRUPT ASSIGNMENT DATA"
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        if indexPath.row == homework.count {
            return .insert
        }
        
        return .delete
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .insert {
            addHomework()
        } else if editingStyle == .delete {
            deleteHomework(homework[indexPath.row])
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (isEditing && indexPath.row < homework.count) || !isEditing {
            editHomework()
        } else {
            addHomework()
        }
    }
    
    //MARK: Misc Functions
    
    func editHomework() {
        self.performSegue(withIdentifier: "editHomeworkSegue", sender: nil)
    }
    
    func addHomework() {
        self.performSegue(withIdentifier: "addHomeworkSegue", sender: nil)
    }
    
    func deleteHomework(_ homework: Homework) {
        HomeworkManager.deleteHomework(homework)
        HomeworkManager.sharedInstance?.loadSavedData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addHomeworkSegue" {
            let setHomeworkView = (segue.destination as! UINavigationController).topViewController as! SetHomeworkVC
            
            setHomeworkView.periodNumber = self.periodNumber
        } else if segue.identifier == "editHomeworkSegue" {
            if let selectedRow = tableView.indexPathForSelectedRow?.row {
                if selectedRow < homework.count {
                    let setHomeworkView = (segue.destination as! UINavigationController).topViewController as! SetHomeworkVC
                    
                    setHomeworkView.periodNumber = self.periodNumber
                    setHomeworkView.curHomework = homework[selectedRow]
                }
            }
        }
    }
    
}
