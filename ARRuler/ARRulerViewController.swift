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
    @IBOutlet weak var cameraTrackingStateLabel: UILabel!
    @IBOutlet weak var shotButton: ShotButton!
    @IBOutlet weak var tipsLabel: Tip!
    
    var arSession: ARSession!
    
//    var screenCenter: CGPoint?
    
    var firstTap = true
    var startVector: SCNVector3?
    var endVector: SCNVector3?
    var startNode: SCNNode?
    var endNode: SCNNode?
    var cameraPosition: SCNVector3 = SCNVector3.init()
    
    var distanceFromCameraToStartNode: Float = 0
    var hittestThreshold: Float = 0.02
    
    var planes = [ARPlaneAnchor: Plane]()
    var ruler: Ruler?
    var focusSquare: FocusSquare?
    
    var isMeasuring = false
    var showDebug = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        if showDebug {
            sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
        }
        
        arSession = ARSession()
        arSession.delegate = self
        sceneView.session = self.arSession
        
        sceneView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(handleTap(_:))))
        
        setupFocusSquare()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Run the view's session
        restartPlaneDetection()
        tipsLabel.text = "Tap to start measure"
        shotButton.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        arSession.pause()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
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
            tipsLabel.text = "Capture your image"
            shotButton.isHidden = false
            shotButton.animate()
        }
    }
    
    @IBAction func shotButtonPressed(_ sender: Any) {
        DispatchQueue.main.async {
            // Briefly flash the screen.
            let flashOverlay = UIView(frame: self.sceneView.frame)
            flashOverlay.backgroundColor = UIColor.white
            self.sceneView.addSubview(flashOverlay)
            UIView.animate(withDuration: 0.25, animations: {
                flashOverlay.alpha = 0.0
            }, completion: { _ in
                flashOverlay.removeFromSuperview()
                if let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ShareScene") as? ShareViewController {
                    vc.image = ScreenShotUtil.screenshot()!
                    self.present(vc, animated: true, completion: nil)
                }
            })
        }
    }
    
    @IBAction func resetButtonPressed(_ sender: UIButton) {
        restartPlaneDetection()
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
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        DispatchQueue.main.async {
            self.updateFocusSquare()
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
        cameraTrackingStateLabel.text = camera.trackingState.presentationString
        print(camera.trackingState.presentationString)
    }
}

extension ARRulerViewController {
    
    func addPlane(node: SCNNode, anchor: ARPlaneAnchor) {
        
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
    
    fileprivate func restartPlaneDetection() {
        arSession.run(ARSessionConfigUtil.planeDetectionConfig(), options: [.resetTracking, .removeExistingAnchors])
        
        isMeasuring = false
        removeMeasureNodes()
        planes.removeAll()
    }
}

extension ARRulerViewController {
    
    func setupFocusSquare() {
        focusSquare?.isHidden = true
        focusSquare?.removeFromParentNode()
        focusSquare = FocusSquare()
        sceneView.scene.rootNode.addChildNode(focusSquare!)
    }
    
    func updateFocusSquare() {
        let screenCenter = self.sceneView.bounds.mid
        
        if false {
            focusSquare?.hide()
        } else {
            focusSquare?.unhide()
        }
        let (worldPos, planeAnchor, _) = worldPositionFromScreenPosition(screenCenter, objectPos: focusSquare?.position)
        if let worldPos = worldPos {
            focusSquare?.update(for: worldPos, planeAnchor: planeAnchor, camera: self.arSession.currentFrame?.camera)
        }
    }
}

extension ARRulerViewController {
    
    fileprivate func worldPositionFromScreenPosition(_ position: CGPoint, objectPos: SCNVector3?, infinitePlane: Bool = false)
        -> (position: SCNVector3?, planeAnchor: ARPlaneAnchor?, hitAPlane: Bool) {
        
        // -------------------------------------------------------------------------------
        // 1. Always do a hit test against exisiting plane anchors first.
        //    (If any such anchors exist & only within their extents.)
        
        let planeHitTestResults = sceneView.hitTest(position, types: .existingPlaneUsingExtent)
        if let result = planeHitTestResults.first {
            
            let planeHitTestPosition = SCNVector3.positionFromTransform(result.worldTransform)
            let planeAnchor = result.anchor
            
            // Return immediately - this is the best possible outcome.
            print("Existing Plane Hittest Result")
            return (planeHitTestPosition, planeAnchor as? ARPlaneAnchor, true)
        }
        
        // -------------------------------------------------------------------------------
        // 2. Collect more information about the environment by hit testing against
        //    the feature point cloud, but do not return the result yet.
        
        var featureHitTestPosition: SCNVector3?
        var highQualityFeatureHitTestResult = false
        
        let minDistance = (objectPos == nil) ? 0.2 : distanceFromCameraToStartNode-hittestThreshold
        let highQualityfeatureHitTestResults = sceneView.hitTestWithFeatures(position, coneOpeningAngleInDegrees: 18, minDistance: minDistance, maxDistance: 2.0)
        
        if !highQualityfeatureHitTestResults.isEmpty {
            let result = highQualityfeatureHitTestResults[0]
            featureHitTestPosition = result.position
            highQualityFeatureHitTestResult = true
        }
        
        // -------------------------------------------------------------------------------
        // 3. If desired or necessary (no good feature hit test result): Hit test
        //    against an infinite, horizontal plane (ignoring the real world).
        
        if infinitePlane || !highQualityFeatureHitTestResult {
            
            if let pointOnPlane = objectPos {
                let pointOnInfinitePlane = sceneView.hitTestWithInfiniteHorizontalPlane(position, pointOnPlane)
                if pointOnInfinitePlane != nil {
                    print("Infinite Plane Hittest Result")
                    return (pointOnInfinitePlane, nil, true)
                }
            }
        }
        
        // -------------------------------------------------------------------------------
        // 4. If available, return the result of the hit test against high quality
        //    features if the hit tests against infinite planes were skipped or no
        //    infinite plane was hit.
        
        if highQualityFeatureHitTestResult {
            print("High Quality Feature Hittest Result")
            return (featureHitTestPosition, nil, false)
        }
        
        // -------------------------------------------------------------------------------
        // 5. As a last resort, perform a second, unfiltered hit test against features.
        //    If there are no features in the scene, the result returned here will be nil.
        
//        let unfilteredFeatureHitTestResults = sceneView.hitTestWithFeatures(position)
//        if !unfilteredFeatureHitTestResults.isEmpty {
//            let result = unfilteredFeatureHitTestResults[0]
//            print("Feature Hittest Result")
//            return (result.position, nil, false)
//        }
        
        return (nil, nil, false)
    }
}

extension ARRulerViewController {
    
    fileprivate func hitTestWithScreenCenter() {
        
        guard isMeasuring else {
            return
        }
        
//        let point = self.sceneView.bounds.mid
//
//        let (worldPos, planeAnchor, _) = worldPositionFromScreenPosition(point, objectPos: startVector)
        
//        let results = self.sceneView.hitTest(point, types: [.estimatedHorizontalPlane, .existingPlane])
//        guard results.count != 0 else { return }
//        let result = results[0]
//
//        print("distance: \(result.distance)")
        
        if let worldPos = focusSquare?.lastPosition {
            if startVector == nil {
                addStartNode(worldPos)
            } else {
                tipsLabel.text = "Tap to end"
                updateEndNode(worldPos)
                
                //                let scale = Float(result.distance) / (cameraPosition-endVector!).length()
                //                let distance = (startVector!-endVector!).length()*scale
                let distance = (startVector!-endVector!).length()
                
                distanceLabel.text = String.init(format: "%.2f", distance)
                
                drawRuler(startVector: startVector!, endVector: endVector!, distance: CGFloat(distance))
            }
        }
    }
    
    fileprivate func drawRuler(startVector: SCNVector3, endVector: SCNVector3, distance: CGFloat) {
        DispatchQueue.main.async {
            if let ruler = self.ruler {
                ruler.update(endVector)
            } else {
                self.ruler = Ruler.init(parentNode: self.sceneView.scene.rootNode, startPoint: startVector, endPoint: endVector)
            }
        }
    }
    
    fileprivate func removeMeasureNodes() {
        startNode?.removeFromParentNode()
        startNode = nil
        endNode?.removeFromParentNode()
        endNode = nil
        ruler?.rulerNode.removeFromParentNode()
        ruler = nil
        startVector = nil
        endVector = nil
    }
    
    fileprivate func addStartNode(_ position: SCNVector3) {
        let geometry = SCNSphere.init(radius: 0.01)
        let node = SCNNode.init(geometry: geometry)
        node.position = position
        
        self.sceneView.scene.rootNode.addChildNode(node)
        
        startNode = node
        startVector = position
//        print("start vector: \(startVector!)")
        
        distanceFromCameraToStartNode = (startVector!-cameraPosition).length()
    }
    
    fileprivate func updateEndNode(_ position: SCNVector3) {
        
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
