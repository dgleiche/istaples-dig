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
        let baseURL = "http://www.staplesgotclass.com/api"
        var alamofireManager : Alamofire.Manager?
        
        override init() {
            let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
            configuration.timeoutIntervalForResource = 15 // seconds
            configuration.HTTPMaximumConnectionsPerHost = 4
            self.alamofireManager = Alamofire.Manager(configuration: configuration)
        }
        
        func performRequest(withMethod method: String, endpoint: String, parameters: [String : String]?, headers: [String : String]?, completion: (Response<AnyObject, NSError>) -> Void) {
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            self.alamofireManager!.request(returnMethod(method), "\(baseURL)/\(endpoint)", headers: headers, parameters: parameters)
                .responseJSON { response in
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                    //print("request body: \(NSString(data:(response.request?.HTTPBody)!, encoding:NSUTF8StringEncoding) as String?)")
                    print(response.request?.allHTTPHeaderFields) // URL response
                    print(response.response) // URL response
                    //print(response.data)     // server data
                    print(response.result)   // result of response serialization
//                    if let JSON = response.result.value {
//                        print("JSON: \(JSON)")
//                    }
                    completion(response)
            }
        }
    
    
        func returnMethod(name: String) -> Alamofire.Method {
            switch name {
            case "GET":
                return Alamofire.Method.GET
            case "POST":
                return Alamofire.Method.POST
            default:
                print("returning get")
                return Alamofire.Method.GET
            }
        }

}
