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
        
        let material = SCNMaterial()
        let image = UIImage(named: "logo")
        material.diffuse.contents = image
        planeGeometry.materials = [material]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
