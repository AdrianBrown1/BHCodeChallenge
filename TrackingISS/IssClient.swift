//
//  IssClient.swift
//  TrackingISS
//
//  Created by Adrian Brown on 4/13/17.
//  Copyright © 2017 Adrian Brown. All rights reserved.
//

import Foundation
import Alamofire

class issClient {
    
    static func getISSCurrentLocation( completionHandler: @escaping ([String: Any]?, Error?) -> ()) {
        
        Alamofire.request(Constants.baseURL + Constants.locationURL).responseJSON { response in
            switch response.result {
            case.success(let value):
                completionHandler(value as? NSDictionary as! [String : Any]?, nil)
            case .failure(let error):
                completionHandler(nil, error)
            }
        }
    }
    
    static func getNextPassTime(lattitude: Double, longitude: Double,pin: Pin, completionHandler: @escaping([String: Any]?, Error?) -> ()) {
        
        let passTimeURL = "\(Constants.baseURL)\(Constants.passTimeURL)lat=\(lattitude)&lon=\(longitude)"
        let queue = DispatchQueue(label: "BackgroundQueue", qos: .background, attributes: .concurrent)
        Alamofire.request(passTimeURL).responseJSON(queue: queue) { response in
            switch response.result {
            case.success(let value):
                completionHandler(value as? NSDictionary as! [String : Any]?, nil)
            case .failure(let error):
                completionHandler(nil, error)
            }
        }
    }
}
