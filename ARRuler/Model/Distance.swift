//
//  Distance.swift
//  ARRuler
//
//  Created by StephenMa on 2017/8/18.
//  Copyright © 2017年 Stephen Ma. All rights reserved.
//

import Foundation

class Distance {
    
    private var value: Float = 0.0
    
    func setValue(_ v: Float) {
        value = v
    }
    
    var valueInMeter: String {
        return String(format: "%.2f", value)
    }
    
    var valueInCentimeter: String {
        return String(format: "%.2f", value*Float(100))
    }
    
    var valueInInch: String {
        return String(format: "%.2f", value*Float(100)/Float(2.54))
    }
}
