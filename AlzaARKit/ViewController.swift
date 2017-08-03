//
//  ViewController.swift
//  AlzaARKit
//
//  Created by Andrey Mosin on 31/07/2017.
//  Copyright © 2017 Alza. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var planeGeometry: SCNPlane?
    var planes: [UUID : Plane] = [:]
    
    var modelPlaced: SCNNode?
    var modelOrigin: SCNVector3?
    var modelPos: SCNVector3? {
        didSet {
            if let pos = modelPos {
                modelPlaced?.worldPosition = pos
                
                
                print("Current Position: \(modelPlaced?.position)")
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]
        
        sceneView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ViewController.handleTap(from:))))
        sceneView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(ViewController.handlePan(from:))))
        
        
        self.sceneView.automaticallyUpdatesLighting = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingSessionConfiguration()
        configuration.planeDetection = .horizontal
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    @objc func handleTap(from sender: UITapGestureRecognizer) {
        let point = sender.location(in: sceneView)
        let hitTestRes = sceneView.hitTest(point, types: ARHitTestResult.ResultType.existingPlaneUsingExtent)
        
        if hitTestRes.isEmpty {
            return
        }
        placeModel(on: hitTestRes.first!)
    }
    
    @objc func handlePan(from sender: UIPanGestureRecognizer) {
        if modelPlaced != nil, var modelPos = modelPos {
            let translation = sender.translation(in: view)
            
            switch sender.state {
            case .began, .changed:
                modelPos = SCNVector3Make(modelPos.x + Float(translation.x) * 0.005, modelPos.y, modelPos.z + Float(translation.y) * 0.005)
                
                modelPlaced?.worldPosition = modelPos
                
            case .cancelled:
                modelPos = modelPlaced!.worldPosition
                break
                
            default: break
            }
            
        }
    }
    
    func placeModel(on plane: ARHitTestResult) {
        if let model = SCNScene(named: "tv.dae")?.rootNode.childNode(withName: "tv", recursively: true), modelPlaced == nil {
            let pos = SCNVector3Make(plane.worldTransform.columns.3.x, plane.worldTransform.columns.3.y + 0.001, plane.worldTransform.columns.3.z)
            model.rotateCool()
            self.sceneView.scene.rootNode.addChildNode(model)
            model.position = pos
            modelPlaced = model
            modelOrigin = pos
            modelPos = pos
        }
    }

    // MARK: - ARSCNViewDelegate
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if let anchor = anchor as? ARPlaneAnchor {
            let plane = Plane(anchor: anchor)
            node.addChildNode(plane)
            self.planes[anchor.identifier] = plane
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        if let plane = self.planes[anchor.identifier], let anchor = anchor as? ARPlaneAnchor {
            plane.update(with: anchor)
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        if let lightEstimate = sceneView.session.currentFrame?.lightEstimate {
            self.sceneView.scene.lightingEnvironment.intensity = lightEstimate.ambientIntensity / 1000
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
    
}
