//
//  AllUsersVC.swift
//  staplesgotclass
//
//  Created by Dylan Diamond on 5/22/16.
//  Copyright © 2016 Dylan Diamond. All rights reserved.
//

import UIKit
import SDWebImage
import GoogleMobileAds

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}



class AllUsersVC: UITableViewController, UISearchBarDelegate, UISearchControllerDelegate, GADBannerViewDelegate {
    var allUsers: [User]?
    let searchController = UISearchController(searchResultsController: nil)
    var filteredUsers: [User]?
    var noResultsView: UIView!
    var userDict = [String : [User]]()
    var sectionTitleArray1 = NSArray()
    var sectionTitleArray = NSMutableArray()
    
    var bannerView: GADBannerView! //Ads

    
    @IBOutlet var activitySpinner: UIActivityIndicatorView!
    @IBOutlet var userCountLabel: UILabel!
    @IBOutlet var refresh: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.definesPresentationContext = false
        
        let sweetBlue = UIColor(red:0.13, green:0.42, blue:0.81, alpha:1.0)

        
        self.navigationController?.navigationBar.barTintColor = sweetBlue
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "AppleSDGothicNeo-UltraLight", size: 15)!, NSForegroundColorAttributeName: UIColor.white]
        UIApplication.shared.statusBarStyle = .lightContent
        
        
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.delegate = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        
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
        
        refresh.backgroundColor = UIColor.white
        refresh.tintColor = UIColor.darkGray
        noResultsView.isHidden = true
        noResultsView.addSubview(noResultsLabel)
        
        self.tableView.backgroundView = UIView()
        self.tableView.backgroundView!.backgroundColor = UIColor.clear
        
        
        self.tableView.insertSubview(noResultsView, belowSubview: self.tableView)
        
        self.activitySpinner.startAnimating()
        
        self.userCountLabel.text = nil
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: "AllUsers")
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker?.send(builder?.build() as! [AnyHashable: Any])
        
        //ads
    
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
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if (self.userDict.count == 0) {
            self.getUsers()
        }
    }
    @IBAction func refresh(_ sender: AnyObject) {
        self.getUsers()
        
    }
    
    func getUsers() {
        if (UserManager.sharedInstance?.currentUser != nil) {
            UserManager.sharedInstance?.getAllUsers({ (success, userList) in
                if (success) {
                    self.allUsers = userList!
                    self.userCountLabel.text = "\(self.allUsers!.count) users"
                    for user in self.allUsers! {
                        let firstCharacter: String = user.name[0]
                        self.userDict[firstCharacter.uppercased()] = []
                    }
                    
                    for user in self.allUsers! {
                        let firstCharacter: String = user.name[0]
                        self.userDict[firstCharacter.uppercased()]?.append(user)
                        
                    }
                    

                    self.sectionTitleArray1 = self.userDict.keys.sorted { $0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending } as NSArray
                    
                    self.sectionTitleArray = self.sectionTitleArray1.mutableCopy() as! NSMutableArray
                    
                    
                    self.activitySpinner.stopAnimating()
                    
                    if (self.refresh.isRefreshing) {
                        self.refresh.endRefreshing()
                    }
                    self.tableView.reloadData()
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "MMM d, h:mm a"
                    let attrsDictionary = [
                        NSForegroundColorAttributeName : UIColor.darkGray
                    ]
                    
                    let attributedTitle: NSAttributedString = NSAttributedString(string: "Last update: \(dateFormatter.string(from: Date()))", attributes: attrsDictionary)
                    
                    self.refresh.attributedTitle = attributedTitle
                }
                else {
                    print("error getting all users")
                    let alert = UIAlertController(title: "Error retrieving all users", message: "Please check your network connection and try again.", preferredStyle: .alert)
                    let dismiss = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
                    alert.addAction(dismiss)
                    self.present(alert, animated: true, completion: nil)
                }
                
            })
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: -Search Bar/Controller Delegate
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        self.refreshControl = nil
        return true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.refreshControl = refresh
    }
    
    func willPresentSearchController(_ searchController: UISearchController) {
        // do something before the search controller is presented
        self.navigationController!.navigationBar.isTranslucent = true
    }
    
    func willDismissSearchController(_ searchController: UISearchController) {
        self.navigationController!.navigationBar.isTranslucent = false
    }
    
    
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return 1
        }
        else {
            return sectionTitleArray.count
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if searchController.isActive && searchController.searchBar.text != "" {
            return nil
        }
        else {
            return sectionTitleArray[section] as? String
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if searchController.isActive && searchController.searchBar.text != "" {
            if (filteredUsers?.count == 0) {
                noResultsView.isHidden = false
                userCountLabel.isHidden = true
            }
            else {
                noResultsView.isHidden = true
                userCountLabel.isHidden = false
            }
            return filteredUsers!.count
        }
        else {
            if noResultsView != nil {
                noResultsView.isHidden = true
                userCountLabel.isHidden = false
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
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "allUserClassmateCell", for: indexPath) as! ClassmateCell
        let indexUser: User
        if searchController.isActive && searchController.searchBar.text != "" {
            indexUser = filteredUsers![indexPath.row]
        } else {
            let userWithLetterArray: Array = userDict[sectionTitleArray[indexPath.section] as! String]!
            indexUser = userWithLetterArray[indexPath.row]
        }
        cell.nameLabel.text = indexUser.name
        
        cell.contentView.layoutIfNeeded()
        cell.classmateImageView.clipsToBounds = true
        cell.classmateImageView.layer.cornerRadius = cell.classmateImageView.frame.width / 2
        
        cell.initialView.clipsToBounds = true
        cell.initialView.layer.cornerRadius = cell.initialView.frame.width / 2
        
        if (indexUser.profilePicURL != nil) {
            cell.classmateImageView.sd_setImage(with: URL(string:indexUser.profilePicURL!), completed: { (image: UIImage!, error: NSError!, cacheType: SDImageCacheType, url: URL!) in
                if (image != nil && error == nil) {
                    //now that image is downloaded, set current user prof pic
                    if (image.images?.count > 1) {
                        cell.classmateImageView.image = image.images?.first
                    }
                }
                
            } as? SDExternalCompletionBlock)
            
            cell.classmateImageView.isHidden = false
            cell.initialView.isHidden = true
        }
        else {
            let names: [String] = indexUser.name.components(separatedBy: " ")
            if (names.count >= 3) {
                cell.initialLabel.text = "\(names[0][0].uppercased())\(names[1][0].uppercased())\(names[2][0].uppercased())"
            }
            else if (names.count == 2) {
                cell.initialLabel.text = "\(names[0][0].uppercased())\(names[1][0].uppercased())"
                
            }
            else if (names.count == 1) {
                cell.initialLabel.text = "\(names[0][0].uppercased()))"
            }
            else{
                cell.initialLabel.text = nil
            }
            cell.classmateImageView.isHidden = true
            cell.initialView.isHidden = false
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let displayedCell = cell as! ClassmateCell
        displayedCell.classmateImageView.image = nil
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
    }
    
    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return sectionTitleArray.index(of: title)
    }
    
    //MARK: Search Controller Methods
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        if (allUsers != nil){
          filteredUsers = allUsers!.filter { user in
              return user.name.lowercased().contains(searchText.lowercased())
          }
        }
        tableView.reloadData()
    }
    
    //MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showAllUserProfile") {
            let newView = segue.destination as! ProfileVC
            let selectedIndexPath = self.tableView.indexPathForSelectedRow
            let indexUser: User
            if searchController.isActive && searchController.searchBar.text != "" {
                indexUser = filteredUsers![(selectedIndexPath?.row)!]
            } else {
                let userWithLetterArray: Array = userDict[sectionTitleArray[selectedIndexPath!.section] as! String]!
                indexUser = userWithLetterArray[(selectedIndexPath?.row)!]
            }
            newView.currentUser = indexUser
            [(self.tableView.indexPathForSelectedRow?.row)!]
            
            let backButton = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
            
            self.navigationItem.backBarButtonItem = backButton
            
            self.tableView.deselectRow(at: self.tableView.indexPathForSelectedRow!, animated: true)
            
        }
        
    }
    func addBannerViewToView(_ bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        view.addConstraints(
            [NSLayoutConstraint(item: bannerView,
                                attribute: .bottom,
                                relatedBy: .equal,
                                toItem: bottomLayoutGuide,
                                attribute: .top,
                                multiplier: 1,
                                constant: 0),
             NSLayoutConstraint(item: bannerView,
                                attribute: .centerX,
                                relatedBy: .equal,
                                toItem: view,
                                attribute: .centerX,
                                multiplier: 1,
                                constant: 0)
            ])
    }
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        bannerView.alpha = 0
        UIView.animate(withDuration: 1, animations: {
            bannerView.alpha = 1
        })
    }
    
}

extension AllUsersVC: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}
