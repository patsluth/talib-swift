//
//  IntegerType+Random.swift
//  Sluthware
//
//  Created by Pat Sluth on 2017-08-08.
//  Copyright © 2017 patsluth. All rights reserved.
//

import Foundation





public extension IntegerType
{
	public static func random(_ range: Range<Self>) -> Self
	{
		return range.lowerBound + Self(arc4random_uniform(UInt32(range.upperBound - range.lowerBound)))
	}
}




