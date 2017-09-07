//
//  FirstViewController.swift
//  superfans
//
//  Created by Jack Sharkey on 11/15/16.
//  Copyright © 2016 Jack Sharkey. All rights reserved.
//

import UIKit
import Alamofire
import SWXMLHash


class SportsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var sportingEvents = [SportingEvent]()
    var gameDates = [String]()
    var uniqueCount = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        
        let sweetBlue = UIColor(red:0.13, green:0.42, blue:0.81, alpha:1.0)

        
        self.navigationController?.navigationBar.barTintColor = sweetBlue
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "AppleSDGothicNeo-UltraLight", size: 15)!, NSForegroundColorAttributeName: UIColor.white]
        UIApplication.shared.statusBarStyle = .lightContent
        self.navigationItem.title = "SPORTS SCHEDULE"

        let currentDate = NSDate()
        let dateFormatter = DateFormatter()
        
        
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let todayDate = dateFormatter.string(from: currentDate as Date)
        
        print(todayDate)
        
        
        Alamofire.request("https://www.casciac.org/xml/?sc=Staples&starttoday=1").responseJSON { response in
            
            let xml = SWXMLHash.lazy(response.data!)
            
            for elem in xml["SCHEDULE_DATA"]["EVENTS"]["EVENT"].all {
                let sportName = elem["sport"].element!.text
                var gameDate = elem["gamedate"].element!.text
                let homeAway = elem["site"].element!.text
                var location = elem["facility"].element!.text
                let time = elem["gametime"].element!.text
                let gameType = elem["gametype"].element!.text
                let level = elem["gamelevel"].element!.text
                
                var dateArray : [String] = gameDate.components(separatedBy: "-")
                
                let index = gameDate.index(gameDate.startIndex, offsetBy: 8)
                var day = gameDate.substring(from: index)
                let dayFirst = day.index(day.startIndex, offsetBy: 1);
                let temp = day.substring(to: dayFirst)
                
                if temp == "0" {
                    day = day.substring(from: dayFirst)
                }
                
                
                let monthName = DateFormatter().monthSymbols[Int(dateArray[1])! - 1]
                
                
                gameDate = monthName + " " + day
                
                let (gameNSDate, weekDay) = self.convertDateToDay(date: gameDate)
                //varsity game
                if location == "" {
                    location = "Location Unknown"
                }
                let uniqueDate = !self.gameDates.contains(gameDate)
                if uniqueDate{self.uniqueCount += 1}
                
                if level == "V"{
                    self.sportingEvents.append(SportingEvent(sport: sportName, stringDate: gameDate, gameNSDate: gameNSDate, weekday: weekDay, time: time, school: location, gameLevel: level, uniqueDate: uniqueDate, home: homeAway))
                    self.gameDates.append(gameDate)
                }
            }
            self.tableView.reloadData()
            print("I AM BELOW THE TABLE VIEW REFRESH")
            
            
        }
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sportingEvents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SportsCell
        if (sportingEvents[indexPath.row].uniqueDate) {
            cell.date.text = sportingEvents[indexPath.row].stringDate
            self.tableView.rowHeight = 85.0

        }else {
            cell.date.text = ""
            self.tableView.rowHeight = 70.0

        }
        cell.sport.text = sportingEvents[indexPath.row].sport
        cell.time.text = "\(sportingEvents[indexPath.row].weekday) at \(sportingEvents[indexPath.row].time)"
        cell.school.text = sportingEvents[indexPath.row].school
        cell.home.font = UIFont(name: "HelveticaNeue", size: 35)
        cell.time.font = UIFont(name: "HelveticaNeue", size: 17)
        //print(gameDates[indexPath.row])
        
        if sportingEvents[indexPath.row].home == "Home" {
            cell.home.text = "H"
            cell.home.textColor = UIColor(red:0.0, green:0.38, blue:0.76, alpha:1.0) //Classic iStaples Blue
            
        } else {
            cell.home.text = "A"
            cell.home.textColor = UIColor(red:0.3, green:0.8, blue:0.13, alpha:1.0)

        }
        
        return cell
        
    }
    func convertDateToDay(date: String) -> (NSDate, String){
        let day = date.components(separatedBy: " ")[1]
        let year = 2017
        var month = 1
        if date.contains("January") {
            month = 1
        }else if date.contains("February"){
            month = 2
        }else if date.contains("March"){
             month = 3
        }else if date.contains("April"){
             month = 4
        }else if date.contains("May"){
             month = 5
        }else if date.contains("June"){
             month = 6
        }else if date.contains("July"){
             month = 7
        }else if date.contains("August"){
             month = 8
        }else if date.contains("September"){
             month = 9
        }else if date.contains("October"){
             month = 10
        }else if date.contains("November"){
             month = 11
        }else if date.contains("November"){
             month = 12
        }
        
        //print("\(day), \(month), \(year)");
        let strDate = "\(year)-\(month)-\(day)"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let gameDate = dateFormatter.date(from:strDate)
        
        let weekdays = [
            "Sunday",
            "Monday",
            "Tuesday",
            "Wednesday",
            "Thursday",
            "Friday",
            "Satudrday,"
        ]
        
        let calendar: NSCalendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
        let components: NSDateComponents = calendar.components(.weekday, from: gameDate!) as NSDateComponents
        let weekDay = weekdays[components.weekday - 1]
        
        return (gameDate! as NSDate, weekDay as String)
    }
    func dateIsUnique(date: String) -> Bool{
        print("DATE: \(date)")

        for strDate in gameDates{
            if strDate == date {
                print("-----------------------------False")
                return false

            }
            print("------ \(strDate)")
        }
        print("---------------------True")

        return true
    }
    
}

extension String {
    func contains(find: String) -> Bool{
        return self.range(of: find) != nil
    }
    
    func containsIgnoringCase(find: String) -> Bool{
        return self.range(of: find, options: .caseInsensitive) != nil
    }
}


