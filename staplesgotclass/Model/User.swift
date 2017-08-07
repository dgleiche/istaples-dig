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
    let profilePicURL: String?
    var profilePic: UIImage? = nil
    var id: Int?
    
    init(name: String, email: String, profilePicURL: String?) {
        self.name = name
        self.email = email
        self.profilePicURL = profilePicURL
        self.network = NetworkManager()
    }
    
    func getSchedule(_ completion: ((Bool) -> Void)?) {
        self.network.performRequest(withMethod: "GET", endpoint: "mySchedule", parameters: nil, headers: nil) { (response: DataResponse<Any>) in
            print("statusCode: \(response.response!.statusCode)")
            
        }
    }
    
    func getClassmates(_ completion: ((Bool) -> Void)?) {
        //print("GET CLASSMATES")
        self.network.performRequest(withMethod: "GET", endpoint: "classmates", parameters: ["email": email], headers: nil) { (response: DataResponse<Any>) in

            if (response.response?.statusCode == 200) {
                self.schedule = [Period]()

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
                                    
                                    let newUser = User(name: classmate["name"]! as! String, email: classmate["email"]! as! String, profilePicURL: classmate["profile_pic_url"] as? String)
                                    UserManager.sharedInstance?.allUsers[classmate["email"]! as! String] = newUser
                                    newUsers.append(newUser)
                                }
                            }

                            let newPeriod = Period(name: period["name"]! as! String, periodNumber: period["period_number"]! as! Int, teacherName: period["teacher_name"]! as! String, quarters: period["quarters"]! as! String, id: period["id"] as! Int, users: newUsers)

                            self.schedule?.append(newPeriod)
                        }

                        completion!(true)
                        print("schedule count: \(self.schedule!.count)")
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
