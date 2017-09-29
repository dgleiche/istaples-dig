//
//  ColorCell.swift
//  staplesgotclass
//
//  Created by Neal Soni on 9/26/17.
//  Copyright © 2017 Dylan Diamond. All rights reserved.
//

import UIKit

class ColorCell: UICollectionViewCell {

    override init(frame: CGRect) {
        super.init(frame: frame)
        print("init—>Not being called???\n")
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
