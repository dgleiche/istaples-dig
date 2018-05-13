//
//  DefaultSportsVC.swift
//  CTSports
//
//  Created by Jack Sharkey on 12/30/17.
//  Copyright © 2017 Neal Soni. All rights reserved.
//

import UIKit



class DefaultSportsVC: UITableViewController {
    
    @IBOutlet var table: UITableView!
    
    var swipeMode = false

    var newColor = UIColor.black
    
    override func viewDidLoad() {
        if sweetBlue.isLight(){
            newColor = UIColor.black
        }else{
            newColor = sweetBlue
        }
        super.viewDidLoad();
        self.navigationController?.view.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.barTintColor = newColor
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "AppleSDGothicNeo-UltraLight", size: 15)!, NSForegroundColorAttributeName: UIColor.white]
        UIApplication.shared.statusBarStyle = .lightContent

        self.navigationItem.title = "Your Sports"

//        print(self.defaultSports.count)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        // Display a message when the table is empty
        let newView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: self.tableView.frame.height))
        
        let sportsIcon: UIImageView = UIImageView(frame: CGRect(x: 0, y: newView.center.y - 150, width: 100, height: 100))
        sportsIcon.image = UIImage(named: "CTSportsLogo.png")
        sportsIcon.center.x = newView.center.x
        
        let messageLabel: UILabel = UILabel(frame: CGRect(x: 0, y: newView.center.y - 20, width: newView.frame.width - 20, height: 50))
        messageLabel.text = "You have no default sports. To add a new default sport, please tap below and press \"add\""
        messageLabel.textColor = UIColor.black
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.center.x = newView.center.x
        messageLabel.font = UIFont(name: "Palatino-Italic", size: 20)
        
        let newClassButton: UIButton = UIButton(frame: CGRect(x: 0, y: newView.center.y + 50, width: 200, height: 50))
        newClassButton.backgroundColor = UIColor.purple
        newClassButton.center.x = newView.center.x
        newClassButton.setTitle("Add Sport", for: UIControlState())
        newClassButton.titleLabel?.textAlignment = .center
        newClassButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Light", size: 25)
        newClassButton.addTarget(self, action: #selector(DefaultSportsVC.addSport), for: .touchUpInside)
        
        
//            let skipLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 10, width: newView.frame.width - 20, height: 50))
//            skipLabel.text = "To Skip, \npress done above"
//            skipLabel.textColor = UIColor.black
//            skipLabel.numberOfLines = 0
//            skipLabel.textAlignment = .center
//            skipLabel.center.x = 60
//            skipLabel.font = UIFont(name: "Palatino-Italic", size: 20)
        
        let skipButton: UIButton = UIButton(frame: CGRect(x: 0, y: newView.center.y + 120, width: 200, height: 50))
        skipButton.backgroundColor = UIColor.blue
        skipButton.center.x = newView.center.x
        skipButton.setTitle("Skip", for: UIControlState())
        skipButton.titleLabel?.textAlignment = .center
        skipButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Light", size: 25)
        skipButton.addTarget(self, action: #selector(DefaultSportsVC.skipView), for: .touchUpInside)
        
        
        newView.addSubview(sportsIcon)
        newView.addSubview(messageLabel)
        newView.addSubview(newClassButton)
        newView.addSubview(skipButton)

        
        self.tableView.backgroundView = newView
        self.tableView.separatorStyle = .none
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        
        
        return 1
    }
    @objc func addSport(){
        let vc1 = self.storyboard?.instantiateViewController(withIdentifier: "SetSportViewController") as! UINavigationController
        self.present(vc1, animated:true, completion: nil)
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return defaultSports.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SetInfoCell", for: indexPath) as! SetInfoCell

        let current = defaultSports[indexPath.row]
        cell.infoText.text = current;
        let image: UIImage = UIImage(named: "\(current.replacingOccurrences(of: " ", with: "")).png") ?? UIImage()
        print("SPORT NAME: \(current)")
        cell.sportImage!.image = image.imageWithColor(newColor)
        return cell
    }
 
    @objc func skipView(){
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func dismiss(_ sender: Any) {
        NetworkManager.sharedInstance.createCustomSportsArray()
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func add(_ sender: Any) {
        //prep for segur
        let vc1 = self.storyboard?.instantiateViewController(withIdentifier: "SetSportViewController") as! UINavigationController
        self.present(vc1, animated:true, completion: nil)
        
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        if self.isEditing == false {
            print("editing false")
            return .delete
        }
        else if self.isEditing && indexPath.row == (defaultSports.count) {
            return .insert
        }
        else {
            return .delete
        }
    }
    
    var curSport: String?
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        //Here we define the buttons for the table cell swipe
     
        
        let delete = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
            let certainSport = defaultSports[indexPath.row]
            
            print("Delete \(certainSport)")
            
            //Delete the class
            //Send the delete request to the server
            
            
            if let index = defaultSports.index(of:certainSport) {
                defaultSports.remove(at: index)
                defaults.set(defaultSports, forKey: "allSports")
            }
            self.table.deleteRows(at: [indexPath], with: .automatic)
            if (self.isEditing == false) {
                self.setEditing(false, animated: true)
            }


           
            
            //Upon completion of the delete request reload the table
        }
        delete.backgroundColor = UIColor.red
        
        return [delete]
    }
    
    //These methods allows the swipes to occur
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .insert) {
//            self.performSegue(withIdentifier: "periodSegue", sender: nil)
        }
    }
    
    func addClass() {
        if (self.isEditing == false) {
            self.setEditing(true, animated: false)
        }
//        self.performSegue(withIdentifier: "periodSegue", sender: nil)
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        print("set editing \(editing)")
        super.setEditing(editing, animated: true)
        if (!self.swipeMode) {
            if (editing) {
                self.table.allowsSelectionDuringEditing = true
                if (defaultSports.count != 0){
                    if (defaultSports.count > 0) {
                        self.table.insertRows(at: [IndexPath(row: defaultSports.count, section: 0)], with: .automatic)
                    }
                }
            }
            else {
                if (self.table.numberOfRows(inSection: 0) > defaultSports.count) {
                    self.table.deleteRows(at: [IndexPath(row: defaultSports.count, section: 0)], with: .automatic)
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        self.swipeMode = true
    }
    
    override func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        self.swipeMode = false
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        if sweetBlue.isLight(){
            newColor = UIColor.black
        }else{
            newColor = sweetBlue
        }
        table.reloadData()
    
    }
    

}
