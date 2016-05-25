//
//  EditPeriodVC.swift
//  staplesgotclass
//
//  Created by Dylan on 5/23/16.
//  Copyright © 2016 Dylan Diamond. All rights reserved.
//

import UIKit

class EditPeriodVC: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, MLPAutoCompleteTextFieldDataSource, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    @IBOutlet weak var periodPicker: UIPickerView!
    
    @IBOutlet weak var classTextField: MLPAutoCompleteTextField!
    @IBOutlet weak var teacherTextField: MLPAutoCompleteTextField!
    
    @IBOutlet weak var quarterTable: UITableView!
    
    //This is set prior to the segue for editing
    //Saving will update this class
    var currentClass: Period?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        classTextField.autoCompleteDataSource = self
        classTextField.autoCompleteTableAppearsAsKeyboardAccessory = true
        
        teacherTextField.autoCompleteDataSource = self
        teacherTextField.autoCompleteTableAppearsAsKeyboardAccessory = true
        
        quarterTable.scrollEnabled = false
        
        if let curClass = currentClass {
            //Load the default values for this class
            print("Cur Class: \(curClass.name)")
            
            classTextField.text = curClass.name
            teacherTextField.text = curClass.teacherName
            periodPicker.selectRow(curClass.periodNumber - 1, inComponent: 0, animated: false)
        }
    }
    
    //MARK: Actions
    
    @IBAction func cancel(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK: Text Field
    
    let classes = ["Chem", "Comp Sci", "AP Spanish", "Library"]
    let teachers = ["Scrof Daddy", "Neenan", "Dewey", "William M. Jones IV", "Dr. Gleicher"]
    
    func autoCompleteTextField(textField: MLPAutoCompleteTextField!, possibleCompletionsForString string: String!) -> [AnyObject]! {
        var returnStrings = Array<String>()
        
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
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return tableView.frame.height / 4
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)!
        
        //Toggle the check mark
        if cell.accessoryType == UITableViewCellAccessoryType.None {
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        } else {
            cell.accessoryType = UITableViewCellAccessoryType.None
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = quarterTable.dequeueReusableCellWithIdentifier("quarterCell")!

        cell.textLabel!.text = "Quarter \(indexPath.row + 1)"
        
        //Configure check mark
        if let curClass = self.currentClass {
            if curClass.quarters.rangeOfString("\(indexPath.row + 1)") != nil {
                cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            } else {
                cell.accessoryType = UITableViewCellAccessoryType.None
            }
        }
        
        return cell
    }
    
    //MARK: Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if saveButton === sender {
            //Save the new class or add the class
            print("Save class")
        }
    }
}