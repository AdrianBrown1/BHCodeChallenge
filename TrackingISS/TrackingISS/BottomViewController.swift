//
//  BottomViewController.swift
//  TrackingISS
//
//  Created by Adrian Brown on 4/26/17.
//  Copyright © 2017 Adrian Brown. All rights reserved.
//

import Foundation
import UIKit


class BottomView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addBehavior()
    }
    
    convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("This class does not support NSCoding")
    }
    
    func addBehavior() {
        print("Add all the behavior here")
    }    
    
}
