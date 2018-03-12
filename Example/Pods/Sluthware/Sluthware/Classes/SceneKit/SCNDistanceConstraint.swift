//
//  SCNDistanceConstraint.swift
//  Sluthware
//
//  Created by Pat Sluth on 2017-10-18.
//  Copyright © 2017 Apple. All rights reserved.
//

import Foundation
import SceneKit





@available(iOS 11.0, OSX 10.13, *)
public extension SCNDistanceConstraint
{
    public convenience init(target: SCNNode?, minimumDistance: CGFloat, maximumDistance: CGFloat)
    {
        self.init(target: target)
        
        self.minimumDistance = minimumDistance
        self.maximumDistance = maximumDistance
    }
}




