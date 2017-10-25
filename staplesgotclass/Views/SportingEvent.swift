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
    var gameType: String
    var season: String
    var opponent: String
    var directionsURL: String
    var id_num: String
    var bus: String
    var busTime: String
    
    init(sport: String, stringDate: String, gameNSDate: NSDate, weekday: String, time: String, school: String, gameLevel: String, home: String, gameType: String, season: String, opponent: String, directionsURL: String, id_num: String, bus: String, busTime: String){
        
        self.stringDate = stringDate
        self.sport = sport
        self.gameNSDate = gameNSDate
        self.weekday = weekday
        self.time = time
        self.school = school
        self.gameLevel = gameLevel
        self.home = home
        self.gameLevel = gameLevel
        self.gameType = gameType
        self.season = season
        self.opponent = opponent.replacingOccurrences(of: ",", with: " &", options: NSString.CompareOptions.literal, range:nil)
        self.directionsURL = directionsURL
        self.id_num = id_num
        self.bus = bus
        self.busTime = busTime
    }
}