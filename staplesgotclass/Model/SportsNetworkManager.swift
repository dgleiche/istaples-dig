//
//  SportsNetworkManager.swift
//  staplesgotclass
//
//  Created by Neal Soni on 5/10/18.
//  Copyright © 2018 Dylan Diamond. All rights reserved.
//

import Foundation

import Foundation
import Alamofire
import SWXMLHash

//protocol DataReturnedDelegate: class {
//    func dataRecieved(allGames : [SportingEvent])
//    func specificDataRecived(specificGames : [SportingEvent])
//}

class SportsNetworkManager: NSObject {
    
    static let sharedInstance = SportsNetworkManager()
    let baseURL: String
    var allGames = [SportingEvent]()
    var allGamesWithPractices = [SportingEvent]()
    var specificGames = [SportingEvent]()
    //    weak var delegate: DataReturnedDelegate?
    var done = false;
    var doneSpecific = false;
    
    var performingSchoolRequest = false
    var performingSpecificRequest = false
    
    private override init() {
        self.baseURL = "https://www.casciac.org/xml/?"
    }
    
    func performRequestSchool()  {
        print("GETTING ALL GAMES")
        if !performingSchoolRequest {
            performingSchoolRequest = true
            allGames.removeAll()
            allGamesWithPractices.removeAll()
            
            let url = "\(baseURL)sc=\(school)&starttoday=1"
            Alamofire.request(url).responseJSON { response in
                let xml = SWXMLHash.lazy(response.data!)
                
                for elem in xml["SCHEDULE_DATA"]["EVENTS"]["EVENT"].all {
                    let sportName = elem["sport"].element?.text     ?? "N/A"
                    let gameDate1 = elem["gamedate"].element?.text  ?? "N/A"
                    let homeAway = elem["site"].element?.text       ?? "N/A"
                    var location = elem["facility"].element?.text   ?? "N/A"
                    var time = elem["gametime"].element?.text       ?? "N/A"
                    let level = elem["gamelevel"].element?.text     ?? "N/A"
                    
                    let gameType = elem["gametype"].element?.text   ?? "N/A"
                    let season = elem["season"].element?.text       ?? "N/A"
                    var opponent = elem["opponent"].element?.text   ?? "N/A"
                    let directionsURL = elem["directionsurl"].element?.text  ?? "N/A"
                    let id_num = elem["id_num"].element?.text       ?? "N/A"
                    let bus = elem["bus"].element?.text             ?? "N/A"
                    let busTime = elem["bustime"].element?.text     ?? "N/A"
                    
                    opponent = opponent.replacingOccurrences(of: "St.", with: "St")
                    
                    var dateArray : [String] = gameDate1.components(separatedBy: "-")
                    time = time.replacingOccurrences(of: " p.m.", with: "PM", options: .literal, range: nil).replacingOccurrences(of: " a.m.", with: "AM", options: .literal, range: nil).replacingOccurrences(of: "pm", with: "PM", options: .literal, range: nil).replacingOccurrences(of: "p.m.", with: "PM", options: .literal, range: nil) //fix
                    let index = gameDate1.index(gameDate1.startIndex, offsetBy: 8)
                    var day = gameDate1.substring(from: index)
                    let dayFirst = day.index(day.startIndex, offsetBy: 1);
                    let temp = day.substring(to: dayFirst)
                    
                    if temp == "0" {
                        day = day.substring(from: dayFirst)
                    }
                    
                    let monthName = DateFormatter().monthSymbols[Int(dateArray[1])! - 1]
                    
                    let (gameNSDate, weekDay) = self.convertDateToDay(date: gameDate1)
                    
                    var exactDate = gameNSDate
                    
                    //Add time to GameNSDate object
                    let calendar = Calendar.current
                    var dateComponents = calendar.dateComponents([.year, .month, .day], from: gameNSDate as Date)
                    let outFormatter = DateFormatter()
                    outFormatter.locale = Locale(identifier: "en_US_POSIX")
                    outFormatter.dateFormat = "hh:mma"
                    var timeDate: Date
                    if (time.characters.count > 8){
                        let startTime = time.split(separator: "-")[0]
                        timeDate = outFormatter.date(from: String(startTime)) ?? outFormatter.date(from: "12:00AM")!
                    }else{
                        timeDate = outFormatter.date(from: time) ?? outFormatter.date(from: "12:00AM")!
                    }
                    
                    let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: timeDate)
                    dateComponents.hour = timeComponents.hour
                    dateComponents.minute = timeComponents.minute
                    dateComponents.second = timeComponents.second
                    
                    exactDate = calendar.date(from: dateComponents)! as NSDate
                    
                    //                    Date(year: dateComponents.year, month: dateComponents.month, day: dateComponents.day, hour: timeComponents.hour, minute: timeComponents.minute, second: timeComponents.second)
                    
                    
                    
                    //varsity game
                    let gameDate = self.convertDaytoWeekday(date: gameNSDate) + ", " + monthName + " " + day
                    
                    if location == "" {
                        location = "Location Unknown"
                    }
                    
                    if gameType != "Practice" {
                        let event = SportingEvent(sport: sportName, stringDate: gameDate, gameNSDate: gameNSDate, weekday: weekDay, time: time, school: location, gameLevel: level, home: homeAway, gameType: gameType, season: season, opponent: opponent, directionsURL: directionsURL, id_num: id_num, bus: bus, busTime: busTime, exactDate: exactDate)
                        
                        if (gameDate1 != "TBA") {
                            self.allGames.append(event)
                            self.allGamesWithPractices.append(event)
                        }
                    } else {
                        let event = SportingEvent(sport: sportName, stringDate: gameDate, gameNSDate: gameNSDate, weekday: weekDay, time: time, school: location, gameLevel: level, home: homeAway, gameType: gameType, season: season, opponent: opponent, directionsURL: directionsURL, id_num: id_num, bus: bus, busTime: busTime, exactDate: exactDate)
                        
                        if (gameDate1 != "TBA") {
                            self.allGamesWithPractices.append(event)
                        }
                        
                    }
                }   
                
                self.done = true;
                self.allGames = Array(Set(self.allGames))
                self.allGamesWithPractices = Array(Set(self.allGamesWithPractices))
                
                self.allGames = self.allGames.sorted(by: { $0.gameNSDate.compare($1.gameNSDate as Date) == .orderedAscending})
                self.allGamesWithPractices = self.allGamesWithPractices.sorted(by: { $0.gameNSDate.compare($1.gameNSDate as Date) == .orderedAscending})
                
                NotificationCenter.default.post(name: NSNotification.Name.init("loadedAllGames"), object: nil)
                self.performingSchoolRequest = false
                //            self.delegate?.dataRecieved(allGames: self.allGames)
            }
        }
        
    }
    
    
    func convertDateToDay(date: String) -> (NSDate, String){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let gameDate = dateFormatter.date(from:date)
        
        let weekDay = convertDaytoWeekday(date: gameDate! as NSDate)
        
        return (gameDate! as NSDate, weekDay as String)
    }
    
    func convertDaytoWeekday(date: NSDate) -> String{
        let weekdays = [
            "Sunday",
            "Monday",
            "Tuesday",
            "Wednesday",
            "Thursday",
            "Friday",
            "Saturday"
        ]
        let calendar: NSCalendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
        let components: NSDateComponents = calendar.components(.weekday, from: date as Date) as NSDateComponents
        let weekDay = weekdays[components.weekday - 1]
        
        return weekDay
    }
    
    
}
