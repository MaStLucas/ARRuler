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
    
    var rulerGeometry: SCNBox
    var rulerNode: SCNNode
    
    var startPoint: SCNVector3
    var endPoint: SCNVector3
    
    init(anchor: ARPlaneAnchor?, startPoint: SCNVector3, endPoint: SCNVector3) {
        
        self.planeAnchor = anchor
        self.startPoint = startPoint
        self.endPoint = endPoint
        
        let width = CGFloat((startPoint-endPoint).length())
        self.rulerGeometry = SCNBox.init(width: width, height: 0.002, length: 0.02, chamferRadius: 0.005)
        self.rulerNode = SCNNode(geometry: rulerGeometry)
        
        super.init()
        
        self.addChildNode(rulerNode)
        
        self.position = (startPoint+endPoint)/2
        
        self.rulerNode.transform = calculateTransformMatrix(anchor: planeAnchor, startPoint: startPoint, endPoint: endPoint)
    }
    
    func update(_ endPoint: SCNVector3) {
        self.endPoint = endPoint
        
        let width = CGFloat((startPoint-endPoint).length())
        self.rulerGeometry.width = width
        
        self.position = (startPoint+endPoint)/2
        
        self.rulerNode.transform = calculateTransformMatrix(anchor: planeAnchor, startPoint: startPoint, endPoint: endPoint)
    }
    
    private func calculateTransformMatrix(anchor: ARPlaneAnchor?, startPoint: SCNVector3, endPoint: SCNVector3) -> SCNMatrix4 {
        let flip = SCNMatrix4MakeRotation(-Float.pi / 2.0, 1, 0, 0)
        let translate = SCNMatrix4MakeTranslation(0, 0, 0.01)
        
//        let xAngle = atan2(endPoint.z-startPoint.z, endPoint.y-startPoint.y)+Float.pi/2
//        let xRotate = SCNMatrix4MakeRotation(xAngle, 1, 0, 0)
        let yAngle = atan2(endPoint.z-startPoint.z, endPoint.x-startPoint.x)
        let yRotate = SCNMatrix4MakeRotation(-yAngle, 0, 1, 0)
        let zAngle = atan2(endPoint.y-startPoint.y, endPoint.x-startPoint.x)
        let zRotate = SCNMatrix4MakeRotation(zAngle, 0, 0, 1)
        
        return SCNMatrix4Mult(SCNMatrix4Mult(translate, yRotate), zRotate)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
