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
    
    static var satellite: ISSSatellite?
    
    static func getISSCurrentLocation( completionHandler: @escaping ([String: Any]?, Error?) -> ()) {

        let issLocationURL = "http://api.open-notify.org/iss-now.json"
        
        Alamofire.request(issLocationURL).responseJSON { response in
            
            switch response.result {
            case.success(let value):
               
                completionHandler(value as? NSDictionary as! [String : Any]?, nil)
                let dictionary: Dictionary = value as! [String: Any]
                let position: Dictionary  = dictionary["iss_position"] as! [String: String]
                let lat = position["latitude"]
                let long = position["longitude"]
                let timeStamp = dictionary["timestamp"]
                
                self.satellite = ISSSatellite.init(timeStamp: timeStamp! as! NSNumber, latitude: lat!, longitude: long!)
                
            case .failure(let error):
                completionHandler(nil, error)

            }
 
      
        }
    
    }
    
    static func getNextPassTime(lattitude: Double, longitude: Double, completionHandler: @escaping([String: Any]?, Error?) -> ()) {
        
        let passTimeURL = "http://api.open-notify.org/iss-pass.json?lat=\(lattitude)&lon=\(longitude)"
        
        Alamofire.request(passTimeURL).responseJSON { response in
            
            
            if let JSON = response.result.value {
                print("JSON: \(JSON)")
                
                
                
            }
        }
        
        
        
        
    }
    
    
    
}
