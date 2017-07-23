//
//  Plane.swift
//  ARRuler
//
//  Created by StephenMa on 2017/7/23.
//  Copyright © 2017年 Stephen Ma. All rights reserved.
//

import Foundation
import ARKit

class Plane: SCNNode {
    
    var anchor: ARPlaneAnchor
    
    var debugVisualization: PlaneDebugVisualization?
    
    init(_ anchor: ARPlaneAnchor, _ showDebugVisualization: Bool) {
        self.anchor = anchor
        
        super.init()
        
        self.showDebugVisualization(showDebugVisualization)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(_ anchor: ARPlaneAnchor) {
        self.anchor = anchor
        debugVisualization?.update(anchor)
    }
    
    func showDebugVisualization(_ show: Bool) {
        if show {
            if debugVisualization == nil {
                DispatchQueue.global().async {
                    self.debugVisualization = PlaneDebugVisualization(anchor: self.anchor)
                    DispatchQueue.main.async {
                        self.addChildNode(self.debugVisualization!)
                    }
                }
            }
        } else {
            debugVisualization?.removeFromParentNode()
            debugVisualization = nil
        }
    }
}
