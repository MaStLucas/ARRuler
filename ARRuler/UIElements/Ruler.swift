//
//  Ruler.swift
//  ARRuler
//
//  Created by StephenMa on 2017/7/23.
//  Copyright © 2017年 Stephen Ma. All rights reserved.
//

import Foundation
import ARKit

class Ruler: SCNNode {

    var planeAnchor: ARPlaneAnchor?
    
    var rulerGeometry: SCNPlane
    var rulerNode: SCNNode
    
    var startPoint: SCNVector3
    var endPoint: SCNVector3
    
    init(anchor: ARPlaneAnchor?, startPoint: SCNVector3, endPoint: SCNVector3) {
        
        self.planeAnchor = anchor
        self.startPoint = startPoint
        self.endPoint = endPoint
        
        self.rulerGeometry = SCNPlane(width: CGFloat((startPoint-endPoint).length()), height: 0.02)
        self.rulerNode = SCNNode(geometry: rulerGeometry)
        self.rulerNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2.0, 1, 0, 0)
        
        super.init()
        
        self.addChildNode(rulerNode)
        
        self.position = (startPoint+endPoint)/2
    }
    
    func update(_ endPoint: SCNVector3) {
        
        self.rulerGeometry.width = CGFloat((startPoint-endPoint).length())
        
        self.position = (startPoint+endPoint)/2
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
