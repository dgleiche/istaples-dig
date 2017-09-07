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
        let url: String! = "\(baseURL)/\(endpoint)"
        self.alamofireManager?.request(url, method: returnMethod(method), parameters: parameters, headers: headers).responseJSON(completionHandler: { (response: DataResponse<Any>) in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            //print(response.response ?? "no response") // URL response
            //print(response.data ?? "no data")     // server data
            
            //print(response.result)   // result of response serialization
            completion(response)
        })
    }
    
    
    func returnMethod(_ name: String) -> Alamofire.HTTPMethod {
        switch name {
        case "GET":
            return Alamofire.HTTPMethod.get
        case "POST":
            return Alamofire.HTTPMethod.post
        default:
            //print("returning get")
            return Alamofire.HTTPMethod.get
        }
    }
    
}
