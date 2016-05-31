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
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var descriptionTextView: UITextView!
    
    //Only viewable on opening page
    @IBOutlet var creditLabel: UILabel!
    
    var pageIndex: Int?
    var titleText: String?
    var imageName: String?
    var descriptionText: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        if self.pageIndex != 0 {
            self.creditLabel.text = ""
        }
        
        if (self.imageName != nil) {
        self.imageView.image = UIImage(named: self.imageName!)?.imageWithColor(UIColor.whiteColor())
        }
        if (self.titleText != nil) {
        self.titleLabel.text = self.titleText
        }
        
        if self.descriptionText != nil {
            self.descriptionTextView.text = self.descriptionText
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
