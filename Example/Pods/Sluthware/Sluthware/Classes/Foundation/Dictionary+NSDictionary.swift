//
//  Dictionary+NSDictionary.swift
//  Sluthware
//
//  Created by Pat Sluth on 2017-09-30.
//  Copyright © 2017 patsluth. All rights reserved.
//

import Foundation





public extension Dictionary
{
	init?(contentsOfFile path: String)
	{
		if let dictionary = NSDictionary(contentsOfFile: path) as? [Key: Value] {
			self = dictionary
		} else {
			return nil
		}
	}
	
	init?(contentsOf url: URL)
	{
		if let dictionary = NSDictionary(contentsOf: url) as? [Key: Value] {
			self = dictionary
		} else {
			return nil
		}
	}
	
	
	
	
	
	func write(toFile path: String, atomically useAuxiliaryFile: Bool) -> Bool
	{
		return (self as NSDictionary).write(toFile: path, atomically: useAuxiliaryFile)
	}
	
	func write(to url: URL, atomically: Bool) -> Bool
	{
		return (self as NSDictionary).write(to: url, atomically: atomically)
	}
	
	@available(iOS 11.0, OSX 10.13, *)
	func write(to url: URL) throws
	{
		try (self as NSDictionary).write(to: url)
	}
}




