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
    //Views
    var bottomView: BottomView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var trackISSButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//coreLoacation setup
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        loadCurrentLocation()
        Timer.scheduledTimer(timeInterval: 2.0, target:self, selector: #selector(loadCurrentLocation), userInfo: nil, repeats: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        mapPinSetUp()
        bottomViewSetUp()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
//BottomView setup
    func bottomViewSetUp() {
        let width = self.mapView.frame.width
        let height = self.mapView.frame.height / 2
        let mapX = self.mapView.frame.origin.x
        let mapY = self.mapView.frame.origin.y
        
        self.bottomView = BottomView(frame: CGRect.init(x: mapX, y: mapY, width: width, height: height))
        self.bottomView.backgroundColor = UIColor.white
        self.mapView.addSubview(self.bottomView)
        self.bottomView.translatesAutoresizingMaskIntoConstraints = false
        self.bottomView.centerXConstraint = NSLayoutConstraint(item: self.bottomView, attribute: .centerX, relatedBy: .equal, toItem: self.mapView, attribute: .centerX, multiplier: 1.0, constant: 0)
        self.bottomView.centerYConstraint = NSLayoutConstraint(item: self.bottomView, attribute: .centerY, relatedBy: .equal, toItem: self.mapView, attribute: .centerY, multiplier: 1.9, constant: 0)
        self.bottomView.heightConstraint = NSLayoutConstraint(item: self.bottomView, attribute: .height, relatedBy: .equal, toItem: self.mapView, attribute: .height, multiplier: 0.1, constant: 0)
        self.bottomView.widthConstraint = NSLayoutConstraint(item: self.bottomView, attribute: .width, relatedBy: .equal, toItem: self.mapView, attribute: .width, multiplier: 1.0, constant: 0)
        NSLayoutConstraint.activate([self.bottomView.centerXConstraint, self.bottomView.centerYConstraint, self.bottomView.heightConstraint, self.bottomView.widthConstraint])
 
//Swipe gesture setup
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.handleTapGesture(gesture:)))
        swipeUp.direction = .up
        self.bottomView.addGestureRecognizer(swipeUp)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.handleTapGesture(gesture:)))
        swipeDown.direction = .down
        self.bottomView.addGestureRecognizer(swipeDown)

    }
    
//Map setup
    func mapPinSetUp(){
        mapView.delegate = self
        mapView.showsUserLocation = true
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
        
        let longPressRecogniser = UILongPressGestureRecognizer(target: self, action: #selector(ViewController.handleLongPress(_:)))
        longPressRecogniser.minimumPressDuration = 0.5
        mapView.addGestureRecognizer(longPressRecogniser)
        
    }
    
//ISS Satellite Setup
    func loadCurrentLocation(){
        let currentLocation = self.locationManager.location?.coordinate
        let pins = try! coreDataStack.context.fetch(Pin.fetch)
        
        if pins.count > 0 {
            
            let lat = String(self.satelliteMapPin.coordinate.latitude)
            let long = String(self.satelliteMapPin.coordinate.longitude)
            
            
            for pin in pins {
                if(lat == pin.latitude! && long == pin.longitude!) {
                    
                    let alertController = UIAlertController(title: "Look up", message: "The ISS satellite is above \(pin.name)!", preferredStyle: UIAlertControllerStyle.alert)
                    
                    let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
                        print("Ok")
                    }
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
                    
                }
            }
        }
        if(self.satelliteMapPin.coordinate.latitude == currentLocation?.latitude && self.satelliteMapPin.coordinate.longitude == currentLocation?.longitude){
            
            let alertController = UIAlertController(title: "Look up", message: "The ISS satellite is right above you!", preferredStyle: UIAlertControllerStyle.alert)
           
            let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
                print("Ok")
            }
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
            
            
        }
 
        issClient.getISSCurrentLocation { [weak self] (response, error) in
            
                let responseDict = response?["iss_position"] as! Dictionary<String, String>
                let latString = responseDict["latitude"]!
                let longString = responseDict["longitude"]!
                let lat = Double(responseDict["latitude"]!)
                let long = Double(responseDict["longitude"]!)
                let satellite = ISSSatellite.init(latitude: latString, longitude: longString)
            
                DispatchQueue.main.async(execute: {
                    
                    let satelliteLocation = CLLocationCoordinate2DMake(lat!, long!)
                    self?.satelliteMapPin.coordinate = satelliteLocation
                    self?.mapView.removeAnnotation((self?.satelliteMapPin)!)
                    self?.mapView.addAnnotation((self?.satelliteMapPin)!)
                    
                })
        }
        
    }

    @IBAction func trackSatelliteButtonTapped(_ sender: Any) {
        
        let pinToZoomOn = self.satelliteMapPin.coordinate
        let span = MKCoordinateSpanMake(30.0, 30.0)
        let region = MKCoordinateRegion(center: pinToZoomOn, span: span)
        mapView.setRegion(region, animated: true);
    }
    
//Swipe Gestures
    func handleTapGesture(gesture: UISwipeGestureRecognizer) {

        if let swipeGesture = gesture as? UISwipeGestureRecognizer{
            switch swipeGesture.direction {
                
            case UISwipeGestureRecognizerDirection.up:
                print("I was swiped upppp")
                self.bottomView.layoutIfNeeded()
                UIView.animate(withDuration: 0.5, animations: {
                    self.bottomView.ViewChangedSize = true
                    self.bottomView.tableView.isHidden = false
                    self.bottomView.passTimeLabelSetup()
                    self.bottomView.translatesAutoresizingMaskIntoConstraints = false
                    self.bottomView.heightConstraint.isActive = false
                    self.bottomView.heightConstraint = NSLayoutConstraint(item: self.bottomView, attribute: .height, relatedBy: .equal, toItem: self.mapView, attribute: .height, multiplier: 2.0, constant: 0)
                    self.bottomView.heightConstraint.isActive = true
                    NSLayoutConstraint.activate([self.bottomView.heightConstraint])
                    self.view.layoutIfNeeded()
                })
                self.trackISSButton.isHidden = true
                self.trackISSButton.isEnabled = false

                
            case UISwipeGestureRecognizerDirection.down:
                print("I was swipped down")
                UIView.animate(withDuration: 0.5, animations: {
                    self.bottomView.tableView.isHidden = true
                    self.bottomView.translatesAutoresizingMaskIntoConstraints = false
                    self.bottomView.heightConstraint.isActive = false
                    self.bottomView.heightConstraint = NSLayoutConstraint(item: self.bottomView, attribute: .height, relatedBy: .equal, toItem: self.mapView, attribute: .height, multiplier: 0.1, constant: 0)
                    self.bottomView.heightConstraint.isActive = true
                    self.bottomView.passTimeLabelSetup()
                    
                    self.view.layoutIfNeeded()
                })
                self.trackISSButton.isHidden = false
                self.trackISSButton.isEnabled = true

            default:
                print("Defualt Swipe")
            }
        }
        
    }

    func handleLongPress(_ getstureRecognizer : UIGestureRecognizer){
        
        if getstureRecognizer.state != .began { return }

        let alert = UIAlertController(title: "Location Name", message: "Please enter name for Location.", preferredStyle: .alert)
        let touchPoint = getstureRecognizer.location(in: self.mapView)
        let newCoordinates = self.mapView.convert(touchPoint, toCoordinateFrom: self.mapView)
        let markerPin = MarkerPin(coordinate: newCoordinates)
        markerPin.coordinate = newCoordinates
        alert.addTextField { (textField) in
            //
        }
        self.mapView.addAnnotation(markerPin)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0]
            let pin = Pin(context: self.coreDataStack.context)
            pin.name = textField?.text
            let latitude = String(newCoordinates.latitude)
            let longitude = String(newCoordinates.longitude)
            let lat = newCoordinates.latitude
            let long = newCoordinates.longitude
            pin.latitude = latitude
            pin.longitude = longitude
            
            DispatchQueue.global(qos: .background).async {
                issClient.getNextPassTime(lattitude: lat, longitude: long, pin: pin, completionHandler: { (response, error) in
                    
                    //Next passTime handled here
                    let nextPassingTimes = response?["response"] as! [Dictionary<String, AnyObject>]
                    let nextTime = nextPassingTimes.first
                    let duration = String(describing: nextTime?["duration"])
                    guard let riseTime = nextTime?["risetime"] else { return }
                    let riseString = String(describing: riseTime)
                    let rise = Double(riseString)
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "MM/dd/yyyy"
                    let date = dateFormatter.string(from: Date(timeIntervalSince1970: rise!))
                    
                    //Passes handled here
                    let request = response!["request"]! as! Dictionary<String, Any>
                    let passes = String(describing: request["passes"])
        
                    DispatchQueue.main.async {
                        
                        pin.passes = passes
                        pin.nextPassingTime = date
                        self.coreDataStack.saveContext()
                        self.bottomView.tableView.reloadData()
                        
                    }
                })
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
//Custom annotation setup.
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
    
//Zoom to pin selected
    func mapView(_: MKMapView, didSelect view: MKAnnotationView) {
        
        let pinToZoomOn = view.annotation
        let span = MKCoordinateSpanMake(55.0, 55.0)
        let region = MKCoordinateRegion(center: pinToZoomOn!.coordinate, span: span)
        mapView.setRegion(region, animated: true)
        
    }
   
}

