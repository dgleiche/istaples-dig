//
//  AllUsersVC.swift
//  staplesgotclass
//
//  Created by Dylan Diamond on 5/22/16.
//  Copyright © 2016 Dylan Diamond. All rights reserved.
//

import UIKit

class AllUsersVC: UITableViewController {
    var allUsers: [User]?
    let searchController = UISearchController(searchResultsController: nil)
    var filteredUsers: [User]?
    var noResultsView: UIView!
    var userDict = [String : [User]]()
    var sectionTitleArray1 = NSArray()
    var sectionTitleArray = NSMutableArray()
    @IBOutlet var userCountLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barTintColor = UIColor(red:0.13, green:0.43, blue:0.81, alpha:1.0)
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "HelveticaNeue-Light", size: 16)!, NSForegroundColorAttributeName: UIColor.whiteColor()]
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        
        noResultsView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.size.width, height: self.tableView.bounds.size.width))
        noResultsView.backgroundColor = UIColor.clearColor()
        
        let noResultsLabel = UILabel(frame: noResultsView.frame)
        noResultsLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 18)
        noResultsLabel.numberOfLines = 1
        noResultsLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        noResultsLabel.shadowColor = UIColor.lightTextColor()
        noResultsLabel.textColor = UIColor.darkGrayColor()
        noResultsLabel.shadowOffset = CGSize(width: 0, height: 1)
        noResultsLabel.backgroundColor = UIColor.clearColor()
        noResultsLabel.textAlignment = NSTextAlignment.Center
        
        noResultsLabel.text = "No Results"
        
        noResultsView.hidden = true
        noResultsView.addSubview(noResultsLabel)
        self.tableView.insertSubview(noResultsView, belowSubview: self.tableView)
        
        if (UserManager.sharedInstance?.currentUser != nil) {
            UserManager.sharedInstance?.getAllUsers({ (success, userList) in
                if (success) {
                    self.allUsers = userList!
                    self.userCountLabel.text = "\(self.allUsers!.count) users"
                    for user in self.allUsers! {
                        let firstCharacter: String = user.name[0]
                        self.userDict[firstCharacter.uppercaseString] = []
                    }
                    
                    for user in self.allUsers! {
                        let firstCharacter: String = user.name[0]
                        self.userDict[firstCharacter.uppercaseString]?.append(user)
                        
                    }
                    self.sectionTitleArray1 = self.userDict.keys.sort { $0.localizedCaseInsensitiveCompare($1) == NSComparisonResult.OrderedAscending }
                    self.sectionTitleArray = self.sectionTitleArray1.mutableCopy() as! NSMutableArray
                    
                    
                    self.tableView.reloadData()
                }
                else {
                    print("error getting all users")
                }
                
            })
        }
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if searchController.active && searchController.searchBar.text != "" {
            return 1
        }
        else {
            return sectionTitleArray.count
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if searchController.active && searchController.searchBar.text != "" {
            return nil
        }
        else {
            return sectionTitleArray[section] as? String
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if searchController.active && searchController.searchBar.text != "" {
            if (filteredUsers?.count == 0) {
                noResultsView.hidden = false
                userCountLabel.hidden = true
            }
            else {
                noResultsView.hidden = true
                userCountLabel.hidden = false
            }
            return filteredUsers!.count
        }
        else {
            if noResultsView != nil {
                noResultsView.hidden = true
                userCountLabel.hidden = false
            }
            if (allUsers != nil) {

                let userWithLetterArray: Array = userDict[sectionTitleArray[section] as! String]!
                return userWithLetterArray.count
            }
            else
            {
                return 0
            }
        }
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("allUserClassmateCell", forIndexPath: indexPath) as! ClassmateCell
        let indexUser: User
        if searchController.active && searchController.searchBar.text != "" {
            indexUser = filteredUsers![indexPath.row]
        } else {
            let userWithLetterArray: Array = userDict[sectionTitleArray[indexPath.section] as! String]!
            indexUser = userWithLetterArray[indexPath.row]
        }
        cell.nameLabel.text = indexUser.name
            cell.classmateImageView.clipsToBounds = true
            cell.classmateImageView.layer.cornerRadius = cell.classmateImageView.frame.width / 2
            if (indexUser.profilePic == nil) {
                if (indexUser.profilePicURL != nil) {
                cell.classmateImageView.downloadedFrom(link: indexUser.profilePicURL!, contentMode: UIViewContentMode.ScaleAspectFit, userImage: indexUser)
                }
                else {
                    cell.classmateImageView.image = UIImage(named: "defaultGooglePic.png")
                }
            }
            else if (indexUser.profilePic != nil) {
                cell.classmateImageView.image = indexUser.profilePic
            }
        
        
        return cell
    }
    
    override func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        return ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
    }
    
    override func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        return sectionTitleArray.indexOfObject(title)
    }
    
    //MARK: Search Controller Methods
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        filteredUsers = allUsers!.filter { user in
            return user.name.lowercaseString.containsString(searchText.lowercaseString)
        }
        
        tableView.reloadData()
    }
    
    //MARK: Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "showAllUserProfile") {
            let newView = segue.destinationViewController as! ProfileVC
            let selectedIndexPath = self.tableView.indexPathForSelectedRow
            let indexUser: User
            if searchController.active && searchController.searchBar.text != "" {
                indexUser = filteredUsers![(selectedIndexPath?.row)!]
            } else {
                let userWithLetterArray: Array = userDict[sectionTitleArray[selectedIndexPath!.section] as! String]!
                indexUser = userWithLetterArray[(selectedIndexPath?.row)!]
            }
            newView.currentUser = indexUser
            [(self.tableView.indexPathForSelectedRow?.row)!]
            
            let backButton = UIBarButtonItem(title: " ", style: .Plain, target: nil, action: nil)
            
            self.navigationItem.backBarButtonItem = backButton
            
            self.tableView.deselectRowAtIndexPath(self.tableView.indexPathForSelectedRow!, animated: true)
            
        }
        
    }
    
}

extension AllUsersVC: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}
