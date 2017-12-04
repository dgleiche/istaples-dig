//
//  ClassesVC.swift
//  staplesgotclass
//
//  Created by Dylan Diamond on 5/21/16.
//  Copyright © 2016 Dylan Diamond. All rights reserved.
//

import UIKit
import Foundation
import RealmSwift
import Alamofire

class ClassesVC: UITableViewController {
    var myClasses: [Period]?
    var swipeMode = false
    
    var curPeriod: Period?
    @IBOutlet var activitySpinner: UIActivityIndicatorView!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let sweetBlue = UIColor(red:0.13, green:0.42, blue:0.81, alpha:1.0)
        
        //Turn off extra lines in the table view
        
        self.navigationController?.navigationBar.barTintColor = sweetBlue
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "AppleSDGothicNeo-UltraLight", size: 15)!, NSForegroundColorAttributeName: UIColor.white]
        UIApplication.shared.statusBarStyle = .lightContent
        self.navigationItem.title = "CLASSES"
        
//        //Info bar button
//        let infoButton = UIButton(type: .InfoLight)
//        infoButton.addTarget(self, action: #selector(ClassesVC.infoPressed), forControlEvents: .TouchUpInside)
//        let infoBarButtonItem = UIBarButtonItem(customView: infoButton)
//        navigationItem.leftBarButtonItem = infoBarButtonItem
        
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: "Classes")
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker?.send(builder?.build() as! [AnyHashable: Any])
        
        if (UserManager.sharedInstance?.currentUser.schedule != nil) {
            self.myClasses = UserManager.sharedInstance?.currentUser.schedule
            self.tableView.reloadData()
        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("view did appear")
        
        //Resets this as to not save the last edited per
        curPeriod = nil
        
        if (UserManager.sharedInstance != nil) {
            
            self.activitySpinner.startAnimating()
            UserManager.sharedInstance?.currentUser.getClassmates({ (success: Bool) in
                if (success) {
                    
                    if (DailyScheduleManager.sharedInstance?.fetchInProgress != true && UserManager.sharedInstance?.refreshNeeded == true) {
                        //add current user to Realm with all of the data
                        print("refreshing class data")
                        let realm = try! Realm()
                        
                        let realmUser = RealmUser()
                        
                        DailyScheduleManager.sharedInstance?.realmPeriodsToDelete = Array(realm.objects(RealmPeriod.self))
                        
                        for period in UserManager.sharedInstance!.currentUser.schedule! {
                            let realmPeriod = RealmPeriod()
                            
                            realmPeriod.setPeriod(period)
                            
                            realmUser.schedule.append(realmPeriod)
                        }
                        
                        
                        try! realm.write {
                            realm.delete(realm.objects(RealmUser.self))
                            realm.add(realmUser)
                        }
                        
                    }
                    
                    print("success in view did appear")
                    self.myClasses = UserManager.sharedInstance?.currentUser.schedule
                    //                    if (self.myClasses?.count == 0) {
                    //                        let alert = UIAlertController(title: "No Classes!", message: "You have no classes. Please set up your schedule to view your classmates.", preferredStyle: .Alert)
                    //                        let ok = UIAlertAction(title: "OK", style: .Default, handler: nil)
                    //                        alert.addAction(ok)
                    //                        self.presentViewController(alert, animated: true, completion: nil)
                    //                    }
                    self.tableView.reloadData()
                    self.tableView.tableFooterView = UIView(frame: CGRect.zero)
                    
                }
                else {
                    print("error getting classes")
                    let alert = UIAlertController(title: "Error retrieving classes", message: "Please check your network connection and try again.", preferredStyle: .alert)
                    let dismiss = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
                    alert.addAction(dismiss)
                    self.present(alert, animated: true, completion: nil)
                }
                self.activitySpinner.stopAnimating()
            })
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        print("set editing \(editing)")
        super.setEditing(editing, animated: true)
        if (!self.swipeMode) {
            if (editing) {
                self.tableView.allowsSelectionDuringEditing = true
                if (self.myClasses != nil){
                    if (self.myClasses!.count > 0) {
                        self.tableView.insertRows(at: [IndexPath(row: self.myClasses!.count, section: 0)], with: .automatic)
                    }
                }
            }
            else {
                if (self.tableView.numberOfRows(inSection: 0) > self.myClasses!.count) {
                    self.tableView.deleteRows(at: [IndexPath(row: self.myClasses!.count, section: 0)], with: .automatic)
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        self.swipeMode = true
    }
    
    override func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        self.swipeMode = false
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // Return the number of sections.
        if self.myClasses?.count != 0 {
            self.tableView.separatorStyle = .singleLine
            self.tableView.backgroundView = nil
            self.navigationItem.rightBarButtonItem?.isEnabled = true
            return 1
        }
        else {
            // Display a message when the table is empty
            
            let newView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: self.tableView.frame.height))
            
            let coursesIcon: UIImageView = UIImageView(frame: CGRect(x: 0, y: newView.center.y - 150, width: 100, height: 100))
            coursesIcon.image = UIImage(named: "coursesPic.png")
            coursesIcon.center.x = newView.center.x
            
            let messageLabel: UILabel = UILabel(frame: CGRect(x: 0, y: newView.center.y - 20, width: newView.frame.width - 20, height: 50))
            messageLabel.text = "You have no classes. To create a new one, please tap below."
            messageLabel.textColor = UIColor.black
            messageLabel.numberOfLines = 0
            messageLabel.textAlignment = .center
            messageLabel.center.x = newView.center.x
            messageLabel.font = UIFont(name: "Palatino-Italic", size: 20)
            
            let newClassButton: UIButton = UIButton(frame: CGRect(x: 0, y: newView.center.y + 50, width: 200, height: 50))
            newClassButton.backgroundColor = UIColor.purple
            newClassButton.center.x = newView.center.x
            newClassButton.setTitle("New Class", for: UIControlState())
            newClassButton.titleLabel?.textAlignment = .center
            newClassButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Light", size: 25)
            newClassButton.addTarget(self, action: #selector(ClassesVC.addClass), for: .touchUpInside)
            
            
            newView.addSubview(coursesIcon)
            newView.addSubview(messageLabel)
            newView.addSubview(newClassButton)
            
            self.tableView.backgroundView = newView
            self.tableView.separatorStyle = .none
            self.navigationItem.rightBarButtonItem?.isEnabled = false
            
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if (self.myClasses != nil) {
            if (self.isEditing == true) {
                return self.myClasses!.count + 1
            }
            else {
                return self.myClasses!.count
            }
        }
        else {
            if (self.isEditing) {
                return 1
            }
            else {
                return 0
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (self.isEditing == true && indexPath.row == self.myClasses!.count) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "newRowCell", for: indexPath)
            cell.textLabel?.text = "Add Class"
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "classCell", for: indexPath) as! ClassCell
            cell.classTitleLabel.text = self.myClasses![indexPath.row].name
            cell.periodNumberLabel.text = "\(self.myClasses![indexPath.row].periodNumber)"
            let defaultObject: String = String(describing: (defaults.object(forKey: "\(self.myClasses![indexPath.row].periodNumber)") ?? "0"))
            print(Int(defaultObject)!)
            
            cell.periodNumberLabel.textColor = colors[Int(defaultObject)!]
            cell.quarterLabel!.text = "\(self.myClasses![indexPath.row].quarters)"
            cell.teacherLabel.text = self.myClasses![indexPath.row].teacherName
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        if self.isEditing == false {
            print("editing false")
            return .delete
        }
        else if self.isEditing && indexPath.row == (self.myClasses!.count) {
            return .insert
        }
        else {
            return .delete
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //Smaller row for add class
        if (self.isEditing && indexPath.row == self.myClasses!.count) {
            return 50
        }
        
        let defaultCellHeight = 70
        let minimumCellHeight = 50.0
        
        var totalHeight = Int(tableView.bounds.height) - Int(navigationController!.navigationBar.frame.height) - 5
        
        if (self.isEditing) {
            //Make room for the add button
            totalHeight -= 50
        }
        
        let heightTaken = defaultCellHeight * self.myClasses!.count
        
        if heightTaken > totalHeight {
            //Scale down the periods to an extent
            let newHeight = (Double(1) / Double(self.myClasses!.count)) * Double(totalHeight)
            
            //Make sure not to go under the minimum
            return (newHeight < minimumCellHeight) ? CGFloat(minimumCellHeight) : CGFloat(newHeight)
        }
        
        return CGFloat(defaultCellHeight)
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        //Here we define the buttons for the table cell swipe
        let edit = UITableViewRowAction(style: .normal, title: "Edit") { action, index in
            self.curPeriod = self.myClasses![indexPath.row]
            
            print("Edit \(self.curPeriod!.name)")
            
            //Segue to the edit class vc
            self.isEditing = false
            self.performSegue(withIdentifier: "periodSegue", sender: nil)
        }
        edit.backgroundColor = UIColor.orange
        
        let delete = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
            let period: Period = self.myClasses![indexPath.row]
            
            print("Delete \(period.name)")
            
            //Delete the class
            //Send the delete request to the server
            
            UserManager.sharedInstance?.currentUser.network.performRequest(withMethod: "POST", endpoint: "delete", parameters: ["id": "\(period.id)"], headers: nil, completion: { (response: DataResponse<Any>) in
                
                if (response.response?.statusCode == 200) {
                    print("successfully deleted period")
                    UserManager.sharedInstance?.refreshNeeded = true
                    self.myClasses?.remove(at: indexPath.row)
                    if ((self.myClasses?.count)! > 0) {
                        self.tableView.deleteRows(at: [indexPath], with: .automatic)
                        if (self.isEditing == false) {
                            self.setEditing(false, animated: true)
                        }
                    }
                    else {
                        self.tableView.deleteSections(IndexSet(integer: 0), with: .none)
                    }
                }
            })
            
            //Upon completion of the delete request reload the table
        }
        delete.backgroundColor = UIColor.red
        
        return [delete, edit]
    }
    
    //These methods allows the swipes to occur
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .insert) {
            self.performSegue(withIdentifier: "periodSegue", sender: nil)
        }
    }
    
    func addClass() {
        if (self.isEditing == false) {
            self.setEditing(true, animated: false)
        }
        self.performSegue(withIdentifier: "periodSegue", sender: nil)
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
    
    func infoPressed() {
        let infoPage = self.storyboard?.instantiateViewController(withIdentifier: "infoVC") as! UINavigationController
        self.tabBarController?.present(infoPage, animated: true, completion: nil)
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if (identifier == "showClassmates" && self.isEditing) {
            let editVC = self.storyboard?.instantiateViewController(withIdentifier: "editVC") as! EditPeriodVC
            editVC.currentClass = self.myClasses![self.tableView.indexPathForSelectedRow!.row]
            let nav = UINavigationController(rootViewController: editVC)
            self.present(nav, animated: true, completion: nil)
            return false
        }
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showClassmates") {
            let newView = segue.destination as! ClassmatesVC
            newView.currentClass = self.myClasses![(self.tableView.indexPathForSelectedRow?.row)!]
            let backButton = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
            
            self.navigationItem.backBarButtonItem = backButton
            self.tableView.deselectRow(at: self.tableView.indexPathForSelectedRow!, animated: true)
            //            self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "HelveticaNeue-Light", size: 16)!, NSForegroundColorAttributeName: UIColor.whiteColor()]
            
            
        } else if (segue.identifier == "periodSegue") {
            if curPeriod != nil {
                let newView = (segue.destination as! UINavigationController).topViewController as! EditPeriodVC
                newView.currentClass = self.curPeriod!
            }
        }
    }
    
    //Allow cancel button to segue back here
    @IBAction func unwindToClassesView(_ sender: UIStoryboardSegue) {
        
    }
    
    
}
