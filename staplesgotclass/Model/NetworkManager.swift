//
//  NetworkManager.swift
//  staplesgotclass
//
//  Created by Dylan Diamond on 5/18/16.
//  Copyright © 2016 Dylan Diamond. All rights reserved.
//

import UIKit
import Alamofire

class NetworkManager: NSObject {
        let baseURL = "https://shsgotclass.herokuapp.com/api"
        var alamofireManager : SessionManager?
    
        override init() {
            let configuration = URLSessionConfiguration.default
            configuration.timeoutIntervalForResource = 15 // seconds
            configuration.httpMaximumConnectionsPerHost = 4
            self.alamofireManager = Alamofire.SessionManager(configuration: configuration)
        }
        
        //func performRequest(withMethod method: String, endpoint: String, parameters: [String : String]?, headers: [String : String]?, completion: (Response<AnyObject, NSError>) -> Void) {
    func performRequest(withMethod method: String, endpoint: String, parameters: [String : String]?, headers: [String : String]?, completion: @escaping (DataResponse<Any>) -> Void) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        //self.alamofireManager!.request(returnMethod(method), "\(baseURL)/\(endpoint)", headers: headers, parameters: parameters)
        self.alamofireManager!.request( "\(baseURL)/\(endpoint)", method: returnMethod(method), parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            //print("request body: \(NSString(data:(response.request?.HTTPBody)!, encoding:NSUTF8StringEncoding) as String?)")
            print(response.request?.allHTTPHeaderFields as Any) // URL response
            print(response.response as Any) // URL response
            print(response.data as Any)     // server data
            print(response.result)   // result of response serialization
            
            print("I AM IN NETWORKMANAGER")
            completion(response)
            
        }
    }
    
    
        func returnMethod(_ name: String) -> Alamofire.HTTPMethod {
            switch name {
            case "GET":
                return Alamofire.HTTPMethod.get
            case "POST":
                return Alamofire.HTTPMethod.post
            default:
                print("returning get")
                return Alamofire.HTTPMethod.get
            }
        }

}
