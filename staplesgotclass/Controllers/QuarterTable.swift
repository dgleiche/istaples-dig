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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.height / 4
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)!
        
        //Toggle the check mark
        if cell.accessoryType == UITableViewCellAccessoryType.none {
            cell.accessoryType = UITableViewCellAccessoryType.checkmark
        } else {
            cell.accessoryType = UITableViewCellAccessoryType.none
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "quarterCell")!
        
        cell.textLabel!.text = "Quarter \(indexPath.row + 1)"
        
        //Configure check mark
        if let curClass = self.currentClass {
            if curClass.quarters.range(of: "\(indexPath.row + 1)") != nil {
                cell.accessoryType = UITableViewCellAccessoryType.checkmark
            } else {
                cell.accessoryType = UITableViewCellAccessoryType.none
            }
        }
        
        return cell
    }
}
