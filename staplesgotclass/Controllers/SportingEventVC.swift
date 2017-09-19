//
//  SportingEventVC.swift
//  staplesgotclass
//
//  Created by Neal Soni on 9/15/17.
//  Copyright © 2017 Dylan Diamond. All rights reserved.
//

import Foundation
import UIKit


class SportingEventVC: UIViewController {
    let sweetBlue = UIColor(red:0.13, green:0.42, blue:0.81, alpha:1.0)
    
    override func viewDidLoad(){
        super.viewDidLoad()

        self.navigationController?.navigationBar.barTintColor = self.sweetBlue
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "AppleSDGothicNeo-UltraLight", size: 15)!, NSForegroundColorAttributeName: UIColor.white]
        UIApplication.shared.statusBarStyle = .lightContent
        self.navigationItem.title = "SPORTS SCHEDULE"
        
    }
    
}

func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if (segue.identifier == "showProfile") {
        let newView = segue.destination as! SportingEventVC
        
        let backButton = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
        
        //self.navigationItem.backBarButtonItem = backButton
        
        
    }
    
}
