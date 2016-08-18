//
//  User.swift
//  staplesgotclass
//
//  Created by Dylan Diamond on 5/18/16.
//  Copyright © 2016 Dylan Diamond. All rights reserved.
//

import UIKit
import Foundation
import RealmSwift
import Alamofire

class User: Object {
    dynamic var name: String? = nil
    dynamic var email: String? = nil
    var network: NetworkManager?
    let schedule = List<Period>()
    dynamic var profilePicURL: String? = nil
    var profilePic: UIImage? = nil
    dynamic var id: Int = 0
    dynamic var isCurrentUser: Bool = false
    

    override static func ignoredProperties() -> [String] {
        return ["network", "profilePic"]
    }
    
    class func setup(name: String, email: String, profilePicURL: String?) -> User {
        let user: User = User()
        
        user.name = name
        user.email = email
        user.profilePicURL = profilePicURL
        user.network = NetworkManager()
        
        return user
    }
    
    func getSchedule(completion: ((Bool) -> Void)?) {
        self.network!.performRequest(withMethod: "GET", endpoint: "mySchedule", parameters: nil, headers: nil) { (response: Response<AnyObject, NSError>) in
            print("statusCode: \(response.response!.statusCode)")
            
        }
    }
    
    func getClassmates(completion: ((Bool) -> Void)?) {
        self.network!.performRequest(withMethod: "GET", endpoint: "classmates", parameters: ["email": email!], headers: nil) { (response: Response<AnyObject, NSError>) in
            if (response.response?.statusCode == 200) {
                self.schedule.removeAll()

                if let classData = response.result.value as? NSDictionary {
                    if let periods = classData["periods"] as? [[String: AnyObject]] {
                        for period in periods {
                            var newUsers = [User]()
                            let classmates = classData["classmates"] as! [String : [[String : AnyObject]]]
                            for classmate in classmates["\(period["id"] as! NSNumber)"]! {
                                if let existingUser = UserManager.sharedInstance?.allUsers[classmate["email"]! as! String]{
                                    newUsers.append(existingUser)
                                }
                                else {
                                    
                                    let newUser = User.setup(classmate["name"]! as! String, email: classmate["email"]! as! String, profilePicURL: classmate["profile_pic_url"] as? String)
                                    UserManager.sharedInstance?.allUsers[classmate["email"]! as! String] = newUser
                                    newUsers.append(newUser)
                                } 
                            }
                            let usersList = List<User>()
                            usersList.appendContentsOf(newUsers)
                            
                            let newPeriod = Period.setup(period["name"]! as! String, periodNumber: period["period_number"]! as! Int, teacherName: period["teacher_name"]! as! String, quarters: period["quarters"]! as! String, id: period["id"] as! Int, users: usersList)
                            self.schedule.append(newPeriod)
                        }
                        completion!(true)
                        print("schedule count: \(self.schedule.count)")
                    }
                    else {
                        completion!(false)
                    }
                    
                }
                else {
                    completion!(false)
                }
                
            }
            else {
                completion!(false)
            }
        }
    }
    
    
}
