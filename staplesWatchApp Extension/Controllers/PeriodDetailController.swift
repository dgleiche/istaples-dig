//
//  PeriodDetailController.swift
//  staplesgotclass
//
//  Created by Dylan Diamond on 9/5/16.
//  Copyright © 2016 Dylan Diamond. All rights reserved.
//

import WatchKit
import Foundation


class PeriodDetailController: WKInterfaceController {

    @IBOutlet var periodNumberLabel: WKInterfaceLabel!
    @IBOutlet var periodTitleLabel: WKInterfaceLabel!
    @IBOutlet var teacherLabel: WKInterfaceLabel!
    @IBOutlet var quartersLabel: WKInterfaceLabel!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        self.setTitle("Close")
        let selectedPeriod = context as! WatchSchedulePeriod
        if let realPeriod = selectedPeriod.realPeriod {
            periodTitleLabel.setText(realPeriod.name)
            periodNumberLabel.setText("\(realPeriod.periodNumber)")
            teacherLabel.setText(realPeriod.teacherName!)
            quartersLabel.setText("Quarters: \(realPeriod.quarters!)")
        }
        else {
            periodTitleLabel.setText(selectedPeriod.name)
            periodNumberLabel.setText("\(selectedPeriod.name!.characters.first)")
        }
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
