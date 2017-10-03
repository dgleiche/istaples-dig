//
//  ColorCell.swift
//  staplesgotclass
//
//  Created by Neal Soni on 9/26/17.
//  Copyright © 2017 Dylan Diamond. All rights reserved.
//

import UIKit

class ColorCell: UICollectionViewCell {
    
    @IBOutlet var innerCircle: UIView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        print("init—>Not being called???\n")
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    func select(){
        self.innerCircle.isHidden = false
        self.innerCircle.layer.cornerRadius = 25
        self.innerCircle.layer.borderWidth = 6
        self.innerCircle.layer.borderColor = UIColor.white.cgColor
        self.innerCircle.layer.shadowColor = UIColor.black.cgColor
        self.innerCircle.layer.shadowOpacity = 1
        self.innerCircle.layer.shadowOffset = CGSize.zero
        self.innerCircle.layer.shadowRadius = 3
    }
    func unselect(){
        self.innerCircle.isHidden = true
        
    }

}
