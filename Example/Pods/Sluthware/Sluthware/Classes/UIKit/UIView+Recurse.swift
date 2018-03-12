//
//  UIView.swift
//  PathwaystoFaery
//
//  Created by Pat Sluth on 2017-12-19.
//  Copyright © 2017 Pat Sluth. All rights reserved.
//

import Foundation





public typealias UIViewBlock = (_ view: UIView, _ stop: inout Bool) -> Void





public extension UIView
{
    func recurseSubviews(_ viewBlock: UIViewBlock)
    {
        var stop = false
        
        viewBlock(self, &stop)
        
        guard !stop else { return }
        
        for subview in self.subviews {
            subview.recurseSubviews(viewBlock)
        }
    }
    
    func recurseSuperviews(_ viewBlock: UIViewBlock)
    {
        var stop = false
        
        viewBlock(self, &stop)
        
        guard !stop else { return }
        guard let superview = self.superview else { return }
        
        superview.recurseSubviews(viewBlock)
    }
}




