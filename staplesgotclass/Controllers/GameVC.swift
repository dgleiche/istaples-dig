//
//  GameVC.swift
//  staplesgotclass
//
//  Created by Jack Sharkey on 9/6/17.
//  Copyright © 2017 Dylan Diamond. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SWXMLHash

class FirstViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var sportNames = [String]()
    var gameDates = [String]()
    var homeAways = [String]()
    var locations = [String]()
    var times = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let currentDate = NSDate()
        let dateFormatter = DateFormatter()
        
        
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let todayDate = dateFormatter.string(from: currentDate as Date)
        
        print(todayDate)
        
        
        Alamofire.request("https://www.casciac.org/xml/?sc=Staples&starttoday=1").responseJSON { response in
            
            let xml = SWXMLHash.lazy(response.data!)
            
            for elem in xml["SCHEDULE_DATA"]["EVENTS"]["EVENT"].all {
                let sportName = elem["sport"].element!.text!
                var gameDate = elem["gamedate"].element!.text!
                let homeAway = elem["site"].element!.text!
                var location = elem["facility"].element!.text!
                let time = elem["gametime"].element!.text!
                let gameType = elem["gametype"].element!.text!
                let level = elem["gamelevel"].element!.text!
                
                
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
                
                
                //varsity game
                if level == "V" && gameType == "Game" {
                    self.sportNames.append(sportName)
                    self.gameDates.append(gameDate)
                    self.homeAways.append(homeAway)
                    if location == "" {
                        location = "Location Unknown"
                        self.locations.append(location)
                        
                    } else {
                        self.locations.append(location)
                        
                    }
                    self.times.append(time)
                }
                
                
                
                
                
            }
            self.tableView.reloadData()
            
            
        }
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sportNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = self.tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomCell
        cell.date.text = gameDates[indexPath.row]
        cell.sport.text = sportNames[indexPath.row]
        cell.time.text = times[indexPath.row]
        cell.school.text = locations[indexPath.row]
        
        if homeAways[indexPath.row] == "Home" {
            cell.away.textColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0)
            cell.home.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1.0)
            
        } else {
            cell.home.textColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0)
            cell.away.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1.0)
        }
        
        return cell
        
}
