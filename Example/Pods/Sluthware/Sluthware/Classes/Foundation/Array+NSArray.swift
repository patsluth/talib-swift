//
//  Array+NSArray.swift
//  Sluthware
//
//  Created by Pat Sluth on 2017-09-30.
//  Copyright © 2017 patsluth. All rights reserved.
//

import Foundation





public extension Array
{
	init?(contentsOfFile path: String)
	{
		if let array = NSArray(contentsOfFile: path) as? [Element] {
			self = array
		} else {
			return nil
		}
	}
	
	init?(contentsOf url: URL)
	{
		if let array = NSArray(contentsOf: url) as? [Element] {
			self = array
		} else {
			return nil
		}
	}
	
	
	
	
	
	func write(toFile path: String, atomically useAuxiliaryFile: Bool) -> Bool
	{
		return (self as NSArray).write(toFile: path, atomically: useAuxiliaryFile)
	}
	
	func write(to url: URL, atomically: Bool) -> Bool
	{
		return (self as NSArray).write(to: url, atomically: atomically)
	}
	
	@available(iOS 11.0, OSX 10.13, *)
	func write(to url: URL) throws
	{
		try (self as NSArray).write(to: url)
	}
	
	
	
	
	
	func sortedArray(comparator cmptr: (Any, Any) -> ComparisonResult) -> [Element]
	{
		return (self as NSArray).sortedArray(comparator: cmptr) as! [Element]
	}
	
	@available(OSX 10.6, *)
	func sortedArray(options opts: NSSortOptions = [], usingComparator cmptr: (Any, Any) -> ComparisonResult) -> [Element]
	{
		return (self as NSArray).sortedArray(options: opts, usingComparator: cmptr) as! [Element]
	}
	
	@available(OSX 10.6, *)
	func index(of obj: Any,
			   inSortedRange r: NSRange,
			   options opts: NSBinarySearchingOptions = [],
			   usingComparator cmp: (Any, Any) -> ComparisonResult) -> Int
	{
		return (self as NSArray).index(of: obj,
									   inSortedRange: r,
									   options: opts,
									   usingComparator: cmp)
	}
}




