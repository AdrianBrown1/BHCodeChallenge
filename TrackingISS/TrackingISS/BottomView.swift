//
//  BottomView.swift
//  TrackingISS
//
//  Created by Adrian Brown on 5/2/17.
//  Copyright © 2017 Adrian Brown. All rights reserved.
//

import UIKit

class BottomView: UIView {
    var ViewChangedSize: Bool?
    //core Data
    let coreDataStack = CoreDataStack.shared
    let passTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "ISS PassTimes"
        label.numberOfLines = 2
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 15, weight: UIFontWeightMedium)
        return label
    }()
    //Views Constraints
    var heightConstraint = NSLayoutConstraint()
    var widthConstraint = NSLayoutConstraint()
    var bottomConstraint = NSLayoutConstraint()
    var centerYConstraint = NSLayoutConstraint()
    var tableView = UITableView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(self.passTimeLabel)
        updatePassTimes()
        passTimeLabelSetup()
        tableViewSetup()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.isHidden = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func updateConstraints() {
        super.updateConstraints()
    }
    
    func passTimeLabelSetup() {
        
        self.passTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        let labelHeight = self.passTimeLabel.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.1)
        let labelWidth = self.passTimeLabel.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 1.0)
        let labelTop = self.passTimeLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 20)
        NSLayoutConstraint.activate([labelHeight, labelWidth, labelTop])
        
         if ViewChangedSize == true {
            self.tableView.isHidden = false
            labelTop.constant = 0
            UIView.animate(withDuration: 0.5, animations: {
                self.layoutIfNeeded()
            })
            ViewChangedSize = false
         }
    }
    
    //Table View Set up.
    func tableViewSetup() {
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.isHidden = true
        self.addSubview(self.tableView)
        self.tableView.backgroundColor = UIColor(hue: 0.5778, saturation: 0.58, brightness: 0.94, alpha: 1.0)
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        let tableViewHeightConstraint = self.tableView.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.7)
        let tableVieWidthConstraint = self.tableView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 1.0)
        let tableViewCenterXConstraint = self.tableView.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0)
        let tableViewCenterYConstraint = self.tableView.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0)
        NSLayoutConstraint.activate([tableViewHeightConstraint,tableVieWidthConstraint, tableViewCenterXConstraint, tableViewCenterYConstraint])
    }
    
    func updatePassTimes(){
        
        let pins = try! coreDataStack.context.fetch(Pin.fetch)
        for pin in pins {
            if let lat = pin.latitude, let long = pin.longitude {
            
                guard  let latitude = NumberFormatter().number(from: lat)?.doubleValue else { return }
                guard let longitude = NumberFormatter().number(from: long)?.doubleValue else { return }
                DispatchQueue.global(qos: .background).async {
                    issClient.getNextPassTime(lattitude: latitude, longitude: longitude, pin: pin, completionHandler: { (response, error) in
                        
                        if response != nil {
                            if let response = response {
                                //Next passTime handled here
                                let nextPassingTimes = response["response"] as? [Dictionary<String, AnyObject>]
                                let nextTime = nextPassingTimes?.first
                                guard let riseTime = nextTime?["risetime"] else { return }
                                let riseString = String(describing: riseTime)
                                let rise = NumberFormatter().number(from: riseString)?.doubleValue
                                let dateFormatter = DateFormatter()
                                dateFormatter.dateFormat = "MM/dd/yyyy"
                                let date = dateFormatter.string(from: Date(timeIntervalSince1970: rise!))
                                //Passes handled here
                                let passes = String(describing: response["passes"])
                                DispatchQueue.main.async {
                                    pin.passes = passes
                                    pin.nextPassingTime = date
                                    self.coreDataStack.saveContext()
                                    self.tableView.reloadData()
                                }
                            }
                        }else {
                            print("Error: \(String(describing: error))")
                        }
                    })
                }
            }
        }
    }
}


extension BottomView:  UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let pins = try! coreDataStack.context.fetch(Pin.fetch)
        if pins.count > 0 {
            return pins.count
        }else {
            return 1
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil {
            cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
        }
        let pins = try! coreDataStack.context.fetch(Pin.fetch)
        if pins.count == 0 {
            cell?.textLabel?.text = "No Saved Locations"
            cell?.detailTextLabel?.text = "Hold on loation to save pin."
        }else {
            let pin = pins[indexPath.row]
            cell?.textLabel?.text = pin.name!
            cell?.detailTextLabel?.text = "ISS Next PassTime \(pin.nextPassingTime!)"
        }
        cell?.textLabel?.textColor = UIColor.white
        cell?.textLabel?.font.withSize(20)
        cell?.textLabel?.font.withSize(20)
        cell?.detailTextLabel?.textColor = UIColor.white
        cell?.backgroundColor = UIColor(hue: 0.5778, saturation: 0.58, brightness: 0.94, alpha: 1.0) /* #64aeef */
        return cell!
    }
}
