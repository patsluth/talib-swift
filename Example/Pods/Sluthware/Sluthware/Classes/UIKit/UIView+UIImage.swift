//
//  UIView+UIImage.swift
//  Sluthware
//
//  Created by Pat Sluth on 2017-09-30.
//  Copyright © 2017 patsluth. All rights reserved.
//

import Foundation





public extension UIView
{
	public func imageRepresentation() -> UIImage?
	{
		var image: UIImage? = nil
		
		UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, 0.0)
		if let context = UIGraphicsGetCurrentContext() {
			self.layer.render(in: context)
			image = UIGraphicsGetImageFromCurrentImageContext()
		}
		UIGraphicsEndImageContext()
		
		return image
	}
}




