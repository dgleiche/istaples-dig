//
//  aboutVC.swift
//  staplesgotclass
//
//  Created by Dylan on 5/30/16.
//  Copyright © 2016 Dylan Diamond. All rights reserved.
//

import UIKit

class AboutVC: UIViewController {
    
    @IBOutlet weak var textField: UITextView!
    
    var navTitle: String?
    
    var text: String?
    
    override func viewDidLoad() {
        self.navigationController!.title = self.navTitle ?? ""
        
        textField.text = self.text ?? ""
    }
}
