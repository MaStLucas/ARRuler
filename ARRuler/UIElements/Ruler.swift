//
//  Ruler.swift
//  ARRuler
//
//  Created by StephenMa on 2017/7/23.
//  Copyright © 2017年 Stephen Ma. All rights reserved.
//

import Foundation
import ARKit

class Ruler {
    
//    var rulerGeometry: SCNGeometry
    var rulerNode: SCNNode
    
    var startPoint: SCNVector3
    var endPoint: SCNVector3
    
    init(parentNode: SCNNode, startPoint: SCNVector3, endPoint: SCNVector3) {
        
        self.startPoint = startPoint
        self.endPoint = endPoint
        
        self.rulerNode = SCNNode(geometry: SCNGeometry.trianglesFrom(vector: startPoint, toVector: endPoint))
        
        parentNode.addChildNode(rulerNode)
    }
    
    func update(_ endPoint: SCNVector3) {
        self.endPoint = endPoint
        
        self.rulerNode.geometry = SCNGeometry.trianglesFrom(vector: startPoint, toVector: endPoint)
        
//        let width = CGFloat((startPoint-endPoint).length())
//        self.rulerGeometry.width = width
        
//        self.rulerNode.position = SCNVector3.init((startPoint.x+endPoint.x)/2.0, (startPoint.y+endPoint.y)/2.0, (startPoint.z+endPoint.z)/2.0)
        
//        self.rulerNode.transform = calculateTransformMatrix(startPoint: startPoint, endPoint: endPoint)
    }
    
    private func calculateTransformMatrix(startPoint: SCNVector3, endPoint: SCNVector3) -> SCNMatrix4 {
        
        let mid = (startPoint+endPoint)/2.0
        let translate = SCNMatrix4MakeTranslation(mid.x, mid.y, mid.z)
        
        var yAngle = acos((endPoint.x-startPoint.x)/hypot(endPoint.x-startPoint.x, endPoint.z-startPoint.z))
        if endPoint.z-startPoint.z > 0 {
            yAngle = -yAngle
        }
        print("yAngle: \(yAngle/Float.pi*180)")
        let yRotate = SCNMatrix4MakeRotation(yAngle, 0, 1, 0)
        var zAngle = acos((endPoint.x-startPoint.x)/hypot(endPoint.x-startPoint.x, endPoint.y-startPoint.y))
        if endPoint.y-startPoint.y < 0 {
            zAngle = -zAngle
        }
        print("zAngle: \(zAngle/Float.pi*180)")
        let zRotate = SCNMatrix4MakeRotation(zAngle, 0, 0, 1)
        
        return SCNMatrix4Mult(SCNMatrix4Mult(yRotate, zRotate), translate)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SCNGeometry {
    
    class func lineFrom(vector vector1: SCNVector3, toVector vector2: SCNVector3) -> SCNGeometry {
        
        var vertices: [SCNVector3] = []
        var indices: [Int32] = []
        
        vertices.append(contentsOf: [vector1, vector2])
        indices.append(contentsOf: [0, 1])
        
        let source = SCNGeometrySource(vertices: vertices)
        let element = SCNGeometryElement(indices: indices, primitiveType: .line)
        
        let geometry = SCNGeometry(sources: [source], elements: [element])
        geometry.firstMaterial?.diffuse.contents = UIColor.white
        geometry.firstMaterial?.isDoubleSided = true
        
        return geometry
    }
    
    class func trianglesFrom(vector vector1: SCNVector3, toVector vector2: SCNVector3) -> SCNGeometry {
        
        let slice: Float = 0.01+0.005*2
        let direction = (vector2-vector1).normalized()
        let distance = (vector2-vector1).length()
        
        var vertices: [SCNVector3] = []
        var indices: [Int32] = []
        
        let count = Int(floor((distance-0.01*2)/slice))
        guard count > 1 else {
            return lineFrom(vector:vector1, toVector:vector2)
        }
        for i in 0...count-1 {
            indices.append(Int32(i*6))
            indices.append(Int32(i*6+1))
            indices.append(Int32(i*6+2))
            indices.append(Int32(i*6+3))
            indices.append(Int32(i*6+4))
            indices.append(Int32(i*6+5))
        }
        
        var vector = SCNVector3Zero
        for index in 0...count-1 {
            vector.x = vector1.x + 0.01*direction.x + Float(index)*slice*direction.x + 0.005*direction.x
            vector.y = vector1.y + 0.01*direction.y + Float(index)*slice*direction.y + 0.005*direction.y + 0.005
            vector.z = vector1.z + 0.01*direction.z + Float(index)*slice*direction.z + 0.005*direction.z
            vertices.append(vector)
            
            vector.x = vector1.x + 0.01*direction.x + Float(index)*slice*direction.x + 0.005*direction.x
            vector.y = vector1.y + 0.01*direction.y + Float(index)*slice*direction.y + 0.005*direction.y - 0.005
            vector.z = vector1.z + 0.01*direction.z + Float(index)*slice*direction.z + 0.005*direction.z
            vertices.append(vector)
            
            vector.x = vector1.x + 0.01*direction.x + Float(index)*slice*direction.x + 0.005*direction.x + 0.01*direction.x
            vector.y = vector1.y + 0.01*direction.y + Float(index)*slice*direction.y + 0.005*direction.y + 0.005 + 0.01*direction.y
            vector.z = vector1.z + 0.01*direction.z + Float(index)*slice*direction.z + 0.005*direction.z + 0.01*direction.z
            vertices.append(vector)
            
            vector.x = vector1.x + 0.01*direction.x + Float(index)*slice*direction.x + 0.005*direction.x + 0.005*direction.x
            vector.y = vector1.y + 0.01*direction.y + Float(index)*slice*direction.y + 0.005*direction.y - 0.005 + 0.005*direction.y
            vector.z = vector1.z + 0.01*direction.z + Float(index)*slice*direction.z + 0.005*direction.z + 0.005*direction.z
            vertices.append(vector)
            
            vector.x = vector1.x + 0.01*direction.x + Float(index)*slice*direction.x + 0.005*direction.x + 0.01*direction.x + 0.005*direction.x
            vector.y = vector1.y + 0.01*direction.y + Float(index)*slice*direction.y + 0.005*direction.y + 0.005 + 0.01*direction.y + 0.005*direction.y
            vector.z = vector1.z + 0.01*direction.z + Float(index)*slice*direction.z + 0.005*direction.z + 0.01*direction.z + 0.005*direction.z
            vertices.append(vector)
            
            vector.x = vector1.x + 0.01*direction.x + Float(index)*slice*direction.x + 0.005*direction.x + 0.01*direction.x + 0.005*direction.x
            vector.y = vector1.y + 0.01*direction.y + Float(index)*slice*direction.y + 0.005*direction.y - 0.005 + 0.01*direction.y + 0.005*direction.y
            vector.z = vector1.z + 0.01*direction.z + Float(index)*slice*direction.z + 0.005*direction.z + 0.01*direction.z + 0.005*direction.z
            vertices.append(vector)
        }
        
        let source = SCNGeometrySource(vertices: vertices)
        let element = SCNGeometryElement(indices: indices, primitiveType: .triangles)
        
        let geometry = SCNGeometry(sources: [source], elements: [element])
        geometry.firstMaterial?.diffuse.contents = UIColor(named: "GiraffeYellow")!
        geometry.firstMaterial?.isDoubleSided = true
        
        return geometry
    }
}
