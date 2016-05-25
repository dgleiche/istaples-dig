//
//  ClassmateCell.swift
//  staplesgotclass
//
//  Created by Dylan Diamond on 5/22/16.
//  Copyright © 2016 Dylan Diamond. All rights reserved.
//

import UIKit

class ClassmateCell: UITableViewCell {
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var classmateImageView: UIImageView!
    @IBOutlet var initialView: UIView!
    @IBOutlet var initialLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
