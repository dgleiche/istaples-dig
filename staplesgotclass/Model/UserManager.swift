//
//  UserManager.swift
//  staplesgotclass
//
//  Created by Dylan Diamond on 5/18/16.
//  Copyright © 2016 Dylan Diamond. All rights reserved.
//

import Foundation
import Alamofire

class UserManager: NSObject {
    static var sharedInstance: UserManager?
    let currentUser: User
    let token: String
    
    private init(name: String, email: String, token: String, completion: ((Bool) -> Void)?) {
        self.currentUser = User(name: name, email: email)
        self.token = token
        super.init()
        self.verifyUser(completion)
    }
    
    class func createCurrentUser(name: String, email: String, token: String, completion: ((Bool) -> Void)?) {
        sharedInstance = UserManager(name: name, email: email, token: token, completion: completion)
    }
    
    func verifyUser(completion: ((Bool) -> Void)?) {
        self.currentUser.network.performRequest(withMethod: "POST", endpoint: "/validateUser", parameters: ["token": self.token], headers: nil) { (response: Response<AnyObject, NSError>) in
            if (response.response?.statusCode == 200) {
                //success
                completion!(true)
                UserManager.sharedInstance?.currentUser.getSchedule({ (success: Bool) in
                    
                })
            }
            else {
                completion!(false)
                UserManager.destroy()
            }
        }
    }
    
    class func destroy() {
        UserManager.sharedInstance = nil
    }
}