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
    @IBOutlet weak var distanceUnitButton: UIButton!
    @IBOutlet weak var shotButton: UIButton!
    @IBOutlet weak var tipsLabel: Tip!
    @IBOutlet weak var focusHexagon: FocusHexagon!
    @IBOutlet weak var restartButton: UIButton!
    
    @IBOutlet weak var tipsGiraffe: UIImageView!
    @IBOutlet weak var tipsGiraffeBottomMargin: NSLayoutConstraint!
    
    @IBOutlet weak var tipsCenterYConstraint: NSLayoutConstraint!
    @IBOutlet weak var tipsBottomConstraint: NSLayoutConstraint!
    
    var arSession: ARSession!
    
    var firstTap = true
    var startVector: SCNVector3?
    var endVector: SCNVector3?
    var startNode: SCNNode?
    var endNode: SCNNode?
    var cameraPosition: SCNVector3 = SCNVector3.init()
    var distance = Distance()
    
    var distanceFromCameraToStartNode: Float = 0
    var hittestThreshold: Float = 0.02
    
    var planes = [ARPlaneAnchor: Plane]()
    var ruler: Ruler?
    var focusSquare: FocusSquare?
    
    var isMeasuring = false
    var isMeasureEnd = false
    var showDebug = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        arSession = ARSession()
        arSession.delegate = self
        
        setupScene()
        
        sceneView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(handleTap(_:))))
        
        setupFocusSquare()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        restartMeasure()
        restartPlaneDetection()
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
        
        guard canStartMeasure() else { return }
        
        if startVector == nil {
            isMeasuring = true
            hitTestWithScreenCenter()
        } else {
            isMeasuring = false
            captureImageStage()
        }
    }
    
    @IBAction func shotButtonPressed(_ sender: Any) {
        DispatchQueue.main.async {
            
            self.prepareForScreenShot()
            
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
        restartMeasure()
    }
    
    @IBAction func distanceUnitButtonPressed(_ sender: UIButton) {
        guard let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DropDownTable") as? DropDownTableViewController else { return }
        vc.delegate = self
        vc.selectedIndex = distance.unit.rawValue
        vc.modalPresentationStyle = .popover
        vc.preferredContentSize = CGSize.init(width: 100, height: 132)
        if let popover = vc.popoverPresentationController {
            popover.delegate = self
            popover.sourceView = sender
            popover.sourceRect = sender.bounds
        }
        self.present(vc, animated: true, completion: nil)
    }
}

// MARK: - ARSCNViewDelegate
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

// MARK: - ARSessionDelegate
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
        if !isMeasureEnd {
            if self.focusHexagon.isHidden {
                if let rawFeaturePoints = frame.rawFeaturePoints {
                    if rawFeaturePoints.__count > 50 {
                        startMeasureStage()
                    }
                }
            }
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
//        cameraTrackingStateLabel.text = camera.trackingState.presentationString
        print(camera.trackingState.presentationString)
        
        switch camera.trackingState {
        case .normal:
            break
        default:
            restartMeasure()
        }
    }
}

// MARK: - Scene
extension ARRulerViewController {
    
    func setupScene() {
        // set up sceneView
        sceneView.delegate = self
        sceneView.session = arSession
        sceneView.antialiasingMode = .multisampling4X
        sceneView.automaticallyUpdatesLighting = false
        
        sceneView.preferredFramesPerSecond = 60
        
        if showDebug {
//            sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
            sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        }
        
//        if let camera = sceneView.pointOfView?.camera {
//            camera.wantsHDR = true
//            camera.wantsExposureAdaptation = true
//            camera.exposureOffset = -1
//            camera.minimumExposure = -1
//        }
    }
}

// MARK: - Plane
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

// MARK: - Restart Session
extension ARRulerViewController {
    
    fileprivate func restartMeasure() {
        initMeasureStage()
        
        isMeasuring = false
        removeMeasureNodes()
    }
    
    fileprivate func restartPlaneDetection() {
        arSession.run(ARSessionConfigUtil.planeDetectionConfig(), options: [.resetTracking, .removeExistingAnchors])
        
        planes.removeAll()
    }
}

// MARK: - Focus Square
extension ARRulerViewController {
    
    func setupFocusSquare() {
        focusSquare?.isHidden = true
        focusSquare?.removeFromParentNode()
        focusSquare = FocusSquare()
        sceneView.scene.rootNode.addChildNode(focusSquare!)
    }
    
    func updateFocusSquare() {
        let screenCenter = self.sceneView.bounds.mid
        
        if true {
            focusSquare?.hide()
        } else {
            focusSquare?.unhide()
        }
        let (worldPos, planeAnchor, _) = worldPositionFromScreenPosition(screenCenter, objectPos: focusSquare?.position)
        if let worldPos = worldPos {
            focusSquare?.update(for: worldPos, planeAnchor: planeAnchor, camera: self.arSession.currentFrame?.camera)
        }
        if planeAnchor == nil {
            self.focusHexagon.unfocus()
        } else {
            self.focusHexagon.focus()
        }
    }
}

// MARK: - Hit Test
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

// MARK: - Measure
extension ARRulerViewController {
    
    fileprivate func canStartMeasure() -> Bool {
        return !self.focusHexagon.isHidden
    }
    
    fileprivate func hitTestWithScreenCenter() {
        
        guard isMeasuring else {
            return
        }
        
        if let worldPos = focusSquare?.lastPosition {
            if startVector == nil {
                addStartNode(worldPos)
            } else {
                
                updateEndNode(worldPos)
                
                //                let scale = Float(result.distance) / (cameraPosition-endVector!).length()
                //                let distance = (startVector!-endVector!).length()*scale
                
                distance.value = (startVector!-endVector!).length()
                distanceLabel.text = distance.displayString
                
                if distance.value > 0.05 {
                    endMeasureStage()
                } else {
                    moveStage()
                }
                
                drawRuler(startVector: startVector!, endVector: endVector!, distance: CGFloat(distance.value))
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
        geometry.firstMaterial?.diffuse.contents = UIColor(named: "GiraffeYellow")!
        let node = SCNNode.init(geometry: geometry)
        node.position = position
        
        self.sceneView.scene.rootNode.addChildNode(node)
        
        startNode = node
        startVector = position
        
        distanceFromCameraToStartNode = (startVector!-cameraPosition).length()
    }
    
    fileprivate func updateEndNode(_ position: SCNVector3) {
        
        if let endNode = endNode{
            endNode.position = position
        } else {
            let geometry = SCNSphere.init(radius: 0.01)
            geometry.firstMaterial?.diffuse.contents = UIColor(named: "GiraffeYellow")!
            let node = SCNNode.init(geometry: geometry)
            node.position = position
            
            self.sceneView.scene.rootNode.addChildNode(node)
            
            endNode = node
        }
        
        endVector = position
    }
}

// MARK: - UI State
extension ARRulerViewController {
    
    fileprivate func initMeasureStage() {
        tipsLabel.text = "Environment Identifying，please move your phone around"
        tipsLabel.isHidden = false
        distanceLabel.text = "ARuler"
        
        isMeasureEnd = false
        
        shotButton.isHidden = true
        distanceLabel.isHidden = false
        distanceUnitButton.isHidden = true
        focusHexagon.isHidden = true
        restartButton.isHidden = true
        
        tipsCenterYConstraint.isActive = true
        tipsBottomConstraint.isActive = false
        
        tipsGiraffe.isHidden = false
        tipsGiraffeBottomMargin.constant = -20
        UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseInOut, .beginFromCurrentState], animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    fileprivate func startMeasureStage() {
        tipsLabel.text = "Tap to set a start point"
        tipsLabel.isHidden = false
        
        focusHexagon.isHidden = false
//        focusHexagon.animate()
        
        tipsCenterYConstraint.isActive = false
        tipsBottomConstraint.isActive = true
        
        tipsGiraffeBottomMargin.constant = 0
        UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseInOut, .beginFromCurrentState], animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    fileprivate func moveStage() {
        tipsLabel.text = "Move your phone to measure"
        tipsLabel.isHidden = false
        
        distanceLabel.isHidden = false
        distanceUnitButton.isHidden = false
    }
    
    fileprivate func endMeasureStage() {
        tipsLabel.text = "Tap to set an end point"
        tipsLabel.isHidden = false
        
        distanceLabel.isHidden = false
        distanceUnitButton.isHidden = false
        
        restartButton.isHidden = false
    }
    
    fileprivate func captureImageStage() {
        tipsLabel.text = "Capture your image"
        tipsLabel.isHidden = false
        
        isMeasureEnd = true
        
        focusHexagon.isHidden = true
        tipsGiraffe.isHidden = true
        shotButton.isHidden = false
//        shotButton.animate()
    }
    
    fileprivate func prepareForScreenShot() {
        shotButton.isHidden = true
        tipsLabel.isHidden = true
        restartButton.isHidden = true
    }
}

extension ARRulerViewController: UIPopoverPresentationControllerDelegate {
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}

extension ARRulerViewController: DropDownTableViewControllerDelegate {
    
    func dropDownTableViewController(_: DropDownTableViewController, didSelectItemAt index: Int) {
        if index == 0 {
            distance.unit = .meter
            distanceUnitButton.setTitle("m", for: .normal)
        } else if index == 1 {
            distance.unit = .centimeter
            distanceUnitButton.setTitle("cm", for: .normal)
        } else if index == 2 {
            distance.unit = .inch
            distanceUnitButton.setTitle("inch", for: .normal)
        }
        distanceLabel.text = distance.displayString
    }
}
