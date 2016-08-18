//
//  Period.swift
//  staplesgotclass
//
//  Created by Dylan Diamond on 5/18/16.
//  Copyright © 2016 Dylan Diamond. All rights reserved.
//

import UIKit
import Foundation
import RealmSwift

class Period: Object {
    dynamic var name: String? = nil
    dynamic var periodNumber: Int = 0
    dynamic var teacherName: String? = nil
    dynamic var quarters: String? = nil
    let users = List<User>()
    dynamic var id: Int = 0
    
    class func setup(name: String, periodNumber: Int, teacherName: String, quarters: String, id: Int, users: List<User>) -> Period {
        let period: Period = Period()
        
        period.name = String(htmlEncodedString: name)
        period.periodNumber = periodNumber
        period.teacherName = String(htmlEncodedString: teacherName)
        period.quarters = quarters
        period.users.removeAll()
        period.users.appendContentsOf(users)
        period.id = id
        
        return period
    }
}
