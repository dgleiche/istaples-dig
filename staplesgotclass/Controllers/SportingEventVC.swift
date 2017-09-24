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
    var schoolName: [String] = [""]
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        
        self.navigationController?.navigationBar.barTintColor = self.sweetBlue
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "AppleSDGothicNeo-UltraLight", size: 15)!, NSForegroundColorAttributeName: UIColor.white]
        UIApplication.shared.statusBarStyle = .lightContent
        self.navigationItem.title = "SPORTING EVENT"
        
        if (currentEvent != nil) {
            self.navigationItem.title = "\(self.currentEvent!.sport)"


            
            self.headers.append("Sport")
            self.information.append(self.currentEvent!.sport)

            self.headers.append("Date")
            self.information.append(self.currentEvent!.stringDate)

            self.headers.append("Time")
            self.information.append(self.currentEvent!.time)

            self.headers.append("Location")
            self.information.append(self.currentEvent!.school)

            self.headers.append("School")
            if (self.currentEvent!.directionsURL.range(of: "school") != nil){
                self.schoolName =  self.currentEvent!.directionsURL.components(separatedBy: "school=")
                self.information.append(schoolName[1])
            }else{
                self.information.append("")
            }
            
            self.headers.append("Opponent")
            self.information.append(self.currentEvent!.opponent)

            self.headers.append("Game Level")
            self.information.append(self.currentEvent!.gameLevel)

            self.headers.append("Game Type")
            self.information.append(self.currentEvent!.gameType)

            self.headers.append("Season")
            self.information.append(self.currentEvent!.season)

            var opponentName = self.currentEvent!.opponent.components(separatedBy: " ")
            opponentName.append("Staples")
            if (opponentName[0] != "") {
                nameLabel.attributedText = "Staples vs \(self.currentEvent!.opponent)".color(opponentName)
            }else{
                nameLabel.attributedText = "Staples vs \(opponentName[0])".color(opponentName)
            }

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

extension String {
    func getRanges(of string: String) -> [NSRange] {
        var ranges:[NSRange] = []
        if contains(string) {
            let words = self.components(separatedBy: " ")
            var position: Int = 0
            for word in words {
                if word.lowercased() == string.lowercased() {
                    let startIndex = position
                    let endIndex = word.characters.count
                    let range = NSMakeRange(startIndex, endIndex)
                    ranges.append(range)
                }
                position += (word.characters.count + 1)
            }
        }
        return ranges
    }
    func color(_ words: [String]) -> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString(string: self)
        print(words)
        for word in words {
            let ranges = getRanges(of: word)
            for range in ranges {
                if word.contains("Staples"){
                    attributedString.addAttributes([NSForegroundColorAttributeName: UIColor(red:0.13, green:0.42, blue:0.81, alpha:1.0)], range: range)
                    print("Staples")
                }else{
                    attributedString.addAttributes([NSForegroundColorAttributeName: UIColor(red:0.83, green:0.18, blue:0.18, alpha:1.0)], range: range)
                    print("\(word)")
                }
            }
            print("\(word)")
        }
        return attributedString
    }
}


