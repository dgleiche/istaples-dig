//
//  InfoVC.swift
//  staplesgotclass
//
//  Created by Dylan on 5/30/16.
//  Copyright © 2016 Dylan Diamond. All rights reserved.
//
import UIKit
import MessageUI
import PopupDialog

var removeAds = false

class InfoVC: UITableViewController, MFMailComposeViewControllerDelegate {
    @IBOutlet var versionNumberLabel: UILabel!
    @IBOutlet weak var adsSwitch2: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.barTintColor = UIColor(red:0.13, green:0.42, blue:0.81, alpha:1.0)
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "AppleSDGothicNeo-UltraLight", size: 15)!, NSForegroundColorAttributeName: UIColor.white]
        UIApplication.shared.statusBarStyle = .lightContent
        let backButton = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
        
        self.navigationItem.backBarButtonItem = backButton

        self.navigationItem.title = "INFO"
        
        self.versionNumberLabel.text = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        adsSwitch2.setOn(( (defaults.object(forKey: "ads") as? Bool) ?? false), animated: false)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.SKProductsDidLoadFromiTunes), name: NSNotification.Name.init("SKProductsHaveLoaded"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.StoreManagerDidPurchaseNonConsumable(notification:)), name: NSNotification.Name.init("DidPurchaseNonConsumableProductNotification"), object: nil)
        SKProductsDidLoadFromiTunes()

    }
    override func viewDidAppear(_ animated: Bool) {
    }
    func StoreManagerDidPurchaseNonConsumable(notification:Notification){
        guard let id = notification.userInfo?["id"] else {
            return
        }
        DispatchQueue.main.async {
            //self.tableView.reloadData()
        }
    }
    
    
    func SKProductsDidLoadFromiTunes(){
        
        
        DispatchQueue.main.async { //main thread to update UI

        }
        
        
    }
    
    func logout() {
        self.dismiss(animated: true, completion: nil)
        NotificationCenter.default.post(name: Notification.Name(rawValue: "logout"), object: nil)
    }
    
    @IBAction func ads(_ sender: Any) {
        removeAds = adsSwitch2.isOn
        if removeAds {
            self.showAlertPopup()
        }
        //StoreManager.shared.buy(product: StoreManager.shared.productsFromStore[0])
        defaults.set(removeAds, forKey: "ads")
        
    }
    func sendMail(_ address: String) {
        let toRecipents = [address]
        let mc = MFMailComposeViewController()
        mc.mailComposeDelegate = self
        mc.setToRecipients(toRecipents)
        mc.setSubject("iStaples App")
        mc.setMessageBody("\n\nFrom,\n\(UserManager.sharedInstance!.currentUser.name)", isHTML: false)
        
        //TODO: CHECK IF MAIL VC IS PRESENTED ON iPHONE!
        self.present(mc, animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller:MFMailComposeViewController, didFinishWith result:MFMailComposeResult, error:Error?) {
        switch result {
        case MFMailComposeResult.cancelled:
            print("Mail cancelled")
        case .saved:
            print("Mail saved")
        case .sent:
            print("Mail sent")
        case .failed:
            print("Mail sent failure: \(String(describing: error?.localizedDescription))")
        default:
            break
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: Table View Functions
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 && indexPath.row == 0 {
            UIApplication.shared.openURL(URL(string: "http://staplesgotclass.com")!)
        }
        else if indexPath.section == 3 {
            switch indexPath.row {
            case 0:
                print("Email Diamond")
                sendMail("dylan@dcdwebdesign.com")
            case 1:
                print("Email Gleicher")
                sendMail("dgleiche@me.com")
            case 2:
                print("Email Neal")
                sendMail("ns51387@students.westportps.org")
            case 3:
                print("Email Sharkey")
                sendMail("sharkeyjack11@gmail.com")
            default:
                break
            }
        }
        
        else if indexPath.section == 3 {
            //Log out button
            print("logout")
            logout()
        }
        
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: Navigation
    
    
    @IBAction func donePressed(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    
    
    //Set the text for the two info things
    
    let aboutText = "iStaples allows students of Staples High School to track their classes and their classmates. This app is designed to be easier and more mobile than the web interface, staplesgotclass.com. You can also view your friends' schedules, along with their classmates."
    
    let securityText = "This app works by logging you in to our servers through a token generated by a Google OAuth login. As Google OAuth is utilized, passwords are NOT NOR COULD BE at any time stored or accessed by this app. Google handles all credentials, thus the security of this app is the security of a Google log in. \n \nBy using this app, you agree that anonymous analytic data may be collected to help improve future use of iStaples."
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "aboutSegue" {
            let newView = segue.destination as! AboutVC
            
            newView.title = "About SHS Got Class"
            newView.text = aboutText
        }
        
        else if segue.identifier == "securitySegue" {
            let newView = segue.destination as! AboutVC
            
            newView.title = "Security Information"
            newView.text = securityText
        }
    }
    func showAlertPopup() {
        // Prepare the popup assets
        let title = "Remove Ads"
        let message = "Remove ads from all pages on iStaples for $3.99. This is a one time purchase. Please restart app for purchase to take effect."
        let image = UIImage(named: "adScreenshot.png")
        
        // Create the dialog
        let pv = PopupDialogDefaultView.appearance()
        pv.titleFont    = UIFont(name: "HelveticaNeue-Light", size: 25)!
        let popup = PopupDialog(title: title, message: message, image: image, buttonAlignment: .horizontal, gestureDismissal: false)
        
        // Create buttons
        let buttonOne = CancelButton(title: "Not Now", height: 40) {
            defaults.set(true, forKey: "ads")
            self.dismiss(animated: true, completion: nil)
            
        }
        let buttonTwo = DefaultButton(title: "Redeem", height: 40) {
            self.dismiss(animated: true, completion: nil)
        }
        
        let buttonThree = SolidBlueButton(title: "Buy $3.99", height: 55) {
            self.dismiss(animated: true, completion: nil)
        }
        
        // Add buttons to dialog
        popup.addButtons([buttonOne, buttonTwo, buttonThree])
        
        // Present dialog
        self.present(popup, animated: true, completion: nil)
    }
}
public final class SolidBlueButton: PopupDialogButton {
    
    override public func setupView() {
        defaultTitleFont      = UIFont.boldSystemFont(ofSize: 16)
        defaultTitleColor     = UIColor.white
        defaultButtonColor    = UIColor(red:0.00, green:0.44, blue:0.71, alpha:1.0)
        defaultSeparatorColor = UIColor.clear
        super.setupView()
    }
}

