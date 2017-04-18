//
//  ISS-Satellite.swift
//  TrackingISS
//
//  Created by Adrian Brown on 4/17/17.
//  Copyright © 2017 Adrian Brown. All rights reserved.
//

import Foundation


class ISSSatellite {
    
    
    var timeStamp: NSNumber?
    var latitude: String?
    var longitude: String?
    
    init(timeStamp: NSNumber, latitude: String, longitude: String) {
        
        self.timeStamp = timeStamp
        self.latitude = latitude
        self.longitude = longitude
        
    }
    
    
}
