//
//  PlaneDebugVisualization.swift
//  ARRuler
//
//  Created by StephenMa on 2017/7/23.
//  Copyright © 2017年 Stephen Ma. All rights reserved.
//

import Foundation
import ARKit

class PlaneDebugVisualization: SCNNode {
    
    var planeAnchor: ARPlaneAnchor
    
    var planeGeometry: SCNPlane
    var planeNode: SCNNode
    
    init(anchor: ARPlaneAnchor) {
        
        self.planeAnchor = anchor
        
        let grid = UIImage(named: "art.scnassets/plane_grid.png")
        self.planeGeometry = createPlane(size: CGSize(width: CGFloat(anchor.extent.x), height: CGFloat(anchor.extent.z)),
                                         contents: grid)
        self.planeNode = SCNNode(geometry: planeGeometry)
        self.planeNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2.0, 1, 0, 0)
        
        super.init()
        
        self.addChildNode(planeNode)
        
        self.position = SCNVector3(anchor.center.x, -0.002, anchor.center.z) // 2 mm below the origin of plane.
    }
    
    func update(_ anchor: ARPlaneAnchor) {
        self.planeAnchor = anchor
        
        self.planeGeometry.width = CGFloat(anchor.extent.x)
        self.planeGeometry.height = CGFloat(anchor.extent.z)
        
        self.position = SCNVector3Make(anchor.center.x, -0.002, anchor.center.z)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
