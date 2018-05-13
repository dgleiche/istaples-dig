//
//  UIColorExtension.swift
//  CTSports
//
//  Created by Neal Soni on 1/29/18.
//  Copyright © 2018 Neal Soni. All rights reserved.
//


import Foundation
import UIKit

extension UIColor {
    func isLight() -> Bool
    {
        //        let components = CGColorGetComponents(self.cgColor)
        //        let brightness = ((components[0] * 299) + (components[1] * 587) + (components[2] * 114)) / 1000
        var r:CGFloat = 0, g:CGFloat = 0, b:CGFloat = 0, a:CGFloat = 0
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        print(r,g,b,a)
        let brightness = (r + g + b)/3
        print(brightness)
        if brightness < 0.6
        {
            return false
        }
        else
        {
            return true
        }
    }
}
