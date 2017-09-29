//
//  editColorVC.swift
//  staplesgotclass
//
//  Created by Neal Soni on 9/28/17.
//  Copyright © 2017 Dylan Diamond. All rights reserved.
//

import UIKit

class ColorTable: UICollectionView, UICollectionViewDelegate, UICollectionViewDataSource {

    let colors: [UIColor] = [UIColor(red:0.13, green:0.42, blue:0.81, alpha:1.0), //Sweet Blue
                             UIColor(red:0.10, green:0.14, blue:0.49, alpha:1.0), //Dark Blue
                             UIColor(red:0.3, green:0.8, blue:0.13, alpha:1.0),   //Sweet Green
                             UIColor(red:0.11, green:0.37, blue:0.13, alpha:1.0),  //Dark Green
                             UIColor(red:0.84, green:0.00, blue:0.00, alpha:1.0), //Red
                             UIColor(red:0.85, green:0.11, blue:0.38, alpha:1.0), //Pink
                             UIColor(red:0.96, green:0.50, blue:0.09, alpha:1.0), //Orange
                             UIColor(red:1.00, green:0.92, blue:0.23, alpha:1.0), //Yellow
                             UIColor(red:0.78, green:0.73, blue:0.00, alpha:1.0), //Dark yellow
                             UIColor(red:0.47, green:0.33, blue:0.28, alpha:1.0)] //Brown
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)!
        
    }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 35, height: 35);
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("HELLO")
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "colorCell", for: indexPath)
        // Configure the cell
        cell.backgroundColor = colors[indexPath.row]
        cell.layer.cornerRadius = 30
        cell.layer.borderWidth = 1.0
        cell.layer.borderColor = UIColor.clear.cgColor
        cell.layer.masksToBounds = true
        
        return cell
    }
}
