//
//  MarkerPin.swift
//  TrackingISS
//
//  Created by Adrian Brown on 4/19/17.
//  Copyright © 2017 Adrian Brown. All rights reserved.
//

import Foundation
import MapKit

class MarkerPin: NSObject, MKAnnotation {
    
    static var annotationViewIdentifier = "pin"
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
        super.init()
    }
    
}
