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
    let periodNumber: String
    let teacherName: String
    let quarters: String
    
    init(name: String, periodNumber: String, teacherName: String, quarters: String) {
        self.name = name
        self.periodNumber = periodNumber
        self.teacherName = teacherName
        self.quarters = quarters
    }

}
