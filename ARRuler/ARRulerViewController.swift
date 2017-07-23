//
//  ViewController.swift
//  ARRuler
//
//  Created by StephenMa on 2017/7/11.
//  Copyright © 2017年 Stephen Ma. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ARRulerViewController: UIViewController {

    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var mode: UISegmentedControl!
    
    var arSession: ARSession!
    
//    var screenCenter: CGPoint?
    
    var firstTap = true
    var startVector: SCNVector3?
    var endVector: SCNVector3?
    var startNode: SCNNode?
    var endNode: SCNNode?
    var cameraPosition: SCNVector3 = SCNVector3.init()
    
    var planes = [ARPlaneAnchor: Plane]()
    var ruler: Ruler?
    
    var isMeasuring = false
    var showDebug = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        DispatchQueue.main.async {
//            self.screenCenter = self.sceneView.bounds.mid
//        }
        
        // Set the view's delegate
        sceneView.delegate = self
        
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
        
        // Show statistics such as fps and timing information
//        sceneView.showsStatistics = true
        
//        // Create a new scene
//        let scene = SCNScene(named: "art.scnassets/ship.scn")!
//
//        // Set the scene to the view
//        sceneView.scene = scene
        
        sceneView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(handleTap(_:))))
//        sceneView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(handleTapTest(_:))))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        arSession = ARSession()
        arSession.delegate = self
        sceneView.session = self.arSession
        // Run the view's session
        arSession.run(ARSessionConfigUtil.planeDetectionConfig())
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        arSession.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    @IBAction func modeChanged(_ sender: UISegmentedControl) {
        startNode?.removeFromParentNode()
        endNode?.removeFromParentNode()
        ruler?.removeFromParentNode()
    }
    
    @objc func handleTapTest(_ recognizer: UITapGestureRecognizer) {
        guard let currentFrame = sceneView.session.currentFrame else {
            return
        }
        let imagePlane = SCNPlane.init(width: sceneView.bounds.width/6000, height: sceneView.bounds.height/6000)
        imagePlane.firstMaterial?.diffuse.contents = sceneView.snapshot()
        imagePlane.firstMaterial?.lightingModel = .constant
        
        let planeNode = SCNNode.init(geometry: imagePlane)
        sceneView.scene.rootNode.addChildNode(planeNode)
        
        var translation = matrix_identity_float4x4
        translation.columns.3.z = -0.1
        planeNode.simdTransform = matrix_multiply(currentFrame.camera.transform, translation)
    }
    
    @objc func handleTap(_ recognizer: UITapGestureRecognizer) {
        
//        let point = recognizer.location(in: self.sceneView)
        
        if startVector == nil {
            hitTestWithScreenCenter()
            isMeasuring = true
        } else {
            isMeasuring = false
        }
    }
}

extension ARRulerViewController: ARSCNViewDelegate {
    
    /*
     // Override to create and configure nodes for anchors added to the view's session.
     func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
     let node = SCNNode()
     
     return node
     }
     */
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        DispatchQueue.main.async {
            if let planeAnchor = anchor as? ARPlaneAnchor {
                self.addPlane(node: node, anchor: planeAnchor)
            }
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        DispatchQueue.main.async {
            if let planeAnchor = anchor as? ARPlaneAnchor {
                self.updatePlane(anchor: planeAnchor)
            }
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        DispatchQueue.main.async {
            if let planeAnchor = anchor as? ARPlaneAnchor {
                self.removePlane(anchor: planeAnchor)
            }
        }
    }
}

extension ARRulerViewController: ARSessionDelegate {
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        cameraPosition = SCNVector3.init(
            frame.camera.transform.columns.3.x,
            frame.camera.transform.columns.3.y,
            frame.camera.transform.columns.3.z
        )
        if startVector != nil {
            hitTestWithScreenCenter()
        }
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        print("Session failed with: \(error)")
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        print("Session interrupted")
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        print("Session interruption end")
    }
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        print(camera.trackingState.presentationString)
    }
}

extension ARRulerViewController {
    func addPlane(node: SCNNode, anchor: ARPlaneAnchor) {
        
        let pos = SCNVector3.positionFromTransform(anchor.transform)
        
        let plane = Plane(anchor, showDebug)
        
        planes[anchor] = plane
        node.addChildNode(plane)
    }
    
    func updatePlane(anchor: ARPlaneAnchor) {
        if let plane = planes[anchor] {
            plane.update(anchor)
        }
    }
    
    func removePlane(anchor: ARPlaneAnchor) {
        if let plane = planes.removeValue(forKey: anchor) {
            plane.removeFromParentNode()
        }
    }
}

extension ARRulerViewController {
    
    fileprivate func hitTestWithScreenCenter() {
        
        guard isMeasuring else {
            return
        }
        
        let point = self.sceneView.bounds.mid
        
        let results = self.sceneView.hitTest(point, types: [.estimatedHorizontalPlane, .existingPlane])
        guard results.count != 0 else { return }
        let result = results[0]
        
        print("distance: \(result.distance)")
        
        
        if startVector == nil {
            addStartNode(result)
        } else {
            updateEndNode(result)
            
            let scale = Float(result.distance) / (cameraPosition-endVector!).length()
            let distance = (startVector!-endVector!).length()*scale
            
            print(distance)
            distanceLabel.text = distance.description
            
            drawRuler(startVector: startVector!, endVector: endVector!, distance: CGFloat(distance))
        }
    }
    
    fileprivate func drawRuler(startVector: SCNVector3, endVector: SCNVector3, distance: CGFloat) {
        DispatchQueue.main.async {
            if let ruler = self.ruler {
                ruler.update(endVector)
            } else {
                self.ruler = Ruler.init(anchor: nil, startPoint: startVector, endPoint: endVector)
                
                if let ruler = self.ruler {
                    self.sceneView.scene.rootNode.addChildNode(ruler)
                }
            }
        }
    }
    
    fileprivate func removeMeasureNodes() {
        startNode?.removeFromParentNode()
        endNode?.removeFromParentNode()
        ruler?.removeFromParentNode()
        startVector = nil
        endVector = nil
    }
    
    fileprivate func addStartNode(_ result: ARHitTestResult) {
        let geometry = SCNSphere.init(radius: 0.01)
        let node = SCNNode.init(geometry: geometry)
        let position = SCNVector3.init(result.worldTransform.columns.3.x, result.worldTransform.columns.3.y, result.worldTransform.columns.3.z)
        node.position = position
        
        self.sceneView.scene.rootNode.addChildNode(node)
        
        startNode = node
        startVector = position
//        print("start vector: \(startVector!)")
    }
    
    fileprivate func updateEndNode(_ result: ARHitTestResult) {
        
        let position = SCNVector3.init(result.worldTransform.columns.3.x, result.worldTransform.columns.3.y, result.worldTransform.columns.3.z)
        
        if let endNode = endNode{
            endNode.position = position
        } else {
            let geometry = SCNSphere.init(radius: 0.01)
            let node = SCNNode.init(geometry: geometry)
            node.position = position
            
            self.sceneView.scene.rootNode.addChildNode(node)
            
            endNode = node
        }
        
        endVector = position
//        print("end vector: \(endVector!)")
    }
}
