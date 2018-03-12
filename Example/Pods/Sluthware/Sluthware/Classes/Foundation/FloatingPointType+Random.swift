//
//  FloatingPointType+Random.swift
//  Sluthware
//
//  Created by Pat Sluth on 2017-08-08.
//  Copyright © 2017 patsluth. All rights reserved.
//

import Foundation





public extension FloatingPointType
{
	/// Returns a random floating point number between 0.0 and 1.0.
	public static var randomSign: Self {
		return (arc4random_uniform(2) == 0) ? Self(1.0) : Self(-1.0)
	}
	
	/// Returns a random floating point number between 0.0 and 1.0.
	public static var random: Self {
		return Self(arc4random()) / Self(UInt32.max)
	}
	
	public static func random(_ range: Range<Self>) -> Self
	{
		return Self.random * (range.upperBound - range.lowerBound) + range.lowerBound
	}
}




