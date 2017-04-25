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
    var satelliteMapPin = SatelliteMapPin(coordinate: CLLocationCoordinate2D(latitude: 0, longitude:0), title: "ISS Satellite")

    //core Data
    let coreDataStack = CoreDataStack.shared
    
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

        //Map setup
        mapView.delegate = self
        mapView.showsUserLocation = true
      
        // coreData saved pins
        let pins = try! coreDataStack.context.fetch(Pin.fetch)
        print(pins.count)
        if pins.count > 0 {
        
            for pin in pins {

                let pinLat = Double(pin.latitude!)
                let pinLong = Double(pin.longitude!)
                
                let markerPin = MarkerPin(coordinate: CLLocationCoordinate2D(latitude: pinLat!, longitude: pinLong!))
             
                
                mapView.addAnnotation(markerPin)
        
            }
            
        mapView.showAnnotations(mapView.annotations, animated: true)
  
        }
        
        // get the particular pin that was tapped
        let pinToZoomOn = locationManager.location?.coordinate
        
        // optionally you can set your own boundaries of the zoom
        let span = MKCoordinateSpanMake(30.0, 30.0)
        
        // now move the map
        let region = MKCoordinateRegion(center: pinToZoomOn!, span: span)
        mapView.setRegion(region, animated: true);
        
        let longPressRecogniser = UILongPressGestureRecognizer(target: self, action: #selector(ViewController.handleLongPress(_:)))
        longPressRecogniser.minimumPressDuration = 0.5
        mapView.addGestureRecognizer(longPressRecogniser)
 
    }
    
    
    
    
    func handleLongPress(_ getstureRecognizer : UIGestureRecognizer){
        
        if getstureRecognizer.state != .began { return }
        print("I was tapped")
        let alert = UIAlertController(title: "Pin's Name", message: "Please enter name for pin.", preferredStyle: .alert)
        
        
        let touchPoint = getstureRecognizer.location(in: self.mapView)
        let newCoordinates = self.mapView.convert(touchPoint, toCoordinateFrom: self.mapView)
        let markerPin = MarkerPin(coordinate: newCoordinates)
        markerPin.coordinate = newCoordinates
        alert.addTextField { (textField) in
            //
        }
        
        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
            markerPin.title = textField?.text
            self.mapView.addAnnotation(markerPin)

        }))
        
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)

        let pin = Pin(context: self.coreDataStack.context)
        let latitude = String(newCoordinates.latitude)
        let longitude = String(newCoordinates.longitude)
        pin.latitude = latitude
        pin.longitude = longitude
        pin.name = markerPin.title
        
        //   use this to save
       coreDataStack.saveContext()
 
    }
    
    func namePinAlert(){
       
    }
 
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        var annotationView: MKAnnotationView?
        
        switch annotation {
        case is SatelliteMapPin:
            
            if let reusedView = mapView.dequeueReusableAnnotationView(withIdentifier: SatelliteMapPin.annotationViewIdentifier) {
                reusedView.annotation = annotation
                annotationView = reusedView
            } else {
                
              
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: SatelliteMapPin.annotationViewIdentifier)
                annotationView?.image = UIImage(named: "satellite")
            }
            break
        case is MarkerPin:
            if let reusedView = mapView.dequeueReusableAnnotationView(withIdentifier: MarkerPin.annotationViewIdentifier) {
                reusedView.annotation = annotation
                annotationView = reusedView
            } else {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: MarkerPin.annotationViewIdentifier)
                annotationView?.image = UIImage(named: "pin")
            }
            break
       
        default:
            print("i am nil")
            return nil
            
        }
        
        return annotationView
        
    }
    
    func mapView(_: MKMapView, didSelect view: MKAnnotationView) {
        // get the particular pin that was tapped
        let pinToZoomOn = view.annotation
        
        // optionally you can set your own boundaries of the zoom
        let span = MKCoordinateSpanMake(55.0, 55.0)
        
        // now move the map
        let region = MKCoordinateRegion(center: pinToZoomOn!.coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    func loadCurrentLocation(){
        //ISS Satellite Setup
        issClient.getISSCurrentLocation { [weak self] (dictionary, error) in
            
            if issClient.satellite?.latitude != nil && issClient.satellite?.longitude != nil {
                
                let lat = Double((issClient.satellite?.latitude)!)!
                let long = Double((issClient.satellite?.longitude)!)!
                let satelliteLocation = CLLocationCoordinate2DMake(lat, long)
                
                self?.satelliteMapPin.coordinate = satelliteLocation
                
                self?.mapView.removeAnnotation((self?.satelliteMapPin)!)
                self?.mapView.addAnnotation((self?.satelliteMapPin)!)
                
            }
        }
        
        
    }
    
    @IBAction func zoomToSatellite(_ sender: Any) {
    
        let pinToZoomOn = satelliteMapPin.coordinate
        
        // optionally you can set your own boundaries of the zoom
        let span = MKCoordinateSpanMake(25.0, 25.0)
        
        // now move the map
        let region = MKCoordinateRegion(center: pinToZoomOn, span: span)
        mapView.setRegion(region, animated: true);
        print("Find the fucking ISS")
    }
    
    
}

