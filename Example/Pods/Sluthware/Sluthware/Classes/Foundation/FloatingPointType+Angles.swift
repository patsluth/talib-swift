//
//  FloatingPointType+Angles.swift
//  Sluthware
//
//  Created by Pat Sluth on 2017-08-08.
//  Copyright © 2017 patsluth. All rights reserved.
//

import Foundation





public extension FloatingPointType
{
	public static var pi_2: Self {
		return Self.pi / Self(2.0)
	}
	
	public static var pi_4: Self {
		return Self.pi / Self(4.0)
	}
	
	public static var pi_8: Self {
		return Self.pi / Self(8.0)
	}
	
	
	
	public var toRad: Self {
		return Self.degToRad(deg: self)
	}
	
	public static func degToRad(deg: Self) -> Self
	{
		return deg * Self.pi / Self(180.0)
	}
	
	public var toDeg: Self {
		return Self.radToDeg(rad: self)
	}
	
	public static func radToDeg(rad: Self) -> Self
	{
		return rad * Self(180.0) / Self.pi
	}
}




