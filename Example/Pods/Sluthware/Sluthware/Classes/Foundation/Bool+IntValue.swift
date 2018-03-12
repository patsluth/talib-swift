//
//  Bool+IntValue.swift
//  Sluthware
//
//  Created by Pat Sluth on 2017-09-30.
//  Copyright © 2017 patsluth. All rights reserved.
//

import Foundation





public extension Bool
{
	public func intValue<T: IntegerType>(_ type: T.Type) -> T
	{
		return (self == false) ? T(0) : T(1)
	}
}




