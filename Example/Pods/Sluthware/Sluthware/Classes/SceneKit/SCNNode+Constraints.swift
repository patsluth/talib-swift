//
//  SCNNode+Constraints.swift
//  Sluthware
//
//  Created by Pat Sluth on 2017-10-18.
//  Copyright © 2017 Apple. All rights reserved.
//

import Foundation
import SceneKit





public extension SCNNode
{
    func addConstraint(_ constraint: SCNConstraint)
    {
        if self.constraints == nil {
            self.constraints = [constraint]
        } else {
            self.constraints!.append(constraint)
        }
    }
    
    func removeConstraint(_ constraint: SCNConstraint)
    {
        if let index = self.constraints?.index(of: constraint) {
            self.constraints?.remove(at: index)
        }
        if self.constraints?.count == 0 {
            self.constraints = nil
        }
    }
    
    func removeAllConstraints()
    {
        self.constraints?.removeAll()
    }
}




