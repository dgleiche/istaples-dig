//
//  Period.swift
//  staplesgotclass
//
//  Created by Dylan Diamond on 5/18/16.
//  Copyright © 2016 Dylan Diamond. All rights reserved.
//

import UIKit

class Period: NSObject {
    let name: String
    let periodNumber: Int
    let teacherName: String
    let quarters: String
    let users: [User]
    
    init(name: String, periodNumber: Int, teacherName: String, quarters: String, users: [User]) {
        self.name = String(htmlEncodedString: name)
        self.periodNumber = periodNumber
        self.teacherName = teacherName
        self.quarters = quarters
        self.users = users
    }

}
