//
//  ViewController.swift
//  TrackingISS
//
//  Created by Adrian Brown on 4/13/17.
//  Copyright © 2017 Adrian Brown. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation


class ViewController: UIViewController, CLLocationManagerDelegate,MKMapViewDelegate {
  
    var locationManager: CLLocationManager!
    var latitude: Double?
    var longitude: Double?
    let satellitePin = MKPointAnnotation()
    var longPressWasHit: Bool = false
    
    @IBOutlet weak var mapView: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        Timer.scheduledTimer(timeInterval: 3.0, target:self, selector: #selector(loadCurrentLocation), userInfo: nil, repeats: true)
        
        

       
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        satellitePinSetup()

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func satellitePinSetup(){

        mapView.delegate = self
        mapView.addAnnotation(satellitePin)
        
        satellitePin.title = "ISS Satelite"
        mapView.showAnnotations(mapView.annotations, animated: true)
        
        
        let pinToZoomOn = mapView.annotations[0]
        // optionally you can set your own boundaries of the zoom
        let span = MKCoordinateSpanMake(150.0, 150.0)
        // now move the map
        let region = MKCoordinateRegion(center: pinToZoomOn.coordinate, span: span)
        mapView.setRegion(region, animated: true)
        
        let longPressRecogniser = UILongPressGestureRecognizer(target: self, action: #selector(ViewController.handleLongPress(_:)))
        longPressRecogniser.minimumPressDuration = 0.5
        mapView.addGestureRecognizer(longPressRecogniser)


   
        
    }
    
    
    func handleLongPress(_ getstureRecognizer : UIGestureRecognizer){
        if getstureRecognizer.state != .began { return }
        
        print("I was tapped")
        
        let touchPoint = getstureRecognizer.location(in: mapView)
        let newCoordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        let annotation = MKPointAnnotation()
        annotation.coordinate = newCoordinates
        annotation.title = "my pin"
        mapView.addAnnotation(annotation)
        self.longPressWasHit = true
        
       
        
    }
    
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
       
        
        if longPressWasHit == true {

            if !(annotation is MKPointAnnotation) {
                return nil
            }
            let annotation = MKPointAnnotation()
            
            let annotationIdentifier = "pin"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier)
            
            if annotationView == nil {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
                annotationView!.canShowCallout = true
            }
            else {
                annotationView!.annotation = annotation
            }
            let pinImage = UIImage(named: "pin")
            annotationView!.image = pinImage

            return annotationView
            
        }else {
            
            if !(annotation is MKPointAnnotation) {
                return nil
            }
            
            let annotationIdentifier = "satillite"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier)
            
            if annotationView == nil {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
                annotationView!.canShowCallout = true
            }
            else {
                annotationView!.annotation = annotation
            }
            
            let pinImage = UIImage(named: "satillite")
            annotationView!.image = pinImage
            
            return annotationView

        }
        
        
    }
    
    func mapView(_: MKMapView, didSelect view: MKAnnotationView) {
        
        // get the particular pin that was tapped
        let pinToZoomOn = view.annotation
        
        // optionally you can set your own boundaries of the zoom
        let span = MKCoordinateSpanMake(25.0, 25.0)
        
        // now move the map
        let region = MKCoordinateRegion(center: pinToZoomOn!.coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
    

    
    func loadCurrentLocation(){

        issClient.getISSCurrentLocation { (dictionary, error) in
            if issClient.satellite?.latitude != nil && issClient.satellite?.longitude != nil {
                
                let lat = Double((issClient.satellite?.latitude)!)
                let long = Double((issClient.satellite?.longitude)!)
                let satelliteLocation = CLLocationCoordinate2DMake(lat!, long!)
                
                //Set satellite location
                self.satellitePin.coordinate = satelliteLocation
             
            }

            
        }
        
    }
    
    
    }

    



