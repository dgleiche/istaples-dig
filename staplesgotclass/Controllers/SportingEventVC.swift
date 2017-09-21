//
//  SportingEventVC.swift
//  staplesgotclass
//
//  Created by Neal Soni on 9/15/17.
//  Copyright © 2017 Dylan Diamond. All rights reserved.
//

import Foundation
import UIKit


class SportingEventVC: UITableViewController {
    let sweetBlue = UIColor(red:0.13, green:0.42, blue:0.81, alpha:1.0)
    @IBOutlet var loadingSpinner: UIActivityIndicatorView!
    @IBOutlet var nameLabel: UILabel!
    var currentEvent: SportingEvent?
    
    var headers = [String]()
    var information = [String]()
    
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        
        self.navigationController?.navigationBar.barTintColor = self.sweetBlue
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "AppleSDGothicNeo-UltraLight", size: 15)!, NSForegroundColorAttributeName: UIColor.white]
        UIApplication.shared.statusBarStyle = .lightContent
        self.navigationItem.title = "SPORTING EVENT"
        
        if (currentEvent != nil) {

            nameLabel.text = currentEvent!.sport
            self.headers.append("Sport")
            self.information.append(self.currentEvent!.sport)

            self.headers.append("Date")
            self.information.append(self.currentEvent!.stringDate)

            self.headers.append("Time")
            self.information.append(self.currentEvent!.time)

            self.headers.append("School")
            self.information.append(self.currentEvent!.school)

            self.headers.append("Opponent")
            self.information.append(self.currentEvent!.opponent)

            self.headers.append("Game Level")
            self.information.append(self.currentEvent!.gameLevel)

            self.headers.append("Game Type")
            self.information.append(self.currentEvent!.gameType)

            self.headers.append("Season")
            self.information.append(self.currentEvent!.season)

            self.headers.append("Directions URL")
            self.information.append(self.currentEvent!.directionsURL)

            if (self.currentEvent!.bus == "yes"){
                self.headers.append("Bus Time")
                self.information.append(self.currentEvent!.busTime)
            }

        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (currentEvent != nil){
            return headers.count
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "INFORMATION"
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "sportsInfoCell", for: indexPath) as! SportsInfoCell
        if (currentEvent != nil) {
            cell.name.text = headers[indexPath.row]
            if (information[indexPath.row] == ""){
                cell.info.text = "N/A"
            }else{
                cell.info.text = information[indexPath.row]
            }
        }
        return cell
    }
    
}


