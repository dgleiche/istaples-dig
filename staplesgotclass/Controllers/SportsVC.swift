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
import GoogleMobileAds


class SportsViewController: UITableViewController, UISearchBarDelegate, UISearchControllerDelegate, GADBannerViewDelegate {


    @IBOutlet var activitySpinner: UIActivityIndicatorView!
    //var refreshControl: UIRefreshControl!
    let searchController = UISearchController(searchResultsController: nil)
    var noResultsView: UIView!

    
    let sweetBlue = UIColor(red:0.13, green:0.42, blue:0.81, alpha:1.0)
    let sweetGreen = UIColor(red:0.3, green:0.8, blue:0.13, alpha:1.0)
    
    var allGames = [SportingEvent]()
    var allGamesV = [SportingEvent]()
    var allGamesJV = [SportingEvent]()
    var allGamesFR = [SportingEvent]()
    var filteredGames = [SportingEvent]()
    var convertedFilteredGames = [NSDate: [SportingEvent]]()
    var filteredUniqueDates = [NSDate]()
    
    var gamesDictionary = [NSDate: [SportingEvent]]()
    var gamesDictionaryV = [NSDate: [SportingEvent]]()
    var gamesDictionaryJV = [NSDate: [SportingEvent]]()
    var gamesDictionaryFR = [NSDate: [SportingEvent]]()
    var gamesDictionaryAll = [NSDate: [SportingEvent]]()
    var filteredGamesDictionary = [NSDate: [SportingEvent]]()

    var gameNSDates = [NSDate]()
    var gameNSDatesV = [NSDate]()
    var gameNSDatesJV = [NSDate]()
    var gameNSDatesFR = [NSDate]()
    var gameNSDatesAll = [NSDate]()
    
    var uniqueNSGameDates = [NSDate]()
    var uniqueNSGameDatesV = [NSDate]()
    var uniqueNSGameDatesJV = [NSDate]()
    var uniqueNSGameDatesFR = [NSDate]()
    var uniqueNSGameDatesAll = [NSDate]()

    var updatedLast = Date()

    var gameLevel = "V"
    
    var bannerView: GADBannerView! //Ads

    
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

        
        //Search Stuff
        searchController.searchResultsUpdater = self as? UISearchResultsUpdating
        searchController.searchBar.delegate = self
        searchController.delegate = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView?.addSubview(searchController.searchBar)
        
        noResultsView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.size.width, height: self.tableView.bounds.size.width))
        noResultsView.backgroundColor = UIColor.clear
        
        let noResultsLabel = UILabel(frame: noResultsView.frame)
        noResultsLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 18)
        noResultsLabel.numberOfLines = 1
        noResultsLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        noResultsLabel.shadowColor = UIColor.lightText
        noResultsLabel.textColor = UIColor.darkGray
        noResultsLabel.shadowOffset = CGSize(width: 0, height: 1)
        noResultsLabel.backgroundColor = UIColor.clear
        noResultsLabel.textAlignment = NSTextAlignment.center
        
        noResultsLabel.text = "No Results"
        

        noResultsView.isHidden = true
        noResultsView.addSubview(noResultsLabel)
        self.tableView.insertSubview(noResultsView, belowSubview: self.tableView)

        
        self.activitySpinner.startAnimating()

        let currentDate = NSDate()
        let dateFormatter = DateFormatter()
        
        
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let todayDate = dateFormatter.string(from: currentDate as Date)
        
        print("GOT TO REFRESH 1!")
        //refreshControl.backgroundColor = UIColor.white
        //refreshControl.tintColor = UIColor.darkGray

        refreshControl = UIRefreshControl()
        
        refreshControl?.addTarget(self, action: #selector(refresh), for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl!)
        print("GOT TO REFRESH 2!")
        refreshControl?.backgroundColor = UIColor.white
        refreshControl?.tintColor = UIColor.darkGray

        self.tableView.reloadData()
        
        //ads
        removeAds = ((defaults.object(forKey: "ads") as? Bool) ?? false)

        if (!removeAds){
            functionsToAddBannerViewToView()
        }
        if (removeAds && bannerView != nil) {
            print("removed view from view")
            bannerView.isHidden = true
            bannerView.removeFromSuperview()
        }else {
            functionsToAddBannerViewToView()
        }

    }
    func functionsToAddBannerViewToView(){
        bannerView =  GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        
        addBannerViewToView(bannerView)
        //bannerView.adUnitID = "ca-app-pub-6421137549100021/7517677074" // real one
        bannerView.adUnitID = adID // Test one
        //request.testDevices = @[ kGADSimulatorID ]
        let request = GADRequest()
        request.testDevices = [ kGADSimulatorID ];
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        bannerView.delegate = self
        //bannerView.superview?.bringSubview(toFront: bannerView)
        self.tableView.insertSubview(bannerView, belowSubview: (navigationController?.navigationBar)!)
        tableView.bringSubview(toFront: bannerView)
    }
    override func viewWillAppear(_ animated: Bool) {
        if (self.uniqueNSGameDates.count == 0) {
            getGames()
            self.updatedLast = Date(timeIntervalSinceReferenceDate: Date().timeIntervalSinceReferenceDate)
        }
        
        
        removeAds = ((defaults.object(forKey: "ads") as? Bool) ?? false)
        if (removeAds && bannerView != nil) {
            print("removed view from view")
            bannerView.isHidden = true
            bannerView.removeFromSuperview()
        }else {
            functionsToAddBannerViewToView()
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
        
        refreshControl?.attributedTitle = attributedTitle

        
        self.tableView.reloadData()
        self.refreshControl?.endRefreshing()
    }
    func removeAll(){
        
        self.activitySpinner.startAnimating()
        self.activitySpinner.isHidden = false
        
        allGames.removeAll()
        allGamesV.removeAll()
        allGamesJV.removeAll()
        allGamesFR.removeAll()
        filteredGames.removeAll()
        convertedFilteredGames.removeAll()
        filteredUniqueDates.removeAll()
        
        gameNSDates.removeAll()
        gameNSDatesV.removeAll()
        gameNSDatesJV.removeAll()
        gameNSDatesFR.removeAll()
        gameNSDatesAll.removeAll()

        
        uniqueNSGameDates.removeAll()
        uniqueNSGameDatesV.removeAll()
        uniqueNSGameDatesJV.removeAll()
        uniqueNSGameDatesFR.removeAll()
        uniqueNSGameDatesAll.removeAll()

        gamesDictionary.removeAll()
        gamesDictionaryV.removeAll()
        gamesDictionaryJV.removeAll()
        gamesDictionaryFR.removeAll()
        gamesDictionaryAll.removeAll()

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
                let time = elem["gametime"].element!.text.replacingOccurrences(of: " p.m.", with: "PM", options: .literal, range: nil).replacingOccurrences(of: " A.M.", with: "AM", options: .literal, range: nil)
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
                    self.allGamesV.append(event)
                }
                if level == "JV" {
                    if (self.gamesDictionaryJV[gameNSDate]?.append(event)) == nil {
                        self.gamesDictionaryJV[gameNSDate] = [event]
                    }
                    //print("new game: \(event.sport)")
                    //print("added \(String(describing: self.gamesDictionaryV[gameNSDate]))");
                    self.gameNSDatesJV.append(gameNSDate)
                    self.allGamesJV.append(event)
                }
                if level == "FR" {
                    if (self.gamesDictionaryFR[gameNSDate]?.append(event)) == nil {
                        self.gamesDictionaryFR[gameNSDate] = [event]
                    }
                    //print("new game: \(event.sport)")
                    //print("added \(String(describing: self.gamesDictionaryV[gameNSDate]))");
                    self.gameNSDatesFR.append(gameNSDate)
                    self.allGamesFR.append(event)

                }
                if (self.gamesDictionaryAll[gameNSDate]?.append(event)) == nil {
                    self.gamesDictionaryAll[gameNSDate] = [event]
                }
                self.gameNSDatesAll.append(gameNSDate)
                self.allGames.append(event)
                

                
            }
            self.gameNSDatesV   = self.gameNSDatesV.removeDuplicates()
            self.gameNSDatesJV  = self.gameNSDatesJV.removeDuplicates()
            self.gameNSDatesFR  = self.gameNSDatesFR.removeDuplicates()
            self.gameNSDatesAll = self.gameNSDatesAll.removeDuplicates()
            self.activitySpinner.stopAnimating()
            self.activitySpinner.isHidden = true
            self.tableView.reloadData()
            //self.bannerView.superview?.bringSubview(toFront: self.bannerView)

            //print("GAME DATES: \(self.gameNSDatesV)");
            //print("UNIQUE GAME DATES: \(self.uniqueNSGameDatesV)");
            
        }
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            uniqueNSGameDates = filteredUniqueDates
            print("number of sections: \(filteredUniqueDates)")
        }else{
            switch gameLevel {
            case "V":
                uniqueNSGameDates = gameNSDatesV
            case "FR":
                uniqueNSGameDates = gameNSDatesFR
            case "JV":
                uniqueNSGameDates = gameNSDatesJV
            case "All":
                uniqueNSGameDates = gameNSDatesAll

            default:
                uniqueNSGameDates = gameNSDatesV
            }
        }
        //print("There are \(uniqueNSGameDates.count) Section")
        return uniqueNSGameDates.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchController.isActive && searchController.searchBar.text != "" {
            if (filteredGames.count == 0){
                noResultsView.isHidden = false
                return 0
            }else{
                noResultsView.isHidden = true
            
                return (self.convertedFilteredGames[filteredUniqueDates[section]]?.count ?? Int())
            }
        }else{

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
            case "All":
                uniqueNSGameDates = gameNSDatesAll
                gamesDictionary = gamesDictionaryAll

            default:
                uniqueNSGameDates = gameNSDatesV
                gamesDictionary = gamesDictionaryV

            }
        }
        //print("Section Number: \(section). Section Name: \(uniqueNSGameDates[section]) and rows in section: \(self.gamesDictionaryV[uniqueNSGameDatesV[section]]?.count ?? Int())")
        return (self.gamesDictionary[uniqueNSGameDates[section]]?.count ?? Int())

    }


    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {

        var gameDate1 = ""
        
        if (uniqueNSGameDates.count != 0 && gamesDictionary[uniqueNSGameDates[0]]?[0] != nil){
            
            if searchController.isActive && searchController.searchBar.text != "" {
                uniqueNSGameDates = filteredUniqueDates
            }else{
                switch gameLevel {
                case "V":
                    uniqueNSGameDates = gameNSDatesV
                case "JV":
                    uniqueNSGameDates = gameNSDatesJV
                case "FR":
                    uniqueNSGameDates = gameNSDatesFR
                case "All":
                    uniqueNSGameDates = gameNSDatesAll
                default:
                    uniqueNSGameDates = gameNSDatesV
                }
            }
            
            let gameDate = uniqueNSGameDates[section].toString(dateFormat: "yyyy-MM-dd")
            let index = gameDate.index(gameDate.startIndex, offsetBy: 8)
            let day = gameDate.substring(from: index)
            let dateArray : [String] = gameDate.components(separatedBy: "-")
            let monthName = DateFormatter().monthSymbols[Int(dateArray[1])! - 1]
            
            gameDate1 = convertDaytoWeekday(date: uniqueNSGameDates[section]) + ", " + monthName + " " + day
        }
        if bannerView != nil {
            tableView.bringSubview(toFront: bannerView)
        }
        return gameDate1
    }
    
//    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
//    {
//        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 30))
//        headerView.backgroundColor = UIColor(red:0.36, green:0.45, blue:0.49, alpha:1.0)
//
//        let label = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 30))
//
//
//
//        label.text = gameDate1
//        label.textColor = UIColor.white
//        label.textAlignment = .center
//        headerView.addSubview(label)
//
//        tableView.bringSubview(toFront: bannerView)
//
//        return headerView
//    }
    
    

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SportsCell
        self.tableView.rowHeight = 73.0
        var tag = ""
        var event: SportingEvent = SportingEvent(sport: "sportName", stringDate: "gameDate", gameNSDate: Date() as NSDate, weekday: "weekDay", time: "time", school: "location", gameLevel: "level", home: "homeAway", gameType: "gameType", season: "season", opponent: "opponent", directionsURL: "", id_num: "id_num", bus: "bus", busTime: "busTime")
        if searchController.isActive && searchController.searchBar.text != "" {

            if (filteredUniqueDates.count != 0 && convertedFilteredGames[filteredUniqueDates[0]]?[0] != nil){
                uniqueNSGameDates = filteredUniqueDates
                event = (convertedFilteredGames[filteredUniqueDates[indexPath.section]]?[indexPath.row])!
                
                if gameLevel == "All"{
                    switch event.gameLevel {
                    case "V":
                        tag = "Varsity "
                    case "JV":
                        tag = "JV "
                    case "FR":
                        tag = "Freshman "
                    default:
                        tag = ""
                    }
                }
                cell.sport.text = tag + (event.sport)
                cell.time.text = "\(String(describing: event.time))"
                cell.school.text = event.school
                cell.school.font = UIFont(name: "HelveticaNeue-Medium", size: 12)
                
                cell.home.font = UIFont(name: "HelveticaNeue", size: 35)
                cell.time.font = UIFont(name: "HelveticaNeue", size: 17)
                //print(gameDates[indexPath.row])
                
                if event.home == "Home" {
                    cell.home.text = "H"
                    cell.home.textColor = self.sweetBlue //Classic iStaples Blue
                    
                } else {
                    cell.home.text = "A"
                    cell.home.textColor = self.sweetGreen
                    
                }
                return cell
            }

        } else{
            if (uniqueNSGameDates.count != 0 && gamesDictionary[uniqueNSGameDates[0]]?[0] != nil){
                //event = (gamesDictionaryV[uniqueNSGameDates[0]]?[0])! // just a place holder for no apparent reason because swift hates me, Don't remove
                switch gameLevel {
                case "V":
                    uniqueNSGameDates = gameNSDatesV
                    event = (gamesDictionaryV[uniqueNSGameDates[indexPath.section]]?[indexPath.row])!
                case "JV":
                    uniqueNSGameDates = gameNSDatesJV
                    event = (gamesDictionaryJV[uniqueNSGameDates[indexPath.section]]?[indexPath.row])!

                case "FR":
                    uniqueNSGameDates = gameNSDatesFR
                    event = (gamesDictionaryFR[uniqueNSGameDates[indexPath.section]]?[indexPath.row])!
                case "All":
                    uniqueNSGameDates = gameNSDatesAll
                    event = (gamesDictionaryAll[uniqueNSGameDates[indexPath.section]]?[indexPath.row])!
                    switch event.gameLevel {
                    case "V":
                        tag = "Varsity "
                    case "JV":
                        tag = "JV "
                    case "FR":
                        tag = "Freshman "
                    default:
                        tag = ""
                    }
                default:
                    uniqueNSGameDates = gameNSDatesV
                }
           
            }
            
            cell.sport.text = tag + (event.sport)
            cell.time.text = "\(String(describing: event.time))"
            cell.school.text = event.school
            cell.school.font = UIFont(name: "HelveticaNeue-Medium", size: 12)
            
            cell.home.font = UIFont(name: "HelveticaNeue", size: 35)
            cell.time.font = UIFont(name: "HelveticaNeue", size: 17)
            //print(gameDates[indexPath.row])
            
            if event.home == "Home" {
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
        if(levelSelector.selectedSegmentIndex == 3){
            self.gameLevel = "All"
        }
        if searchController.isActive && searchController.searchBar.text != "" {
            filterContentForSearchText(searchController.searchBar.text!)
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
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredGames.removeAll()
        convertedFilteredGames.removeAll()
        filteredUniqueDates.removeAll()
        print("Filtering")
        switch gameLevel {
        case "V":
            filteredGames = allGamesV.filter { game in
                return game.searchCriteria.lowercased().contains(searchText.lowercased())
            }
        case "JV":
            filteredGames = allGamesJV.filter { game in
                return game.searchCriteria.lowercased().contains(searchText.lowercased())
            }
        case "FR":
            filteredGames = allGamesFR.filter { game in
                return game.searchCriteria.lowercased().contains(searchText.lowercased())
            }
        case "All":
            filteredGames = allGames.filter { game in
                return game.searchCriteria.lowercased().contains(searchText.lowercased())
            }
            
        default:
            filteredGames = allGames.filter { game in
                return game.searchCriteria.lowercased().contains(searchText.lowercased())
            }
        }
        print(filteredGames.count)

        for event in filteredGames {
            if (self.convertedFilteredGames[event.gameNSDate]?.append(event)) == nil {
                self.convertedFilteredGames[event.gameNSDate] = [event]
            }
            self.filteredUniqueDates.append(event.gameNSDate)
        }
        self.filteredUniqueDates = self.filteredUniqueDates.removeDuplicates()
        
        print("unique Dates: \(filteredUniqueDates)")
        print("unique Events: \(convertedFilteredGames)")
        
        print("Done Filtering")
        tableView.reloadData()
        //bannerView.superview?.bringSubview(toFront: bannerView)

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showEvent") {
            let newView = segue.destination as! SportingEventVC
            
            let selectedIndexPath = self.tableView.indexPathForSelectedRow
            if searchController.isActive && searchController.searchBar.text != "" {
                var indexEvent = allGames[0]

                if (filteredUniqueDates.count != 0 && convertedFilteredGames[filteredUniqueDates[0]]?[0] != nil){
                    uniqueNSGameDates = filteredUniqueDates
                    indexEvent = (convertedFilteredGames[filteredUniqueDates[selectedIndexPath![0]]]?[selectedIndexPath![1]])!
                    newView.currentEvent = indexEvent
                }
                
                
            }else{
                print("Game date count: \(uniqueNSGameDates.count)")
                //if (uniqueNSGameDates.count != 0){
                var indexEvent: SportingEvent //= allGames[0] // just a place holder for no apparent reason because swift hates me, Don't remove
                    
                    switch gameLevel {
                    case "V":
                        uniqueNSGameDates = gameNSDatesV
                        indexEvent = (gamesDictionaryV[uniqueNSGameDates[selectedIndexPath![0]]]?[selectedIndexPath![1]])!
                    case "JV":
                        uniqueNSGameDates = gameNSDatesJV
                        indexEvent = (gamesDictionaryJV[uniqueNSGameDates[selectedIndexPath![0]]]?[selectedIndexPath![1]])!
                    case "FR":
                        uniqueNSGameDates = gameNSDatesFR
                        indexEvent = (gamesDictionaryFR[uniqueNSGameDates[selectedIndexPath![0]]]?[selectedIndexPath![1]])!
                    case "All":
                        uniqueNSGameDates = gameNSDatesAll
                        indexEvent = (gamesDictionaryAll[uniqueNSGameDates[selectedIndexPath![0]]]?[selectedIndexPath![1]])!
                    default:
                        uniqueNSGameDates = gameNSDatesV
                        indexEvent = allGames[0]
                    }
                
                newView.currentEvent = indexEvent
                
                //print(indexEvent!.sport)
                //}
            }
            let backButton = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
            
            self.navigationItem.backBarButtonItem = backButton
            
            self.tableView.deselectRow(at: self.tableView.indexPathForSelectedRow!, animated: true)

        }
    }
    func addBannerViewToView(_ bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        if #available(iOS 11.0, *) {
            // In iOS 11, we need to constrain the view to the safe area.
            positionBannerViewFullWidthAtBottomOfSafeArea(bannerView)
        }
        else {
            // In lower iOS versions, safe area is not available so we use
            // bottom layout guide and view edges.
            positionBannerViewFullWidthAtBottomOfView(bannerView)
        }
    }
    
    // MARK: - view positioning
    @available (iOS 11, *)
    func positionBannerViewFullWidthAtBottomOfSafeArea(_ bannerView: UIView) {
        // Position the banner. Stick it to the bottom of the Safe Area.
        // Make it constrained to the edges of the safe area.
        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            guide.leftAnchor.constraint(equalTo: bannerView.leftAnchor),
            guide.rightAnchor.constraint(equalTo: bannerView.rightAnchor),
            guide.bottomAnchor.constraint(equalTo: bannerView.bottomAnchor)
            ])
    }
    
    func positionBannerViewFullWidthAtBottomOfView(_ bannerView: UIView) {
        view.addConstraint(NSLayoutConstraint(item: bannerView,
                                              attribute: .leading,
                                              relatedBy: .equal,
                                              toItem: view,
                                              attribute: .leading,
                                              multiplier: 1,
                                              constant: 0))
        view.addConstraint(NSLayoutConstraint(item: bannerView,
                                              attribute: .trailing,
                                              relatedBy: .equal,
                                              toItem: view,
                                              attribute: .trailing,
                                              multiplier: 1,
                                              constant: 0))
        view.addConstraint(NSLayoutConstraint(item: bannerView,
                                              attribute: .bottom,
                                              relatedBy: .equal,
                                              toItem: bottomLayoutGuide,
                                              attribute: .top,
                                              multiplier: 1,
                                              constant: 0))
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

extension SportsViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}
