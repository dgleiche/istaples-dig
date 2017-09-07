//
//  GameCell.swift
//  staplesgotclass
//
//  Created by Jack Sharkey on 9/6/17.
//  Copyright © 2017 Dylan Diamond. All rights reserved.
//


import UIKit

class SportsCell: UITableViewCell {
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var sport: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var school: UILabel!
    @IBOutlet weak var home: UILabel!
    @IBOutlet weak var away: UILabel!    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

