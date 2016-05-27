//
//  EditPeriodVC.swift
//  staplesgotclass
//
//  Created by Dylan on 5/23/16.
//  Copyright © 2016 Dylan Diamond. All rights reserved.
//

import UIKit

class EditPeriodVC: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate, MLPAutoCompleteTextFieldDataSource {
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    @IBOutlet weak var periodPicker: UIPickerView!
    
    @IBOutlet weak var classTextField: MLPAutoCompleteTextField!
    @IBOutlet weak var teacherTextField: MLPAutoCompleteTextField!
    
    @IBOutlet weak var quarterTable: QuarterTable!
    
    //This is set prior to the segue for editing
    //Saving will update this class
    var currentClass: Period?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.allowsSelection = false
        
        
        self.navigationController?.navigationBar.barTintColor = UIColor(red:0.17, green:0.28, blue:0.89, alpha:1.0)
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "HelveticaNeue-Light", size: 16)!, NSForegroundColorAttributeName: UIColor.whiteColor()]
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        
        quarterTable.dataSource = quarterTable
        quarterTable.delegate = quarterTable
        quarterTable.currentClass = currentClass
        
        classTextField.autoCompleteDataSource = self
        classTextField.autoCompleteTableAppearsAsKeyboardAccessory = true
        
        teacherTextField.autoCompleteDataSource = self
        teacherTextField.autoCompleteTableAppearsAsKeyboardAccessory = true
        
        quarterTable.scrollEnabled = false
        
        if let curClass = currentClass {
            //Load the default values for this class
            print("Cur Class: \(curClass.name)")
            self.navigationItem.title = "Edit Period"
            classTextField.text = curClass.name
            teacherTextField.text = curClass.teacherName
            periodPicker.selectRow(curClass.periodNumber - 1, inComponent: 0, animated: false)
        }
        else {
            self.navigationItem.title = "New Period"
        }
    }
    
    //MARK: Actions
    
    @IBAction func cancel(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK: Text Field
    
    let classes = UserManager.sharedInstance!.classNames
    let teachers = UserManager.sharedInstance!.teacherNames

    func autoCompleteTextField(textField: MLPAutoCompleteTextField!, possibleCompletionsForString string: String!) -> [AnyObject]! {
        var returnStrings = Array<String>()
        
        //Return nothing if the string is empty
        if string.isEmpty {
            return returnStrings
        }
        
        if textField === classTextField {
            returnStrings = classes
        } else if textField === teacherTextField {
            returnStrings = teachers
        }
        
        return returnStrings
    }
    
    
    //MARK: Picker View
    
    //Data sources
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 8
    }
    
    //Delegates
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(row+1)"
    }
    
    //MARK: Table View
    
    //MARK: Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if saveButton === sender {
            //Save the new class or add the class
            print("Save class")
        }
    }
}