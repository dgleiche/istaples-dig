
//
//  SportingEventVC.swift
//  CTSports
//
//  Created by Neal Soni on 12/13/17.
//  Copyright © 2017 Neal Soni. All rights reserved.
//
//
//  SportingEventVC.swift
//  staplesgotclass
//
//  Created by Neal Soni on 9/15/17.
//  Copyright © 2017 Dylan Diamond. All rights reserved.
//

import Foundation
import UIKit
import PopupDialog
import EventKit
import UserNotifications

class SportingEventVC: UITableViewController {
    @IBOutlet var loadingSpinner: UIActivityIndicatorView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var opponentLabel: UILabel!
    @IBOutlet var homeLetterView: UIView!
    @IBOutlet var homeLetter: UILabel!
    @IBOutlet var opponentLetter: UILabel!
    @IBOutlet var opponentLetterView: UIView!
    
    //    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var homeAwaySelector: UISegmentedControl!
    
    
    var currentEvent: SportingEvent?
    
    var headers = [String]()
    var information = [String]()
    var schoolName: [String] = [""]
    var newColor = UIColor.black
    
    override func viewDidLoad(){
        if sweetBlue.isLight(){
            newColor = UIColor.black
        }else{
            newColor = sweetBlue
        }
        super.viewDidLoad()
        self.navigationController?.navigationBar.barTintColor = newColor
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "AppleSDGothicNeo-UltraLight", size: 15)!, NSForegroundColorAttributeName: UIColor.white]
        UIApplication.shared.statusBarStyle = .lightContent
        self.navigationItem.title = "SPORTING EVENT"
        
        
        if (currentEvent != nil) {
            self.navigationItem.title = "\(self.currentEvent!.sport)".uppercased()
            
            self.headers.append("Sport")
            self.information.append(self.currentEvent!.sport)
            
            self.headers.append("Date")
            self.information.append(self.currentEvent!.stringDate)
            
            self.headers.append("Time")
            self.information.append(self.currentEvent!.time)
            //            self.timeLabel.text = self.currentEvent!.time
            
            self.headers.append("Location")
            self.information.append(self.currentEvent!.school)
            
            self.headers.append("Opponent")
            self.information.append(self.currentEvent!.opponent)
            
            self.headers.append("School")
            if (self.currentEvent!.directionsURL.range(of: "school") != nil){
                self.schoolName =  self.currentEvent!.directionsURL.components(separatedBy: "school=")
                self.information.append(schoolName[1])
            }else{
                self.information.append("")
            }
            
            
            self.headers.append("Game Level")
            switch self.currentEvent!.gameLevel{
            case "V":
                self.information.append("Varsity")
            case "JV":
                self.information.append("Junior Varsity")
            case "FR":
                self.information.append("Freshman")
            default:
                break;
            }
            //            homeAwaySelector.isEnabled = false
            homeAwaySelector.tintColor = newColor
            switch self.currentEvent!.home {
            case "Home":
                homeAwaySelector.selectedSegmentIndex = 0
            //                homeAwaySelector.setEnabled(false, forSegmentAt: 0)
            case "Away":
                homeAwaySelector.tintColor = schoolColors[self.currentEvent!.opponent] ?? UIColor(red:0.83, green:0.18, blue:0.18, alpha:1.0)
                homeAwaySelector.selectedSegmentIndex = 1
            //                homeAwaySelector.setEnabled(false, forSegmentAt: 1)
            default:
                break
            }
            //            self.homeAwayLabel.text = self.currentEvent!.home
            
            self.headers.append("Game Type")
            self.information.append(self.currentEvent!.gameType)
            
            self.headers.append("Season")
            self.information.append(self.currentEvent!.season.capitalized)
            
            var opponentName = self.currentEvent!.opponent.components(separatedBy: " ")
            opponentName.append(school)
            //            if (opponentName[0] != "") {
            //                nameLabel.attributedText = "\(school) \nvs \n \(self.currentEvent!.opponent)".color(opponentName)
            //            }else{
            //                nameLabel.attributedText = "\(school) \nvs \n \(opponentName[0])".color(opponentName)
            //            }
            
            nameLabel.textColor = newColor
            if schoolKey.split(separator: " ").count > 2 {
                let schoolArray = schoolKey.split(separator: " ")
                if ("\(String(schoolArray[0]))  \(String(schoolArray[1]))".characters.count < 35){
                    nameLabel.text = "\(String(schoolArray[0]))  \(String(schoolArray[1])) \(String(schoolArray[2]))..."
                }else{
                    nameLabel.text = "\(String(schoolArray[0]))  \(String(schoolArray[1]))"
                }
            }else{
                nameLabel.text = schoolKey
            }
            
            homeLetter.text = schoolKey.getInitals()
            
            
            if (homeLetter.text?.characters.count == 2){
                homeLetter.font = UIFont (name: "SFCollegiateSolid-Bold", size: 60)
            }
            else{
                homeLetter.font = UIFont (name: "SFCollegiateSolid-Bold", size: 69)
            }
            
            if !sweetBlue.isLight(){
                homeLetter.textColor = UIColor.white
            }else{
                homeLetter.textColor = UIColor.black
            }
            homeLetterView.backgroundColor = sweetBlue
            homeLetterView.layer.cornerRadius = homeLetterView.layer.frame.size.width / 2
            
            
            opponentLabel.textColor = schoolColors[self.currentEvent!.opponent] ?? UIColor(red:0.83, green:0.18, blue:0.18, alpha:1.0)
            
            if self.currentEvent!.opponent.split(separator: " ").count > 2 {
                let schoolArray = self.currentEvent!.opponent.split(separator: " ")
                if ("\(String(schoolArray[0]))  \(String(schoolArray[1]))".characters.count < 35){
                    opponentLabel.text = "\(String(schoolArray[0]))  \(String(schoolArray[1])) \(String(schoolArray[2]))..."
                }else{
                    opponentLabel.text = "\(String(schoolArray[0]))  \(String(schoolArray[1]))"
                }
            }else{
                opponentLabel.text = self.currentEvent!.opponent
            }
            //              opponentLabel.text = self.currentEvent!.opponent
            
            //            initials = ""
            //            for word in self.currentEvent!.opponent.split(separator: " "){
            //                if (initials.characters.count < 2){
            //                    initials = initials + String(word)[0]
            //                }
            //            }
            opponentLetter.text = self.currentEvent!.opponent.getInitals()
            if (opponentLetter.text?.characters.count == 2){
                opponentLetter.font = UIFont (name: "SFCollegiateSolid-Bold", size: 60)
            }
            else{
                opponentLetter.font = UIFont (name: "SFCollegiateSolid-Bold", size: 69)
            }
            
            //            opponentLabel.text = String(self.currentEvent!.opponent.split(separator: " ")[0])
            //            var initialsOpponent = ""
            //            for word in self.currentEvent!.opponent.split(separator: " "){
            //                initialsOpponent = initialsOpponent + String(word)[0]
            //            }
            //            opponentLetter.text = initialsOpponent
            opponentLetterView.backgroundColor = schoolColors[self.currentEvent!.opponent] ?? UIColor(red:0.83, green:0.18, blue:0.18, alpha:1.0)
            opponentLetterView.layer.cornerRadius = opponentLetterView.layer.frame.size.width / 2
            
            if opponentLetterView.backgroundColor! != UIColor(red:0.83, green:0.18, blue:0.18, alpha:1.0) && opponentLetterView.backgroundColor!.isLight(){
                opponentLetter.textColor = UIColor.black
                opponentLabel.textColor = UIColor.black
            }else{
                opponentLetter.textColor = UIColor.white
                opponentLabel.textColor = schoolColors[self.currentEvent!.opponent] ?? UIColor(red:0.83, green:0.18, blue:0.18, alpha:1.0)
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
    
    @IBAction func levelSelectorChanged(_ sender: Any) {
        switch self.currentEvent!.home {
        case "Home":
            homeAwaySelector.selectedSegmentIndex = 0
        case "Away":
            homeAwaySelector.selectedSegmentIndex = 1
        default:
            break
        }
    }
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
            if (indexPath.row < information.count){
                if (information[indexPath.row] == ""){
                    cell.info.text = "N/A"
                }else{
                    cell.info.text = information[indexPath.row]
                }
            }else{
                cell.info.text = "N/A"
            }
        }
        
        return cell
    }
    @IBAction func addToCalender(_ sender: Any) {
        let title = "Add Event to Calender"
        let message = "Do you want to add this sporting event to your calender?"
        
        // Create the dialog
        let popup = PopupDialog(title: title, message: message)
        
        // Create buttons
        let buttonOne = CancelButton(title: "Cancel") {
            print("You canceled the car dialog.")
        }
        
        // This button will not the dismiss the dialog
        let buttonTwo = DefaultButton(title: "Add", dismissOnTap: false) {
            
            let eventStore = EKEventStore()
            
            eventStore.requestAccess(to: .event, completion: { (granted, error) in
                if (granted) && (error == nil) {
                    addEventToCalendar(title: "\(String(describing: self.currentEvent!.sport)) @\(String(describing: self.currentEvent!.time))", description: "Against \(self.currentEvent!.opponent) at \(self.currentEvent!.school)", startDate: self.currentEvent?.exactDate as! Date, endDate: self.currentEvent?.exactDate as! Date)
                    let title = "Success."
                    let message = "This sporting event has been added to your calender."
                    
                    // Create the dialog
                    let popup = PopupDialog(title: title, message: message)
                    self.present(popup, animated: true, completion: nil)
                    
                } else {
                    let title = "Error."
                    let message = "CTSports does not have access to your calender. You can change this by going to Settings->Privacy->Calenders."
                    
                    // Create the dialog
                    let popup = PopupDialog(title: title, message: message)
                    self.present(popup, animated: true, completion: nil)
                }
            })
            
            self.dismiss(animated: true, completion: nil)
            
            
        }
        
        
        
        popup.addButtons([buttonOne, buttonTwo])
        
        // Present dialog
        
        self.present(popup, animated: true, completion: nil)
        
    }
    
    
    @IBAction func createNotification(_ sender: Any) {
        
        let title = "Are you sure?"
        let message = "Do you want to create a reminder 24 hours in advance for this event?"
        
        // Create the dialog
        let popup1 = PopupDialog(title: title, message: message)
        
        // Create buttons
        let buttonOne = CancelButton(title: "Cancel") {
            print("You canceled the car dialog.")
            self.dismiss(animated: true, completion: nil)
        }
        let buttonTwo = DefaultButton(title: "Yes") {
            //            let options: UNAuthorizationOptions = [.alert];
            //            center.requestAuthorization(options: options) {
            //                (granted, error) in
            //                if !granted {
            //                    print("Something went wrong")
            //                }
            //            }
            
            
            // Present dialog
            
            let content = UNMutableNotificationContent()
            content.title = "Sporting event alert!"
            content.body = "There is a \(self.currentEvent!.sport) game tomorrow at \(self.currentEvent!.time)."
            content.sound = UNNotificationSound.default()
            //        let formatter = DateFormatter()
            
            //        formatter.dateFormat = "yyyy-MM-dd HH:mm"
            //        let someDateTime = formatter.date(from:)
            //        print("DATE IS: \(someDateTime)")
            let currentDate = self.currentEvent!.exactDate as! Date
            let tempCalendar = Calendar.current
            let alteredDate = tempCalendar.date(byAdding: .hour, value: -24, to: currentDate)
            print(alteredDate)
            
            
            let triggerDate = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second,], from: alteredDate!)
            print(triggerDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate,  repeats: false)
            
            let identifier = "UYLLocalNotification"
            let request = UNNotificationRequest(identifier: identifier,
                                                content: content, trigger: trigger)
            UNUserNotificationCenter.current().getNotificationSettings { (notificationSettings) in
                switch notificationSettings.authorizationStatus {
                case .notDetermined:
                    self.requestAuthorization(completionHandler: { (success) in
                        guard success else { return }
                        
                        // Schedule Local Notification
                        if(self.currentEvent!.time != "TBA") {
                            center.add(request, withCompletionHandler: { (error) in
                                if let error = error {
                                    print(error)
                                    //                // Something went wrong
                                } else {
                                    
                                    let title = "Notification created."
                                    let message = "You will be reminded 24 hours before the event."
                                    
                                    // Create the dialog
                                    let popup = PopupDialog(title: title, message: message)
                                    self.present(popup, animated: true, completion: nil)
                                }
                            })
                        } else {
                            let title = "Error."
                            let message = "Notification could not be created because time has not been announced yet."
                            
                            // Create the dialog
                            let popup = PopupDialog(title: title, message: message)
                            self.present(popup, animated: true, completion: nil)
                        }
                        
                    })
                case .authorized:
                    // Schedule Local Notification
                    if(self.currentEvent!.time != "TBA") {
                        center.add(request, withCompletionHandler: { (error) in
                            if let error = error {
                                print(error)
                                //                // Something went wrong
                            } else {
                                
                                let title = "Notification created."
                                let message = "You will be reminded 24 hours before the event."
                                
                                // Create the dialog
                                let popup = PopupDialog(title: title, message: message)
                                self.present(popup, animated: true, completion: nil)
                            }
                        })
                    } else {
                        let title = "Error."
                        let message = "Notification could not be created because time has not been annouced yet."
                        
                        // Create the dialog
                        let popup = PopupDialog(title: title, message: message)
                        self.present(popup, animated: true, completion: nil)
                    }
                case .denied:
                    let title = "Error."
                    let message = "CTSports does not have permission to display notifications. This can be changed in Settings->Notifications->CTSports."
                    
                    // Create the dialog
                    let popup = PopupDialog(title: title, message: message)
                    self.present(popup, animated: true, completion: nil)            }
            }
            
        }
        popup1.addButtons([buttonOne, buttonTwo])
        self.present(popup1, animated: true, completion: nil)
        
    }
    
    private func requestAuthorization(completionHandler: @escaping (_ success: Bool) -> ()) {
        // Request Authorization
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (success, error) in
            if let error = error {
                print("Request Authorization Failed (\(error), \(error.localizedDescription))")
            }
            
            completionHandler(success)
        }
    }
    
    
}

func addEventToCalendar(title: String, description: String?, startDate: Date, endDate: Date, completion: ((_ success: Bool, _ error: NSError?) -> Void)? = nil) {
    let eventStore = EKEventStore()
    
    eventStore.requestAccess(to: .event, completion: { (granted, error) in
        if (granted) && (error == nil) {
            let event = EKEvent(eventStore: eventStore)
            event.title = title
            event.startDate = startDate
            event.endDate = endDate
            event.notes = description
            event.calendar = eventStore.defaultCalendarForNewEvents
            do {
                try eventStore.save(event, span: .thisEvent)
            } catch let e as NSError {
                completion?(false, e)
                return
            }
            completion?(true, nil)
            
        } else {
            completion?(false, error as NSError?)
        }
    })
}



