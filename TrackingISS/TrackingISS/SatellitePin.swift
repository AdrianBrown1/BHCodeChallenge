//
//  SatillitePin.swift
//  TrackingISS
//
//  Created by Adrian Brown on 4/19/17.
//  Copyright © 2017 Adrian Brown. All rights reserved.
//

import Foundation
import MapKit


class SatelliteMapPin: NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    static var annotationViewIdentifier = "satellite"
    var title: String?
    var subtitle: String?
    
    init(coordinate: CLLocationCoordinate2D, title: String) {
        self.coordinate = coordinate
        self.title = title
        super.init()
    }
    
}
