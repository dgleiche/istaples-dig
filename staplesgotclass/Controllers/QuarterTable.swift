//
//  QuarterTable.swift
//  staplesgotclass
//
//  Created by Dylan on 5/25/16.
//  Copyright © 2016 Dylan Diamond. All rights reserved.
//

import UIKit

class QuarterTable: UITableView, UITableViewDelegate, UITableViewDataSource {
    
    var currentClass: Period?
    
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
        let cell = tableView.dequeueReusableCellWithIdentifier("quarterCell")!
        
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
}
