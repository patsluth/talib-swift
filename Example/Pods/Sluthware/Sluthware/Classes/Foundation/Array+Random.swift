//
//  Array+Random.swift
//  Sluthware
//
//  Created by Pat Sluth on 2017-09-30.
//  Copyright © 2017 patsluth. All rights reserved.
//

import Foundation





public extension Array
{
	var random: Element? {
		guard !self.isEmpty else { return nil }
		return self[Int.random((0..<self.count))]
	}
}




