//
//  ViewController.swift
//  AlzaARKit
//
//  Created by Andrey Mosin on 31/07/2017.
//  Copyright © 2017 Alza. All rights reserved.
//

import UIKit
import SceneKit
import SceneKit.ModelIO
import ARKit
import ModelIO

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
    
    var ambientLight = SCNLight()
    var pointLight = SCNLight()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]
        
        
        sceneView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ViewController.handleTap(from:))))
        sceneView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(ViewController.handlePan(from:))))
        
        ambientLight.type = .ambient
        
//        let node = SCNNode()
//        node.light = ambientLight
//        self.sceneView.scene.rootNode.addChildNode(node)
//
        self.sceneView.scene.lightingEnvironment.contents = UIImage.init(named: "TunnelHDRI")
        
        self.sceneView.automaticallyUpdatesLighting = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        configuration.isLightEstimationEnabled = true
        
        // Run the view's session
        sceneView.session.run(configuration)
        
    }
    
    func addSpotLight(at position: SCNVector3) {
        pointLight.type = .spot
        pointLight.spotInnerAngle = 180
        pointLight.spotOuterAngle = 180
        
        let spotNode = SCNNode()
        spotNode.light = pointLight
        spotNode.position = position
        
        spotNode.eulerAngles = SCNVector3Make(-Float.pi / 2, 0, 0)
        sceneView.scene.rootNode.addChildNode(spotNode)
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
        
        if let url = Bundle.main.url(forResource: "TEFZN017", withExtension: "obj") {
            do {
                let node = try SCNScene(url: url, options: [.checkConsistency: true]).rootNode.childNodes[0]
                
                node.geometry?.firstMaterial?.lightingModel = .physicallyBased
                
                node.rotateCool()
                sceneView.scene.rootNode.addChildNode(node)
                node.position = SCNVector3Make(plane.worldTransform.columns.3.x, plane.worldTransform.columns.3.y + 0.01, plane.worldTransform.columns.3.z)
            } catch {
                print(error)
            }
        }
        
        
        //Lednicka
//        let cube = SCNBox(width: 0.6, height: 0.6, length: 1.80, chamferRadius: 0)
//
//        let color = UIImage(named: "1")?.getPixelColor(atLocation: CGPoint(x: 150, y: 5), withFrameSize: CGSize(width: 1, height: 1))
//        let mat = SCNMaterial()
//        mat.diffuse.contents = color
//        mat.lightingModel = .blinn
//
//        let material6 = SCNMaterial()
//        material6.diffuse.contents = UIImage(named: "6")
//
//        cube.materials = [mat, mat, mat, mat, mat, material6]
//        let node = SCNNode(geometry: cube)
//
//        node.rotateCool()
//
//        self.sceneView.scene.rootNode.addChildNode(node)
//        node.position = SCNVector3Make(plane.worldTransform.columns.3.x, plane.worldTransform.columns.3.y + 0.9, plane.worldTransform.columns.3.z)
    }
    
    // Gesture Recognizers
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
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
//            ambientLight.intensity = lightEstimate.ambientIntensity
//            pointLight.intensity = lightEstimate.ambientIntensity
            
            sceneView.scene.lightingEnvironment.intensity = lightEstimate.ambientIntensity / 250
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

extension UIImage {
    func rotate(by degrees: CGFloat) -> UIImage {
        let size = self.size
        
        UIGraphicsBeginImageContext(size)
        
        let bitmap: CGContext = UIGraphicsGetCurrentContext()!
        //Move the origin to the middle of the image so we will rotate and scale around the center.
        bitmap.translateBy(x: size.width / 2, y: size.height / 2)
        //Rotate the image context
        bitmap.rotate(by: (degrees * CGFloat(Float.pi / 180)))
        //Now, draw the rotated/scaled image into the context
        bitmap.scaleBy(x: 1.0, y: -1.0)
        
        let origin = CGPoint(x: -size.width / 2, y: -size.width / 2)
        
        bitmap.draw(self.cgImage!, in: CGRect(origin: origin, size: size))
        
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
    func getPixelColor(atLocation location: CGPoint, withFrameSize size: CGSize) -> UIColor {
        let x = location.x
        let y = location.y
        
        let pixelPoint: CGPoint = CGPoint(x: x, y: y)
        
        let pixelData = self.cgImage!.dataProvider!.data
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        
        let pixelIndex: Int = ((Int(self.size.width) * Int(pixelPoint.y)) + Int(pixelPoint.x)) * 4
        
        let r = CGFloat(data[pixelIndex]) / CGFloat(255.0)
        let g = CGFloat(data[pixelIndex+1]) / CGFloat(255.0)
        let b = CGFloat(data[pixelIndex+2]) / CGFloat(255.0)
        let a = CGFloat(data[pixelIndex+3]) / CGFloat(255.0)
        
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
}
