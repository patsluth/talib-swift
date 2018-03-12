//
//  Array.swift
//  Sluthware
//
//  Created by Pat Sluth on 2017-09-30.
//  Copyright © 2017 patsluth. All rights reserved.
//

import Foundation





public extension Array
{
	public subscript(safe index: Index) -> Element?
	{
		guard (0..<self.count).contains(index) else { return nil }
		return self[index]
	}
}




