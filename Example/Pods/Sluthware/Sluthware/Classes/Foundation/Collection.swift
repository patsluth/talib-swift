//
//  Collection.swift
//  Sluthware
//
//  Created by Pat Sluth on 2017-11-28.
//  Copyright © 2017 patsluth. All rights reserved.
//

import Foundation





public extension Collection
{
	public func stringForElements(separatedBy separator: String) -> String
	{
		var string = ""
		
		for element in self {
			string += String(describing: element) + separator
		}
		if string.suffix(separator.count) == separator {
			let index = string.index(string.endIndex, offsetBy: -separator.count)
			string = String(string[..<index])
		}
		
		return string
	}
}




