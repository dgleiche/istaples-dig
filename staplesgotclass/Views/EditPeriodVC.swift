//
//  EditPeriodVC.swift
//  staplesgotclass
//
//  Created by Dylan on 5/23/16.
//  Copyright © 2016 Dylan Diamond. All rights reserved.
//

import UIKit
import Alamofire
import MLPAutoCompleteTextField

class EditPeriodVC: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate, MLPAutoCompleteTextFieldDataSource {
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    @IBOutlet weak var periodPicker: UIPickerView!
    
    @IBOutlet weak var classTextField: MLPAutoCompleteTextField!
    @IBOutlet weak var teacherTextField: MLPAutoCompleteTextField!
    
    @IBOutlet weak var quarterTable: QuarterTable!
    
    var classes: [String] = []
    var teachers: [String] = []
    
    //This is set prior to the segue for editing
    //Saving will update this clas
    var currentClass: Period?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.allowsSelection = false
        
        self.view.layoutIfNeeded()
        
        self.navigationController?.navigationBar.barTintColor = UIColor(red:0.13, green:0.42, blue:0.81, alpha:1.0)
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "AppleSDGothicNeo-UltraLight", size: 15)!, NSForegroundColorAttributeName: UIColor.white]
        UIApplication.shared.statusBarStyle = .lightContent
        
        quarterTable.dataSource = quarterTable
        quarterTable.delegate = quarterTable
        quarterTable.currentClass = currentClass
        
        classTextField.autoCompleteDataSource = self
        classTextField.autoCompleteTableAppearsAsKeyboardAccessory = true
        
        teacherTextField.autoCompleteDataSource = self
        teacherTextField.autoCompleteTableAppearsAsKeyboardAccessory = true
        
        quarterTable.isScrollEnabled = false
        
        classes = UserManager.sharedInstance!.classNames
        teachers = UserManager.sharedInstance!.teacherNames
        
        let tracker = GAI.sharedInstance().defaultTracker
        
        if let curClass = currentClass {
            //Load the default values for this class
            print("Cur Class: \(curClass.name)")
            self.navigationItem.title = "EDIT PERIOD"
            tracker?.set(kGAIScreenName, value: "EditPeriod")
            classTextField.text = curClass.name
            teacherTextField.text = curClass.teacherName
            print("cur teacher: \(curClass.teacherName)")
            periodPicker.selectRow(curClass.periodNumber - 1, inComponent: 0, animated: false)
        }
        else {
            self.navigationItem.title = "NEW PERIOD"
            tracker?.set(kGAIScreenName, value: "NewPeriod")
        }
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker?.send(builder?.build() as! [AnyHashable: Any])
        
    }
    
    func createAlert(_ title: String, alert: String) {
        let alertController = UIAlertController(title: title, message:
            alert, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    //MARK: Actions
    
    @IBAction func cancel(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: Text Field
    //func autoCompleteTextField(_ textField: MLPAutoCompleteTextField!, possibleCompletionsForString: String!, completionHandler handler: (([AnyObject]?) -> Void)!)
    
     func autoCompleteTextField(_ textField: MLPAutoCompleteTextField!, possibleCompletionsForString string: String!, completionHandler handler: (([AnyObject]?) -> Void)!) {
        var returnStrings = Array<String>()
        print("GOT TO AUTOCOMPLETE")
        //Return nothing if the string is empty
        if string.isEmpty {
            handler(returnStrings as [AnyObject])
        }
        
        if textField === classTextField {
            returnStrings = classes
        } else if textField === teacherTextField {
            returnStrings = teachers
        }
        
         handler(returnStrings as [AnyObject])
    }
    
    
    //MARK: Picker View
    
    //Data sources
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 8
    }
    
    //Delegates
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(row+1)"
    }
    
    //MARK: Table View
    
    //MARK: Navigation
    
    
    @IBAction func savePeriod(_ sender: UIButton) {
        
        //Verify the class is set
        if let selectedClass = classTextField.text {
            
            //Verify the class is in the array of classes
            if classes.contains(selectedClass) {
                
                //If the teacher field is set, verify it's in the array
                if teacherTextField.text != nil && teacherTextField.text != "" {
                    if !teachers.contains(teacherTextField.text!) {
                        createAlert("Error", alert: "Please choose a teacher from the autocomplete field or leave the field blank if there is no teacher for your class. If the teacher doesn't exist in the autocomplete field, please contact us.")
                        return
                    }
                }
                
                //Finally verify that a quarter was chosen
                var selectedQuartersText = ""
                
                for i in 0..<4 {
                    let selected: Bool = quarterTable.cellForRow(at: IndexPath(item: i, section: 0))!.accessoryType == UITableViewCellAccessoryType.checkmark
                    
                    if selected {
                        //Make sure to add the commas at the right spot
                        if selectedQuartersText == "" {
                            selectedQuartersText += "\(i+1)"
                        } else {
                            selectedQuartersText += ", \(i+1)"
                        }
                    }
                }
                
                //If the selected quarters is still empty, it wasn't set
                if selectedQuartersText == "" {
                    createAlert("Error", alert: "Please select a quarter")
                    return
                }
                
                let selectedTeacher = teacherTextField.text ?? ""
                
                let period = periodPicker.selectedRow(inComponent: 0) + 1
                
                //All the variables should now be created and verified. Send the request
                print("Info: period: \(period) class: \(selectedClass) teacher: \(selectedTeacher) quarters: \(selectedQuartersText)")
                
                var parameters = ["name": selectedClass, "teacher_name": selectedTeacher, "period_number": "\(period)", "quarters": selectedQuartersText]
                if (currentClass != nil) {
                    parameters["id"] = "\(currentClass!.id)"
                }
                sender.isEnabled = false
                UserManager.sharedInstance?.currentUser.network.performRequest(withMethod: "POST", endpoint: "edit", parameters: parameters, headers: nil, completion: { (response: DataResponse<Any>) in
                    sender.isEnabled = true
                    if (response.response?.statusCode == 200) {
                        UserManager.sharedInstance?.refreshNeeded = true
                        self.dismiss(animated: true, completion: nil)
                    }
                    else {
                        self.createAlert("Error saving period", alert: "Please check your network connection and try again.")
                    }
                    
                })
                
                
            } else {
                createAlert("Error", alert: "Please choose a class from the autocomplete field. If the class doesn't exist in the autocomplete field, please contact us.")
                return
            }
            
        } else {
            createAlert("Error", alert: "Please select a class")
            return
        }
        
    }
    
}
