//
//  editColorVC.swift
//  staplesgotclass
//
//  Created by Neal Soni on 9/28/17.
//  Copyright © 2017 Dylan Diamond. All rights reserved.
//

import UIKit
let colors: [UIColor] = [UIColor(red:0.13, green:0.42, blue:0.81, alpha:1.0), //Sweet Blue
                        UIColor(red:0.10, green:0.14, blue:0.49, alpha:1.0), //Dark Blue
                        UIColor(red:0.32, green:0.55, blue:0.81, alpha:1.0), //Blue 3
                        UIColor(red:0.30, green:0.80, blue:0.13, alpha:1.0), //Sweet Green
                        UIColor(red:0.11, green:0.37, blue:0.13, alpha:1.0), //Dark Green
                        UIColor(red:0.84, green:0.00, blue:0.00, alpha:1.0), //Red
                        UIColor(red:0.93, green:0.27, blue:0.29, alpha:1.0), //Red 2
                        UIColor(red:0.85, green:0.11, blue:0.38, alpha:1.0), //Pink
                        UIColor(red:1.00, green:0.27, blue:0.41, alpha:1.0), //Pink 2
                        UIColor(red:0.99, green:0.51, blue:0.12, alpha:1.0), //Orange
                        UIColor(red:1.00, green:0.92, blue:0.23, alpha:1.0), //Yellow
                        UIColor(red:0.78, green:0.73, blue:0.00, alpha:1.0)] //Dark yellow

class ColorTable: UICollectionView, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var currentClass: Period?
    
   
    var selectedColor: Int?
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! ColorCell
        cell.layer.borderWidth = 4.0
        cell.layer.borderColor = colors[indexPath.row].cgColor
        currentClass?.colorInt = indexPath.row
        cell.select()
        print("selected: \(indexPath.row)")
        selectedColor = indexPath.row
    }
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? ColorCell
        cell?.layer.borderWidth = 0.0
        cell?.innerCircle.layer.borderWidth = 0
        cell?.unselect()
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let customCell = cell as! ColorCell
        if customCell.isSelected {
            customCell.select()
        } else {
            customCell.unselect()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 35, height: 35);
    }

    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "colorCell", for: indexPath) as! ColorCell
        // Configure the cell
//        print("colorInt: \(currentClass?.colorInt)")
//        if (indexPath.row == (currentClass?.colorInt)){
//            collectionView.selectItem(at: indexPath, animated: true, scrollPosition: UICollectionViewScrollPosition.centeredHorizontally)
//        }
        cell.backgroundColor = colors[indexPath.row]
        cell.layer.cornerRadius = 30
        cell.layer.borderColor = UIColor.clear.cgColor
        cell.layer.masksToBounds = true
        
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOpacity = 1
        cell.layer.shadowOffset = CGSize.zero
        cell.layer.shadowRadius = 4
        
        return cell
    }
    


}
