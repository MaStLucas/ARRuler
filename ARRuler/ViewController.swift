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

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var distanceLabel: UILabel!
    
    var arSession: ARSession!
    var arSessionConfiguration: ARWorldTrackingSessionConfiguration!
    
    var screenCenter: CGPoint?
    
    var firstTap = true
    var startVector: SCNVector3 = SCNVector3.init()
    var endVector: SCNVector3 = SCNVector3.init()
    var startEndNodes: [SCNNode] = []
    var cameraPosition: SCNVector3 = SCNVector3.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.async {
            self.screenCenter = self.sceneView.bounds.mid
        }
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
//        sceneView.showsStatistics = true
        
//        // Create a new scene
//        let scene = SCNScene(named: "art.scnassets/ship.scn")!
//
//        // Set the scene to the view
//        sceneView.scene = scene
        
        sceneView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(handleTap(_:))))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupSessionConfiguration()
        arSession = ARSession()
        arSession.delegate = self
        sceneView.session = self.arSession
        // Run the view's session
        arSession.run(arSessionConfiguration)
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

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if let planeAnchor = anchor as? ARPlaneAnchor {
            let plane = SCNBox.init(width: CGFloat(planeAnchor.extent.x), height: 0, length: CGFloat(planeAnchor.extent.x), chamferRadius: 0)
            plane.firstMaterial?.diffuse.contents = UIColor.clear
            
            let planeNode = SCNNode.init(geometry: plane)
            planeNode.position = SCNVector3.init(planeAnchor.center.x, 0, planeAnchor.center.z)
            
            node.addChildNode(planeNode)
        }
    }
    
    
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    @objc func handleTap(_ recognizer: UITapGestureRecognizer) {
        let point = recognizer.location(in: self.sceneView)
        let results = self.sceneView.hitTest(point, types: .existingPlaneUsingExtent)
        guard results.count != 0 else { return }
        let result = results[0]
        let geometry = SCNSphere.init(radius: 0.01)
        let node = SCNNode.init(geometry: geometry)
        
        let position = SCNVector3.init(result.worldTransform.columns.3.x, result.worldTransform.columns.3.y, result.worldTransform.columns.3.z)
        node.position = position
        
        self.sceneView.scene.rootNode.addChildNode(node)
        
        print("distance: \(result.distance)")
        
        if startEndNodes.count == 0 || startEndNodes.count == 2 {
            startEndNodes.forEach{ $0.removeFromParentNode() }
            startEndNodes.removeAll()
            
            startVector = position
            print("start vector: \(startVector)")
        } else {
            endVector = position
            print("end vector: \(endVector)")
            
            let scale = Float(result.distance) / (cameraPosition-endVector).length()
            let distance = (startVector-endVector).length()*scale
            
            print(distance)
            distanceLabel.text = distance.description
        }
        
        startEndNodes.append(node)
    }
    
    private func setupSessionConfiguration() {
        arSessionConfiguration = ARWorldTrackingSessionConfiguration()
        arSessionConfiguration.isLightEstimationEnabled = true
        arSessionConfiguration.planeDetection = .horizontal
    }
}

extension ViewController: ARSessionDelegate {
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        cameraPosition = SCNVector3.init(frame.camera.transform.columns.3.x, frame.camera.transform.columns.3.y, frame.camera.transform.columns.3.z)
    }
}
