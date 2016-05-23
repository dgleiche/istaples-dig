//
//  StringExtension.swift
//  staplesgotclass
//
//  Created by Dylan Diamond on 5/21/16.
//  Copyright © 2016 Dylan Diamond. All rights reserved.
//

import Foundation
extension String {
    init(htmlEncodedString: String) {
        if let encodedData = htmlEncodedString.dataUsingEncoding(NSUTF8StringEncoding){
            let attributedOptions : [String: AnyObject] = [
                NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
                NSCharacterEncodingDocumentAttribute: NSUTF8StringEncoding
            ]
            
            do{
                if let attributedString:NSAttributedString = try NSAttributedString(data: encodedData, options: attributedOptions, documentAttributes: nil){
                    self.init(attributedString.string)
                }else{
                    print("error")
                    self.init(htmlEncodedString)     //Returning actual string if there is an error
                }
            }catch{
                print("error: \(error)")
                self.init(htmlEncodedString)     //Returning actual string if there is an error
            }
            
        }else{
            self.init(htmlEncodedString)     //Returning actual string if there is an error
        }
    }
    
    subscript (i: Int) -> Character {
        return self[self.startIndex.advancedBy(i)]
    }
    
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    
    subscript (r: Range<Int>) -> String {
        return substringWithRange(Range(start: startIndex.advancedBy(r.startIndex), end: startIndex.advancedBy(r.endIndex)))
    }
    
    func replace(string:String, replacement:String) -> String {
        return self.stringByReplacingOccurrencesOfString(string, withString: replacement, options: NSStringCompareOptions.LiteralSearch, range: nil)
    }
    
    func removeWhitespace() -> String {
        return self.replace(" ", replacement: "")
    }
}