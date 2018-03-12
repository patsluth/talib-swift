//
//  SCNNode.swift
//  Sluthware
//
//  Created by Pat Sluth on 2017-10-18.
//  Copyright © 2017 Apple. All rights reserved.
//

import Foundation
import SceneKit





public extension SCNNode
{
    var zForward: SCNVector3 {
        return SCNVector3(self.worldTransform.m31, self.worldTransform.m32, self.worldTransform.m33)
    }
	
	@available(iOS 8.0, OSX 10.10, *)
    func centrePivot(centreX: Bool = true, centreY: Bool = true, centreZ: Bool = true) -> SCNMatrix4
    {
        let min = self.boundingBox.min
        let max = self.boundingBox.max
        
        return SCNMatrix4MakeTranslation(
            centreX ? (min.x + (max.x - min.x) / 2.0) : 0.0,
            centreY ? (min.y + (max.y - min.y) / 2.0) : 0.0,
            centreZ ? (min.z + (max.z - min.z) / 2.0) : 0.0
        )
    }
    
    func transform(from vectorA: SCNVector3, to vectorB: SCNVector3) -> SCNMatrix4
    {
        let distance = SCNVector3.distance(from: vectorA, to: vectorB)
		guard distance != 0.0 else { return self.transform }
        
        // original vector of cylinder above 0,0,0
        let oldVector = SCNVector3(0.0, distance / 2.0, 0.0)
        // target vector, in new coordination
        let newVector = SCNVector3((vectorB.x - vectorA.x) / 2.0,
                                   (vectorB.y - vectorA.y) / 2.0,
                                   (vectorB.z - vectorA.z) / 2.0)
        
        let axis = SCNVector3.midPoint(from: oldVector, to: newVector)
        let axisNormalized = axis.normalized
        
        let q0 = SCNFloat(0.0) //cos(angel/2), angle is always 180 or M_PI
        let q1 = SCNFloat(axisNormalized.x) // x' * sin(angle/2)
        let q2 = SCNFloat(axisNormalized.y) // y' * sin(angle/2)
        let q3 = SCNFloat(axisNormalized.z) // z' * sin(angle/2)
        
        return SCNMatrix4(m11: SCNFloat(q0 * q0 + q1 * q1 - q2 * q2 - q3 * q3),
                          m12: SCNFloat(2.0 * q1 * q2 + 2.0 * q0 * q3),
                          m13: SCNFloat(2.0 * q1 * q3 - 2.0 * q0 * q2),
                          m14: SCNFloat(0.0),
                          m21: SCNFloat(2.0 * q1 * q2 - 2.0 * q0 * q3),
                          m22: SCNFloat(q0 * q0 - q1 * q1 + q2 * q2 - q3 * q3),
                          m23: SCNFloat(2.0 * q2 * q3 + 2.0 * q0 * q1),
                          m24: SCNFloat(0.0),
                          m31: SCNFloat(2.0 * q1 * q3 + 2.0 * q0 * q2),
                          m32: SCNFloat(2.0 * q2 * q3 - 2.0 * q0 * q1),
                          m33: SCNFloat(q0 * q0 - q1 * q1 - q2 * q2 + q3 * q3),
                          m34: SCNFloat(0.0),
                          m41: SCNFloat(vectorA.x + vectorB.x) / 2.0,
                          m42: SCNFloat(vectorA.y + vectorB.y) / 2.0,
                          m43: SCNFloat(vectorA.z + vectorB.z) / 2.0,
                          m44: SCNFloat(1.0))
    }
}




