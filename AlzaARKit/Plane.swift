//
//  Plane.swift
//  AlzaARKit
//
//  Created by Andrey Mosin on 31/07/2017.
//  Copyright © 2017 Alza. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class Plane: SCNNode {
    
    let anchor: ARPlaneAnchor
    let planeGeometry: SCNPlane
    
    init(anchor: ARPlaneAnchor) {
        self.anchor = anchor
        self.planeGeometry = SCNPlane(width: CGFloat(anchor.extent.x), height: CGFloat(anchor.extent.z))
        super.init()
        
        let planeNode = SCNNode(geometry: planeGeometry)
        planeNode.position = SCNVector3Make(anchor.center.x, 0, anchor.center.z)
        planeNode.rotateCool()
        
        planeNode.physicsBody = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(geometry: planeGeometry, options: nil))
        addChildNode(planeNode)
        
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.white.withAlphaComponent(0.4)
        planeGeometry.materials = [material]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(with anchor: ARPlaneAnchor) {
        self.planeGeometry.width = CGFloat(anchor.extent.x)
        self.planeGeometry.height = CGFloat(anchor.extent.z)
        
        self.position = SCNVector3Make(anchor.center.x, 0, anchor.center.z)
        setTextureScale()
    }
    
    func setTextureScale() {
        planeGeometry.materials.first?.diffuse.contentsTransform = SCNMatrix4MakeScale(Float(planeGeometry.width), Float(planeGeometry.height), 1)
        planeGeometry.materials.first?.diffuse.wrapS = .repeat
        planeGeometry.materials.first?.diffuse.wrapT = .repeat
    }
    
}

extension SCNNode {
    func rotateCool() {
        self.transform = SCNMatrix4MakeRotation(-Float.pi / 2, 1, 0, 0)
    }
}
