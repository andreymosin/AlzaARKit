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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]
        
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(handleTap(from:)))
        sceneView.addGestureRecognizer(tapGR)
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
    
    func placeModel(on plane: ARHitTestResult) {
        
        if let model = SCNScene(named: "tv.dae")?.rootNode.childNode(withName: "tv", recursively: true) {
            model.position = SCNVector3Make(plane.worldTransform.columns.3.x, plane.worldTransform.columns.3.y, plane.worldTransform.columns.3.z)
            model.rotateCool()
            model.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
            model.physicsBody?.mass = 2
            self.sceneView.scene.rootNode.addChildNode(model)
        }
    }

    // MARK: - ARSCNViewDelegate
    
    var nbool = false
    
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
