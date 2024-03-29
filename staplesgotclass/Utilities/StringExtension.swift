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
        if let encodedData = htmlEncodedString.data(using: String.Encoding.utf8){
            let attributedOptions : [String: AnyObject] = [
                NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType as AnyObject,
                NSCharacterEncodingDocumentAttribute: String.Encoding.utf8 as AnyObject
            ]
            
            do{
                if let attributedString:NSAttributedString = try NSAttributedString(data: encodedData, options: attributedOptions, documentAttributes: nil){
                    self.init(attributedString.string)!
                }else{
                    print("error")
                    self.init(htmlEncodedString)!     //Returning actual string if there is an error
                }
                
            }catch{
                print("error: \(error)")
                self.init(htmlEncodedString)!     //Returning actual string if there is an error
            }
            
        }else{
            self.init(htmlEncodedString)!     //Returning actual string if there is an error
        }
    }
    
    subscript (i: Int) -> Character {
        return self[self.characters.index(self.startIndex, offsetBy: i)]
    }
    
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    
    subscript (r: Range<Int>) -> String {
        return substring(with: (characters.index(startIndex, offsetBy: r.lowerBound) ..< characters.index(startIndex, offsetBy: r.upperBound)))
    }
    
    func replace(_ string:String, replacement:String) -> String {
        return self.replacingOccurrences(of: string, with: replacement, options: NSString.CompareOptions.literal, range: nil)
    }
    
    func removeWhitespace() -> String {
        return self.replace(" ", replacement: "")
    }
    
    func convertSpecialCharacters() -> String {
        var newString = self
        let char_dictionary = [
            "&amp;" : "&",
            "&lt;" : "<",
            "&gt;" : ">",
            "&quot;" : "\"",
            "&apos;" : "'"
        ];
        for (escaped_char, unescaped_char) in char_dictionary {
            newString = newString.replacingOccurrences(of: escaped_char, with: unescaped_char, options: NSString.CompareOptions.literal, range: nil)
        }
        return newString
    }
    func getInitals() -> String{
        let school = self.replacingOccurrences(of: "of", with: "").replacingOccurrences(of: "the", with: "").replacingOccurrences(of: " @ ", with: "").replacingOccurrences(of: " & ", with: "").replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "")
        var initials = ""
        for word in school.split(separator: " "){
            if (initials.characters.count < 2){
                initials = initials + String(word)[0]
            }
        }
        return initials
    }
}

extension String {
    func getRanges(of string: String) -> [NSRange] {
        var ranges:[NSRange] = []
        if contains(string) {
            let words = self.components(separatedBy: " ")
            var position: Int = 0
            for word in words {
                if word.lowercased() == string.lowercased() {
                    let startIndex = position
                    let endIndex = word.count
                    let range = NSMakeRange(startIndex, endIndex)
                    ranges.append(range)
                }
                position += (word.count + 1)
            }
        }
        return ranges
    }
}
