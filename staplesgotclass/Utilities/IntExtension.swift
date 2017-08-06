//
//  IntExtension.swift
//  staplesgotclass
//
//  Created by Dylan Diamond on 8/20/16.
//  Copyright © 2016 Dylan Diamond. All rights reserved.
//

import Foundation

extension Int {
    
    func secondsToHoursMinutesSeconds() -> (Int, Int, Int) {
        return (self / 3600, (self % 3600) / 60, (self % 3600) % 60)
    }
    func printSecondsToHoursMinutesSeconds() -> String {
        let (h, m, _) = self.secondsToHoursMinutesSeconds()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "H:mm"
        let inDate = dateFormatter.date(from: String(format: "%d:%02d", h, m))
        dateFormatter.dateFormat = "h:mm"
        return dateFormatter.string(from: inDate!)
    }
}
