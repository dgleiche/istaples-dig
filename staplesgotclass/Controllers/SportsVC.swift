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


class SportsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchControllerDelegate {


    @IBOutlet var activitySpinner: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    var refreshControl: UIRefreshControl!
    
    
    let sweetBlue = UIColor(red:0.13, green:0.42, blue:0.81, alpha:1.0)


    var gamesDictionary = [NSDate: [SportingEvent]]()
    var gamesDictionaryV = [NSDate: [SportingEvent]]()
    var gamesDictionaryJV = [NSDate: [SportingEvent]]()
    var gamesDictionaryFR = [NSDate: [SportingEvent]]()

    
    var gameNSDates = [NSDate]()
    var gameNSDatesV = [NSDate]()
    var gameNSDatesJV = [NSDate]()
    var gameNSDatesFR = [NSDate]()

    
    var uniqueNSGameDates = [NSDate]()
    var uniqueNSGameDatesV = [NSDate]()
    var uniqueNSGameDatesJV = [NSDate]()
    var uniqueNSGameDatesFR = [NSDate]()

    var updatedLast = Date()
    

    var gameLevel = "V"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        

        
        self.navigationController?.navigationBar.barTintColor = self.sweetBlue
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "AppleSDGothicNeo-UltraLight", size: 15)!, NSForegroundColorAttributeName: UIColor.white]
        UIApplication.shared.statusBarStyle = .lightContent
        self.navigationItem.title = "SPORTS SCHEDULE"

        let currentDate = NSDate()
        let dateFormatter = DateFormatter()
        
        
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let todayDate = dateFormatter.string(from: currentDate as Date)
        
        print("GOT TO REFRESH 1!")
        //refreshControl.backgroundColor = UIColor.white
        //refreshControl.tintColor = UIColor.darkGray

        refreshControl = UIRefreshControl()
        
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl)
        print("GOT TO REFRESH 2!")
        refreshControl.backgroundColor = UIColor.white
        refreshControl.tintColor = UIColor.darkGray

        self.tableView.reloadData()


        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if (self.uniqueNSGameDatesV.count == 0) {
            self.getGames()
            self.updatedLast = Date(timeIntervalSinceReferenceDate: Date().timeIntervalSinceReferenceDate)
        }
    }
    func refresh(sender:AnyObject) {
        gameNSDates.removeAll()
        gameNSDatesV.removeAll()
        gameNSDatesJV.removeAll()
        gameNSDatesFR.removeAll()

        uniqueNSGameDates.removeAll()
        uniqueNSGameDatesV.removeAll()
        uniqueNSGameDatesJV.removeAll()
        uniqueNSGameDatesFR.removeAll()
        
        gamesDictionary.removeAll()
        gamesDictionaryV.removeAll()
        gamesDictionaryJV.removeAll()
        gamesDictionaryFR.removeAll()
        
        getGames()
        
        let dateFormatter = DateFormatter()

        dateFormatter.dateFormat = "MMM d, h:mm a"
        let attrsDictionary = [
            NSForegroundColorAttributeName : UIColor.darkGray
        ]
        let attributedTitle: NSAttributedString = NSAttributedString(string: "Last update: \(dateFormatter.string(from: updatedLast))", attributes: attrsDictionary)
        
        refreshControl.attributedTitle = attributedTitle

        
        self.tableView.reloadData()
        self.refreshControl?.endRefreshing()

    }
    
    func getGames(){
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
                let event = SportingEvent(sport: sportName, stringDate: gameDate, gameNSDate: gameNSDate, weekday: weekDay, time: time, school: location, gameLevel: level, home: homeAway)
                
                if level == "V" {
                    if (self.gamesDictionaryV[gameNSDate]?.append(event)) == nil {
                        self.gamesDictionaryV[gameNSDate] = [event]
                    }
                    //print("new game: \(event.sport)")
                    //print("added \(String(describing: self.gamesDictionaryV[gameNSDate]))");
                    self.gameNSDatesV.append(gameNSDate)
                }
                if level == "JV" {
                    if (self.gamesDictionaryJV[gameNSDate]?.append(event)) == nil {
                        self.gamesDictionaryJV[gameNSDate] = [event]
                    }
                    //print("new game: \(event.sport)")
                    //print("added \(String(describing: self.gamesDictionaryV[gameNSDate]))");
                    self.gameNSDatesJV.append(gameNSDate)
                }
                if level == "FR" {
                    if (self.gamesDictionaryFR[gameNSDate]?.append(event)) == nil {
                        self.gamesDictionaryFR[gameNSDate] = [event]
                    }
                    //print("new game: \(event.sport)")
                    //print("added \(String(describing: self.gamesDictionaryV[gameNSDate]))");
                    self.gameNSDatesFR.append(gameNSDate)
                }
                
            }
            print("I AM BELOW THE TABLE VIEW REFRESH")
            self.uniqueNSGameDatesV = self.gameNSDatesV.removeDuplicates()
            self.uniqueNSGameDatesJV = self.gameNSDatesJV.removeDuplicates()
            self.uniqueNSGameDatesFR = self.gameNSDatesFR.removeDuplicates()
            
            self.tableView.reloadData()
            //print("GAME DATES: \(self.gameNSDatesV)");
            //print("UNIQUE GAME DATES: \(self.uniqueNSGameDatesV)");
            
        }
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        switch gameLevel {
        case "V":
            uniqueNSGameDates = uniqueNSGameDatesV
        case "FR":
            uniqueNSGameDates = uniqueNSGameDatesFR
        case "JV":
            uniqueNSGameDates = uniqueNSGameDatesJV
        default:
            uniqueNSGameDates = uniqueNSGameDatesV
        }
        //print("There are \(uniqueNSGameDates.count) Section")
        return uniqueNSGameDates.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch gameLevel {
        case "V":
            uniqueNSGameDates = uniqueNSGameDatesV
            gamesDictionary = gamesDictionaryV
        case "JV":
            uniqueNSGameDates = uniqueNSGameDatesJV
            gamesDictionary = gamesDictionaryJV


        case "FR":
            uniqueNSGameDates = uniqueNSGameDatesFR
            gamesDictionary = gamesDictionaryFR

        default:
            uniqueNSGameDates = uniqueNSGameDatesV
            gamesDictionary = gamesDictionaryV

        }
        //print("Section Number: \(section). Section Name: \(uniqueNSGameDates[section]) and rows in section: \(self.gamesDictionaryV[uniqueNSGameDatesV[section]]?.count ?? Int())")
        return (self.gamesDictionary[uniqueNSGameDates[section]]?.count ?? Int())

    }

//
     func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch gameLevel {
        case "V":
            uniqueNSGameDates = uniqueNSGameDatesV
        case "JV":
            uniqueNSGameDates = uniqueNSGameDatesJV
        case "FR":
            uniqueNSGameDates = uniqueNSGameDatesFR
        default:
            uniqueNSGameDates = uniqueNSGameDatesV
        }
        
        let gameDate = uniqueNSGameDates[section].toString(dateFormat: "yyyy-MM-dd")
        let index = gameDate.index(gameDate.startIndex, offsetBy: 8)
        let day = gameDate.substring(from: index)
        let dateArray : [String] = gameDate.components(separatedBy: "-")
        let monthName = DateFormatter().monthSymbols[Int(dateArray[1])! - 1]

        let gameDate1 = convertDaytoWeekday(date: uniqueNSGameDates[section]) + ", " + monthName + " " + day
        return gameDate1
    }
    

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var event = gamesDictionaryV[uniqueNSGameDates[0]]?[0] // just a place holder for no apparent reason because swift hates me, Don't remove
        
        
        switch gameLevel {
        case "V":
            uniqueNSGameDates = uniqueNSGameDatesV
            event = gamesDictionaryV[uniqueNSGameDates[indexPath.section]]?[indexPath.row]
        case "JV":
            uniqueNSGameDates = uniqueNSGameDatesJV
            event = gamesDictionaryJV[uniqueNSGameDates[indexPath.section]]?[indexPath.row]
        case "FR":
            uniqueNSGameDates = uniqueNSGameDatesFR
            event = gamesDictionaryFR[uniqueNSGameDates[indexPath.section]]?[indexPath.row]

        default:
            uniqueNSGameDates = uniqueNSGameDatesV
        }
        
        

        let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SportsCell
        self.tableView.rowHeight = 73.0
        
        
        cell.sport.text = event?.sport
        cell.time.text = "\(String(describing: event!.time))"
        cell.school.text = event?.school
        cell.school.font = UIFont(name: "HelveticaNeue-Medium", size: 12)

        cell.home.font = UIFont(name: "HelveticaNeue", size: 35)
        cell.time.font = UIFont(name: "HelveticaNeue", size: 17)
        //print(gameDates[indexPath.row])
        
        if event?.home == "Home" {
            cell.home.text = "H"
            cell.home.textColor = self.sweetBlue //Classic iStaples Blue
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

