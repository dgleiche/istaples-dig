//
//  PageContentVC.swift
//  staplesgotclass
//
//  Created by Dylan Diamond on 5/20/16.
//  Copyright © 2016 Dylan Diamond. All rights reserved.
//

import UIKit

class PageContentVC: UIViewController {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var backgroundImageView: UIImageView!
    
    var pageIndex: Int?
    var titleText: String?
    var imageName: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if (self.imageName != nil) {
        self.backgroundImageView.image = UIImage(named: self.imageName!)
        }
        if (self.titleText != nil) {
        self.titleLabel.text = self.titleText
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
