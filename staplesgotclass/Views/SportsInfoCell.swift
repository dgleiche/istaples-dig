//
//  SportsInfoCell.swift
//  staplesgotclass
//
//  Created by Neal Soni on 9/20/17.
//  Copyright © 2017 Dylan Diamond. All rights reserved.
//

import Foundation


import UIKit

class SportsInfoCell: UITableViewCell {
    
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var info: UILabel!
    @IBOutlet weak var classTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
