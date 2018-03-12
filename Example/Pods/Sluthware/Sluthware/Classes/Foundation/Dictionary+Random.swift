//
//  Array+Random.swift
//  Sluthware
//
//  Created by Pat Sluth on 2017-09-30.
//  Copyright © 2017 patsluth. All rights reserved.
//

import Foundation





public extension Dictionary
{
	var random: Element? {
		guard let randomKey = Array(self.keys).random else { return nil }
		guard let randomElement = self[randomKey] else { return nil }
		return Element(key: randomKey, value: randomElement)
	}
}




