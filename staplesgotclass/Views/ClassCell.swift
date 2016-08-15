//
//  ClassCell.swift
//  staplesgotclass
//
//  Created by Dylan Diamond on 5/21/16.
//  Copyright © 2016 Dylan Diamond. All rights reserved.
//

import UIKit

class ClassCell: UITableViewCell {
    @IBOutlet var periodNumberLabel: UILabel!
    @IBOutlet var classTitleLabel: UILabel!
    @IBOutlet var quarterLabel: UILabel!
    @IBOutlet var teacherLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
