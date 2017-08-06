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
    
    class func EmptyMessage(_ message:String, viewController:UITableViewController) {
        let messageLabel = UILabel(frame: CGRect(x: 0,y: 0,width: viewController.view.bounds.size.width, height: viewController.view.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = UIColor.black
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = .center;
        messageLabel.font = UIFont(name: "TrebuchetMS", size: 25)
        messageLabel.sizeToFit()
        
        viewController.tableView.backgroundView = messageLabel;
        viewController.tableView.separatorStyle = .none;
    }
}
