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
        self.navigationController?.navigationBar.translucent = false
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "AppleSDGothicNeo-UltraLight", size: 15)!, NSForegroundColorAttributeName: UIColor.whiteColor()]
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        self.navigationItem.title = "HOMEWORK"
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "Homework")
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject: AnyObject])
    }
    
    override func viewDidAppear(animated: Bool) {
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
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return homework.count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Array(homework.keys)[section]
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let curHomework = homework[Array(homework.keys)[section]] {
            return curHomework.count
        }
        
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("homeworkCell")!
        
        if let curSectionHomework = homework[Array(homework.keys)[indexPath.section]] {
            cell.textLabel!.text = curSectionHomework[indexPath.row].assignment
            
        }
        
        return cell
    }
    
    override func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        return Array(homework.keys)
    }
    
    override func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        return Array(homework.keys).indexOf(title) ?? 0
    }
    
}
