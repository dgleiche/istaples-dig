//
//  SportingEvent.swift
//  staplesgotclass
//
//  Created by Neal Soni on 9/7/17.
//  Copyright © 2017 Dylan Diamond. All rights reserved.
//

import Foundation

class SportingEvent: NSObject {
    
    var stringDate: String
    var gameNSDate: NSDate
    var weekday: String
    var sport: String
    var time: String
    var school: String
    var home: String
    var gameLevel: String
    var uniqueDate: Bool
    
    init(sport: String, stringDate: String, gameNSDate: NSDate, weekday: String, time: String, school: String, gameLevel: String, uniqueDate: Bool, home: String){
        self.stringDate = stringDate
        self.sport = sport
        self.gameNSDate = gameNSDate
        self.weekday = weekday
        self.time = time
        self.school = school
        self.gameLevel = gameLevel
        self.uniqueDate = uniqueDate
        self.home = home
    }
}
