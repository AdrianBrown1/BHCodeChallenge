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
        label.font = .systemFont(ofSize: 12)
        return label
    }()
    
    
    //Views Constraints
    var heightConstraint = NSLayoutConstraint()
    var widthConstraint = NSLayoutConstraint()
    var centerXConstraint = NSLayoutConstraint()
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
        self.passTimeLabel.font.withSize(14)
        var labelHeightConstraint = NSLayoutConstraint(item: self.passTimeLabel, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 0.4, constant: 0)
        let labelWidthConstraint = NSLayoutConstraint(item: self.passTimeLabel, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 0.3, constant: 0)
        let labelXConstraint = NSLayoutConstraint(item: self.passTimeLabel, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0)
        var labelYConstraint = NSLayoutConstraint(item: self.passTimeLabel, attribute: .centerY, relatedBy: .equal
            , toItem: self, attribute: .centerY, multiplier: 0.3, constant: 0)
        var topConstraint = NSLayoutConstraint(item: self.passTimeLabel, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 10)
        NSLayoutConstraint.activate([labelHeightConstraint, labelWidthConstraint, labelXConstraint, labelYConstraint, topConstraint])
        
        if ViewChangedSize == true {
            
            labelHeightConstraint.isActive = false
            labelHeightConstraint = NSLayoutConstraint(item: self.passTimeLabel, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 0.1, constant: 0)
            labelHeightConstraint.isActive = true
            labelYConstraint.isActive = false
            labelYConstraint = NSLayoutConstraint(item: self.passTimeLabel, attribute: .centerY, relatedBy: .equal
                , toItem: self, attribute: .centerY, multiplier: 0.2, constant: 0)
            labelYConstraint.isActive = true
            topConstraint.isActive = false
            topConstraint  = NSLayoutConstraint(item: self.passTimeLabel, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 30)
            topConstraint.isActive = true
            NSLayoutConstraint.activate([labelHeightConstraint, labelYConstraint, topConstraint])
            self.ViewChangedSize = false
            
        }
    }
    
    //Table View Set up.
    func tableViewSetup() {
        
        self.addSubview(self.tableView)
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        let tableViewHeightConstraint = NSLayoutConstraint(item: self.tableView, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 0.8, constant: 0)
        let tableVieWidthConstraint = NSLayoutConstraint(item: self.tableView, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 1.0, constant: 0)
        let tableViewCenterXConstraint = NSLayoutConstraint(item: self.tableView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0)
        let tableViewCenterYConstraint = NSLayoutConstraint(item: self.tableView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0)
        
        NSLayoutConstraint.activate([tableViewHeightConstraint,tableVieWidthConstraint, tableViewCenterXConstraint, tableViewCenterYConstraint])
        print(self.tableView)
        
    }
    
    func updatePassTimes(){
        let pins = try! coreDataStack.context.fetch(Pin.fetch)
        
        for pin in pins {
            
            let lat = Double(pin.latitude!)
            let long = Double(pin.longitude!)
            
            DispatchQueue.global(qos: .background).async {
                issClient.getNextPassTime(lattitude: lat!, longitude: long!, pin: pin, completionHandler: { (response, error) in
                    
                    //Next passTime handled here
                    let nextPassingTimes = response?["response"] as! [Dictionary<String, AnyObject>]
                    let nextTime = nextPassingTimes.first
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
                        self.tableView.reloadData()
                        
                    }
                })
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
        let cell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: "Cell")
        let pins = try! coreDataStack.context.fetch(Pin.fetch)
        if pins.count == 0 {
            cell.textLabel?.text = "No Saved Locations"
            cell.detailTextLabel?.text = "Hold on loation to save pin."
            
        }else {
            let pin = pins[indexPath.row]
            cell.textLabel?.text = pin.name
            cell.detailTextLabel?.text = "ISS Next PassTime \(pin.nextPassingTime!)"
        }
        
        
        return cell
    }
    
    
    
    
}
