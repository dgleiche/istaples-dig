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
    let sweetGreen = UIColor(red:0.3, green:0.8, blue:0.13, alpha:1.0)

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
            removeAll()
            getGames()
            self.updatedLast = Date(timeIntervalSinceReferenceDate: Date().timeIntervalSinceReferenceDate)
        }
    }
    func refresh(sender:AnyObject) {
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
    func removeAll(){
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
    }
    
    func getGames(){
        removeAll()
        Alamofire.request("https://www.casciac.org/xml/?sc=Staples&starttoday=1").responseJSON { response in
            
            let xml = SWXMLHash.lazy(response.data!)
            
            for elem in xml["SCHEDULE_DATA"]["EVENTS"]["EVENT"].all {
                let sportName = elem["sport"].element!.text
                let gameDate1 = elem["gamedate"].element!.text
                let homeAway = elem["site"].element!.text
                var location = elem["facility"].element!.text
                let time = elem["gametime"].element!.text.replacingOccurrences(of: " p.m.", with: "PM", options: .literal, range: nil)
                let level = elem["gamelevel"].element!.text

                let gameType = elem["gametype"].element!.text
                let season = elem["season"].element!.text
                let opponent = elem["opponent"].element!.text
                let directionsURL = elem["directionsurl"].element!.text
                let id_num = elem["id_num"].element!.text
                let bus = elem["bus"].element!.text
                let busTime = elem["bustime"].element!.text
                
                
                var dateArray : [String] = gameDate1.components(separatedBy: "-")
                
                let index = gameDate1.index(gameDate1.startIndex, offsetBy: 8)
                var day = gameDate1.substring(from: index)
                let dayFirst = day.index(day.startIndex, offsetBy: 1);
                let temp = day.substring(to: dayFirst)
                
                if temp == "0" {
                    day = day.substring(from: dayFirst)
                }
                
                let monthName = DateFormatter().monthSymbols[Int(dateArray[1])! - 1]
                
                
                let (gameNSDate, weekDay) = self.convertDateToDay(date: gameDate1)
                //varsity game
                let gameDate = self.convertDaytoWeekday(date: gameNSDate) + ", " + monthName + " " + day

                if location == "" {
                    location = "Location Unknown"
                }
                
                
                let event = SportingEvent(sport: sportName, stringDate: gameDate, gameNSDate: gameNSDate, weekday: weekDay, time: time, school: location, gameLevel: level, home: homeAway, gameType: gameType, season: season, opponent: opponent, directionsURL: directionsURL, id_num: id_num, bus: bus, busTime: busTime)
                
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
            self.gameNSDatesV = self.gameNSDatesV.removeDuplicates()
            self.gameNSDatesJV = self.gameNSDatesJV.removeDuplicates()
            self.gameNSDatesFR = self.gameNSDatesFR.removeDuplicates()
            
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
            uniqueNSGameDates = gameNSDatesV
        case "FR":
            uniqueNSGameDates = gameNSDatesFR
        case "JV":
            uniqueNSGameDates = gameNSDatesJV
        default:
            uniqueNSGameDates = gameNSDatesV
        }
        //print("There are \(uniqueNSGameDates.count) Section")
        return uniqueNSGameDates.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch gameLevel {
        case "V":
            uniqueNSGameDates = gameNSDatesV
            gamesDictionary = gamesDictionaryV
        case "JV":
            uniqueNSGameDates = gameNSDatesJV
            gamesDictionary = gamesDictionaryJV


        case "FR":
            uniqueNSGameDates = gameNSDatesFR
            gamesDictionary = gamesDictionaryFR

        default:
            uniqueNSGameDates = gameNSDatesV
            gamesDictionary = gamesDictionaryV

        }
        //print("Section Number: \(section). Section Name: \(uniqueNSGameDates[section]) and rows in section: \(self.gamesDictionaryV[uniqueNSGameDatesV[section]]?.count ?? Int())")
        return (self.gamesDictionary[uniqueNSGameDates[section]]?.count ?? Int())

    }

//
     func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if (uniqueNSGameDates.count != 0 && gamesDictionary[uniqueNSGameDates[0]]?[0] != nil){
        switch gameLevel {
        case "V":
            uniqueNSGameDates = gameNSDatesV
        case "JV":
            uniqueNSGameDates = gameNSDatesJV
        case "FR":
            uniqueNSGameDates = gameNSDatesFR
        default:
            uniqueNSGameDates = gameNSDatesV
        }
        
        let gameDate = uniqueNSGameDates[section].toString(dateFormat: "yyyy-MM-dd")
        let index = gameDate.index(gameDate.startIndex, offsetBy: 8)
        let day = gameDate.substring(from: index)
        let dateArray : [String] = gameDate.components(separatedBy: "-")
        let monthName = DateFormatter().monthSymbols[Int(dateArray[1])! - 1]

        let gameDate1 = convertDaytoWeekday(date: uniqueNSGameDates[section]) + ", " + monthName + " " + day
        return gameDate1
        }
        return ""
    }
    

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SportsCell
        self.tableView.rowHeight = 73.0

        if (uniqueNSGameDates.count != 0 && gamesDictionary[uniqueNSGameDates[0]]?[0] != nil){
            var event = gamesDictionaryV[uniqueNSGameDates[0]]?[0] // just a place holder for no apparent reason because swift hates me, Don't remove
        
            switch gameLevel {
            case "V":
                uniqueNSGameDates = gameNSDatesV
                event = gamesDictionaryV[uniqueNSGameDates[indexPath.section]]?[indexPath.row]
            case "JV":
                uniqueNSGameDates = gameNSDatesJV
                event = gamesDictionaryJV[uniqueNSGameDates[indexPath.section]]?[indexPath.row]
            case "FR":
                uniqueNSGameDates = gameNSDatesFR
                event = gamesDictionaryFR[uniqueNSGameDates[indexPath.section]]?[indexPath.row]

            default:
                uniqueNSGameDates = gameNSDatesV
            }
            
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
                cell.home.textColor = self.sweetGreen
                
            }
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showEvent") {
            let newView = segue.destination as! SportingEventVC
            
            let selectedIndexPath = self.tableView.indexPathForSelectedRow
            
            if (uniqueNSGameDates.count != 0 && gamesDictionary[uniqueNSGameDates[0]]?[0] != nil){
                var indexEvent = gamesDictionaryV[uniqueNSGameDates[0]]?[0] // just a place holder for no apparent reason because swift hates me, Don't remove
                
                switch gameLevel {
                case "V":
                    uniqueNSGameDates = gameNSDatesV
                    indexEvent = gamesDictionaryV[uniqueNSGameDates[selectedIndexPath![0]]]?[selectedIndexPath![1]]
                case "JV":
                    uniqueNSGameDates = gameNSDatesJV
                    indexEvent = gamesDictionaryJV[uniqueNSGameDates[selectedIndexPath![0]]]?[selectedIndexPath![1]]
                case "FR":
                    uniqueNSGameDates = gameNSDatesFR
                    indexEvent = gamesDictionaryFR[uniqueNSGameDates[selectedIndexPath![0]]]?[selectedIndexPath![1]]

                default:
                    uniqueNSGameDates = gameNSDatesV
                }
            
            newView.currentEvent = indexEvent
            
            //print(indexEvent!.sport)
            }
            let backButton = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
            
            self.navigationItem.backBarButtonItem = backButton
            
            self.tableView.deselectRow(at: self.tableView.indexPathForSelectedRow!, animated: true)
            
            
            
        }
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

