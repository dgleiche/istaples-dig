import Foundation
import Alamofire

class UserManager: NSObject {
    static var sharedInstance: UserManager?
    let currentUser: User
    var allUsers = [String: User]()
    let token: String
    
    var teacherNames = [String]()
    var classNames = [String]()
    
    var refreshNeeded = false
    
    fileprivate init(name: String, email: String, token: String, profilePicURL: String?, completion: ((Bool) -> Void)?) {
        self.currentUser = User(name: name, email: email, profilePicURL: profilePicURL)
        
        self.token = token
        super.init()
        self.verifyUser(completion)
    }
    
    class func createCurrentUser(_ name: String, email: String, token: String, profilePicURL: String?, completion: ((Bool) -> Void)?) {
        sharedInstance = UserManager(name: name, email: email, token: token, profilePicURL: profilePicURL, completion: completion)
    }
    
    func verifyUser(_ completion: ((Bool) -> Void)?) {
        self.currentUser.network.performRequest(withMethod: "POST", endpoint: "validateUser", parameters: ["token": self.token, "name": self.currentUser.name], headers: nil) { (response: DataResponse<Any>) in
            if (response.response?.statusCode == 200) {
                if let verifyResponse = response.result.value as? NSDictionary {
                    print("verify response: \(verifyResponse)")
                    if let userID = verifyResponse["userID"] as? Int {
                        self.currentUser.id = userID
                        
                        let tracker = GAI.sharedInstance().defaultTracker
                        
                        // You only need to set User ID on a tracker once. By setting it on the tracker, the ID will be
                        // sent with all subsequent hits.
                        //ADDED ? TO TRACKERs
                        tracker?.set(kGAIUserId, value: "\(userID)")
                        tracker?.set(GAIFields.customMetric(for: 1), value:  "\(userID)")
                        let builder = GAIDictionaryBuilder.createEvent(withCategory: "UX", action: "Sign In", label: nil, value: nil)
                        // This hit will be sent with the User ID value and be visible in User-ID-enabled views (profiles).
                        
                        tracker?.send(builder?.build() as! [AnyHashable: Any])
                        print("sent user id  \(userID)")
                        
                    }
                }
                
                //success
                self.currentUser.network.performRequest(withMethod: "GET", endpoint: "getAutofillData", parameters: nil, headers: nil, completion: { (responseData: DataResponse<Any>) in
                    if (responseData.response?.statusCode == 200) {
                        completion!(true)
                        if let responseJSON = responseData.result.value as? NSDictionary {
                            self.teacherNames = responseJSON["staffList"] as! [String]
                            self.classNames = responseJSON["classList"] as! [String]
                        }
                        if (self.currentUser.profilePicURL != nil) {
                            self.currentUser.network.performRequest(withMethod: "POST", endpoint: "setProfPicURL", parameters: ["url": self.currentUser.profilePicURL!], headers: nil, completion: { (response: DataResponse<Any>) in
                                if (response.response?.statusCode == 200) {
                                    print("updated profile pic url")
                                }
                                else {
                                    print("error updating profile pic url: \(String(describing: response.result.error))")
                                }
                            })
                        }
                    }
                    else {
                        completion!(false)
                    }
                })
            }
            else {
                completion!(false)
                UserManager.destroy()
            }
        }
    }
    
    func getAllUsers(_ completion: ((_ success: Bool, _ userList: [User]?) -> Void)?) {
        self.currentUser.network.performRequest(withMethod: "GET", endpoint: "getUsers", parameters: nil, headers: nil) { (response: DataResponse<Any>) in
            if (response.response?.statusCode == 200) {
                if let userResponse = response.result.value as? [[String : AnyObject]] {
                    var userList = [User]()
                    for selectedUser in userResponse {
                        //check if already in allUsers dict, if not create new. Then add to user list and pass back in completion handler. Fuck yes.
                        if let existingUser = self.allUsers[selectedUser["email"]! as! String]{
                            userList.append(existingUser)
                        }
                        else {
                            let newUser = User(name: selectedUser["name"]! as! String, email: selectedUser["email"]! as! String, profilePicURL: selectedUser["profile_pic_url"] as? String)
                            self.allUsers[selectedUser["email"]! as! String] = newUser
                            userList.append(newUser)
                        }
                        
                    }
                    completion!(true, userList)
                }
                else {
                    completion!(false, nil)
                }
            }
            else {
                completion!(false, nil)
                
            }
        }
    }
    
    class func destroy() {
        UserManager.sharedInstance = nil
    }
}
