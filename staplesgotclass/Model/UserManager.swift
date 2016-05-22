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
    var allUsers = [String: User]()
    let token: String
    
    private init(name: String, email: String, token: String, profilePicURL: String?, completion: ((Bool) -> Void)?) {
        self.currentUser = User(name: name, email: email, profilePicURL: profilePicURL)
        self.token = token
        super.init()
        self.verifyUser(completion)
    }
    
    class func createCurrentUser(name: String, email: String, token: String, profilePicURL: String?, completion: ((Bool) -> Void)?) {
        sharedInstance = UserManager(name: name, email: email, token: token, profilePicURL: profilePicURL, completion: completion)
    }
    
    func verifyUser(completion: ((Bool) -> Void)?) {
        self.currentUser.network.performRequest(withMethod: "POST", endpoint: "/validateUser", parameters: ["token": self.token], headers: nil) { (response: Response<AnyObject, NSError>) in
            if (response.response?.statusCode == 200) {
                //success
                completion!(true)
                
                if (self.currentUser.profilePicURL != nil) {
                    self.currentUser.network.performRequest(withMethod: "POST", endpoint: "/setProfPicURL", parameters: ["url": self.currentUser.profilePicURL!], headers: nil, completion: { (response: Response<AnyObject, NSError>) in
                        if (response.response?.statusCode == 200) {
                            print("updated profile pic url")
                        }
                        else {
                            print("error updating profile pic url: \(response.result.error)")
                        }
                    })
                }
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