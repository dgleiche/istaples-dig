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
    @IBOutlet var quarterLabel: UILabel?
    @IBOutlet var teacherLabel: UILabel!
    @IBOutlet var timeLabel: UILabel?
    @IBOutlet var lunchNumberLabel: UILabel?
    @IBOutlet var labView: UIView?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.labView?.layer.cornerRadius = 6
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
