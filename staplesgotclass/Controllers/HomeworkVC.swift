//
//  HomeworkVC.swift
//  staplesgotclass
//
//  Created by Dylan on 8/29/16.
//  Copyright © 2016 Dylan Diamond. All rights reserved.
//

import UIKit

class HomeworkVC: UITableViewController, HomeworkManagerDelegate {
    
    //Keyed by period name
    var homework = [String: [Homework]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.definesPresentationContext = false
        
        self.navigationController?.navigationBar.barTintColor = UIColor(red:0.13, green:0.42, blue:0.81, alpha:1.0)
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "AppleSDGothicNeo-UltraLight", size: 15)!, NSForegroundColorAttributeName: UIColor.white]
        UIApplication.shared.statusBarStyle = .lightContent
        self.navigationItem.title = "HOMEWORK"
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: "Homework")
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker?.send(builder?.build() as! [AnyHashable: Any])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        getHomework()
    }
    
    func getHomework() {
        HomeworkManager.setup(delegate: self)
        HomeworkManager.sharedInstance?.loadSavedData()
    }
    
    func homeworkDidLoad() {
        if let homeworkDict = HomeworkManager.sharedInstance?.homework {
            for (periodNumber, homeworkArr) in homeworkDict {
                homework["\(periodNumber)"] = homeworkArr //TODO: Make this the period name
            }
        }
        
        tableView.reloadData()
    }
    
    //MARK: TableView Data Source & Delegate Methods
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return homework.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Array(homework.keys)[section]
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let curHomework = homework[Array(homework.keys)[section]] {
            return curHomework.count
        }
        
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "homeworkCell")!
        
        if let curSectionHomework = homework[Array(homework.keys)[indexPath.section]] {
            cell.textLabel!.text = curSectionHomework[indexPath.row].assignment
            
        }
        
        return cell
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return Array(homework.keys)
    }
    
    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return Array(homework.keys).index(of: title) ?? 0
    }
    
}
