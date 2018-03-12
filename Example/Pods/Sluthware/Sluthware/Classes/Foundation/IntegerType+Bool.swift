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
	public var boolValue: Bool {
		get
		{
			return (self == 0) ? false : true
		}
	}
}




