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


    @IBOutlet var activitySpinner: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    
    
    
    var sportingEvents = [SportingEvent]()
    var sportingEventsVarsity = [SportingEvent]()

    var gamesDictionary = [NSDate: [SportingEvent]]()
    var gamesDictionaryV = [NSDate: [SportingEvent]]()
    
    var gameNSDates = [NSDate]()
    var gameNSDatesV = [NSDate]()

    
    var uniqueNSGameDates = [NSDate]()
    var uniqueNSGameDatesV = [NSDate]()
    

    var gameLevel = "V"
    

    
    var uniqueCount = 0;
    var uniqueCountV = 0;


    
    
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
                let gameDate1 = elem["gamedate"].element!.text
                let homeAway = elem["site"].element!.text
                var location = elem["facility"].element!.text
                let time = elem["gametime"].element!.text
                let gameType = elem["gametype"].element!.text
                let level = elem["gamelevel"].element!.text
                
                var dateArray : [String] = gameDate1.components(separatedBy: "-")
                
                let index = gameDate1.index(gameDate1.startIndex, offsetBy: 8)
                var day = gameDate1.substring(from: index)
                let dayFirst = day.index(day.startIndex, offsetBy: 1);
                let temp = day.substring(to: dayFirst)
                
                if temp == "0" {
                    day = day.substring(from: dayFirst)
                }
                
                let monthName = DateFormatter().monthSymbols[Int(dateArray[1])! - 1]
                
                let gameDate = monthName + " " + day
                
                let (gameNSDate, weekDay) = self.convertDateToDay(date: gameDate1)
                //varsity game
                if location == "" {
                    location = "Location Unknown"
                }
                
                if level == "V" {
                    let event = SportingEvent(sport: sportName, stringDate: gameDate, gameNSDate: gameNSDate, weekday: weekDay, time: time, school: location, gameLevel: level, home: homeAway)
                    self.sportingEventsVarsity.append(event)
                    
                    if (self.gamesDictionaryV[gameNSDate]?.append(event)) == nil {
                        self.gamesDictionaryV[gameNSDate] = [event]
                    }
                    print("new game: \(event.sport)")
                    print("added \(String(describing: self.gamesDictionaryV[gameNSDate]))");
                    self.gameNSDatesV.append(gameNSDate)
                }
                
            }
            print("I AM BELOW THE TABLE VIEW REFRESH")
            self.uniqueNSGameDatesV = self.gameNSDatesV.removeDuplicates()

            self.tableView.reloadData()
            print("GAME DATES: \(self.gameNSDatesV)");
            print("UNIQUE GAME DATES: \(self.uniqueNSGameDatesV)");
            
        }
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        switch gameLevel {
        case "V":
            uniqueNSGameDates = uniqueNSGameDatesV
            
        default:
            uniqueNSGameDates = uniqueNSGameDatesV
        }
        print("There are \(uniqueNSGameDates.count) Section")
        return uniqueNSGameDates.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch gameLevel {
        case "V":
            uniqueNSGameDates = uniqueNSGameDatesV
            
        default:
            uniqueNSGameDates = uniqueNSGameDatesV
        }
        print("Section Number: \(section). Section Name: \(uniqueNSGameDates[section]) and rows in section: \(self.gamesDictionaryV[uniqueNSGameDatesV[section]]?.count ?? Int())")
        return (self.gamesDictionaryV[uniqueNSGameDatesV[section]]?.count ?? Int())

    }

//
     func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch gameLevel {
        case "V":
            uniqueNSGameDates = uniqueNSGameDatesV
        default:
            uniqueNSGameDates = uniqueNSGameDatesV
        }

        return uniqueNSGameDates[section].toString(dateFormat: "dd-MM")
    }
    

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch gameLevel {
        case "V":
            sportingEvents = sportingEventsVarsity
            uniqueNSGameDates = uniqueNSGameDatesV
        default:
            sportingEvents = sportingEventsVarsity
            uniqueNSGameDates = uniqueNSGameDatesV
        }
        
        let event = gamesDictionaryV[uniqueNSGameDates[indexPath.section]]?[indexPath.row]
        

        let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SportsCell
                self.tableView.rowHeight = 87.0
        self.tableView.rowHeight = 73.0
        
        
        cell.sport.text = event?.sport
        cell.time.text = "\(String(describing: event?.time))"
        cell.school.text = event?.school
        cell.home.font = UIFont(name: "HelveticaNeue", size: 35)
        cell.time.font = UIFont(name: "HelveticaNeue", size: 17)
        //print(gameDates[indexPath.row])
        
        if event?.home == "Home" {
            cell.home.text = "H"
            cell.home.textColor = UIColor(red:0.0, green:0.38, blue:0.76, alpha:1.0) //Classic iStaples Blue
//            cell.home.font = UIFont(name: "HelveticaNeue", size: 16)
            
        } else {
            cell.home.text = "A"
            cell.home.textColor = UIColor(red:0.3, green:0.8, blue:0.13, alpha:1.0)

        }
        
        return cell
        
    }
    
    @IBOutlet weak var levelSelector: UISegmentedControl!
    
    @IBAction func levelSelector(_ sender: Any) {
        if(levelSelector.selectedSegmentIndex == 0){
            self.gameLevel = "V"
        }
        if(levelSelector.selectedSegmentIndex == 1){
            self.gameLevel = "JV"
        }
        if(levelSelector.selectedSegmentIndex == 2){
        self.gameLevel = "FR"
        }
        self.tableView.reloadData()
    }
    
    
    func convertDateToDay(date: String) -> (NSDate, String){ // FIX THIS LATER _________________________NOTE___
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let gameDate = dateFormatter.date(from:date)
        
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
        let components: NSDateComponents = calendar.components(.weekday, from: gameDate!) as NSDateComponents
        let weekDay = weekdays[components.weekday - 1]
        
        return (gameDate! as NSDate, weekDay as String)
    }
    func uniq<S : Sequence, T : Hashable>(source: S) -> [T] where S.Iterator.Element == T {
        var buffer = [T]()
        var added = Set<T>()
        for elem in source {
            if !added.contains(elem) {
                buffer.append(elem)
                added.insert(elem)
            }
        }
        return buffer
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

extension NSDate
{
    func toString( dateFormat format  : String ) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self as Date)
    }
    
    
    
}

extension Array where Element:Equatable {
    func removeDuplicates() -> [Element] {
        var result = [Element]()
        
        for value in self {
            if result.contains(value) == false {
                result.append(value)
            }
        }
        
        return result
    }
}

