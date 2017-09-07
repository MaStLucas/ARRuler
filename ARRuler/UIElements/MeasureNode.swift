//
//  MeasureNode.swift
//  ARRuler
//
//  Created by StephenMa on 2017/9/6.
//  Copyright © 2017年 Stephen Ma. All rights reserved.
//

import UIKit
import ARKit

class MeasureNode: SCNNode {

    override init() {
        super.init()
        let geometry = SCNSphere.init(radius: 0.005)
        geometry.firstMaterial?.diffuse.contents = UIColor(named: "GiraffeYellow")!
        self.geometry = geometry
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateScale(cameraPosition: SCNVector3) {
        let distance = (cameraPosition-self.position).length()
        if !distance.isNaN {
            let distanceInCm = CGFloat(distance)*CGFloat(100)
            let radius: CGFloat
            if distance < 0.1 {
                radius = (0.025*distanceInCm+0.5)/CGFloat(100)
            } else if distance > 0.5 {
                radius = (0.025*distanceInCm-0.75)/CGFloat(100)
            } else {
                radius = 0.5/CGFloat(100)
            }
            let geometry = SCNSphere.init(radius: radius)
            geometry.firstMaterial?.diffuse.contents = UIColor(named: "GiraffeYellow")!
            self.geometry = geometry
        }
    }
}
