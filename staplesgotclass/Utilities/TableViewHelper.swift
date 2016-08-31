//
//  TableViewHelper.swift
//  staplesgotclass
//
//  Created by Dylan Diamond on 8/31/16.
//  Copyright © 2016 Dylan Diamond. All rights reserved.
//

import Foundation
import UIKit
class TableViewHelper {
    
    class func EmptyMessage(message:String, viewController:UITableViewController) {
        let messageLabel = UILabel(frame: CGRectMake(0,0,viewController.view.bounds.size.width, viewController.view.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = UIColor.blackColor()
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = .Center;
        messageLabel.font = UIFont(name: "TrebuchetMS", size: 25)
        messageLabel.sizeToFit()
        
        viewController.tableView.backgroundView = messageLabel;
        viewController.tableView.separatorStyle = .None;
    }
}
