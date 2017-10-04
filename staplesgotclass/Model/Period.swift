//
//  Period.swift
//  staplesgotclass
//
//  Created by Dylan Diamond on 5/18/16.
//  Copyright © 2016 Dylan Diamond. All rights reserved.
//

import UIKit
import HTMLEntities
import RealmSwift

class Period: NSObject {
    let name: String
    let periodNumber: Int
    let teacherName: String
    let quarters: String
    let users: [User]
    let id: Int
    var colorInt: Int?
    //var realm: Realm
    init(name: String, periodNumber: Int, teacherName: String, quarters: String, id: Int, users: [User]) {
        self.name = name.htmlUnescape()
        self.periodNumber = periodNumber
        self.teacherName = String(teacherName)
        self.quarters = quarters
        self.users = users
        self.id = id
        //let colors = Array(realm.objects(Color.self))
        

    }
}
