//
//  Distance.swift
//  ARRuler
//
//  Created by StephenMa on 2017/8/18.
//  Copyright © 2017年 Stephen Ma. All rights reserved.
//

import Foundation

enum DistanceUnit: Int {
    case meter, centimeter, inch
}

class Distance {
    
    var value: Float = 0.0
    
    var unit: DistanceUnit = .meter
    
    var displayString: String {
        switch unit {
        case .meter:
            return valueInMeter
        case .centimeter:
            return valueInCentimeter
        case .inch:
            return valueInInch
        }
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
