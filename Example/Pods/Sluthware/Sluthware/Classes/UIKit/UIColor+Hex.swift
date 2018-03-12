//
//  UIColor+Hex.swift
//  Sluthware
//
//  Created by Pat Sluth on 2017-07-25.
//  Copyright © 2017 patsluth. All rights reserved.
//

import Foundation





public extension UIColor
{
    public convenience init(hex: String)
	{
		let scanner = Scanner(string: hex)
		scanner.scanLocation = 0
		
		var rgbValue: UInt64 = 0
		
		scanner.scanHexInt64(&rgbValue)
		
		if hex.utf8.count == 6 {
			
			let r = (rgbValue & 0xff0000) >> 16
			let g = (rgbValue & 0xff00) >> 8
			let b = rgbValue & 0xff
			
			self.init(red: CGFloat(r) / 0xff, green: CGFloat(g) / 0xff, blue: CGFloat(b) / 0xff, alpha: 1.0)
			
		} else if hex.utf8.count == 8 {
			
			let a = (rgbValue & 0xff000000) >> 24
			let r = (rgbValue & 0xff0000) >> 16
			let g = (rgbValue & 0xff00) >> 8
			let b = rgbValue & 0xff
			
			self.init(red: CGFloat(r) / 0xff, green: CGFloat(g) / 0xff, blue: CGFloat(b) / 0xff, alpha: CGFloat(a) / 0xff)
		
		} else {
			
			self.init()
			
		}
	}
}




