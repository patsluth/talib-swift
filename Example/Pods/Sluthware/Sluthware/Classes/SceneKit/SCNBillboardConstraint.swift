//
//  SCNBillboardConstraint.swift
//  Sluthware
//
//  Created by Pat Sluth on 2017-10-18.
//  Copyright © 2017 Apple. All rights reserved.
//

import Foundation
import SceneKit





@available(iOS 9.0, OSX 10.11, *)
public extension SCNBillboardConstraint
{
    public convenience init(freeAxes: SCNBillboardAxis)
    {
        self.init()
        
        self.freeAxes = freeAxes
    }
}




