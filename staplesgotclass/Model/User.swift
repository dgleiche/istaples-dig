//
//  User.swift
//  staplesgotclass
//
//  Created by Dylan Diamond on 5/18/16.
//  Copyright © 2016 Dylan Diamond. All rights reserved.
//

import UIKit
import Alamofire

class User: NSObject {
    let name: String
    let email: String
    let network: NetworkManager
    var schedule: [Period]?
    
    init(name: String, email: String) {
        self.name = name
        self.email = email
        self.network = NetworkManager()
    }
    
    func getSchedule(completion: ((Bool) -> Void)?) {
        self.network.performRequest(withMethod: "GET", endpoint: "mySchedule", parameters: nil, headers: nil) { (response: Response<AnyObject, NSError>) in
            print("statusCode: \(response.response!.statusCode)")
            
        }
    }
    

}
