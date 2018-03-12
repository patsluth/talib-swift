//
//  String+Comparator.swift
//  Sluthware
//
//  Created by Pat Sluth on 2017-12-19.
//

import Foundation





public extension String
{
	static func alphabeticalComparator() -> Comparator
	{
		let comparator = { (lhs: Any, rhs: Any) -> ComparisonResult in
			guard let lhsString = lhs as? String, let rhsString = rhs as? String else { return ComparisonResult.orderedSame }
			
			return lhsString.localizedCaseInsensitiveCompare(rhsString)
		}
		
		return comparator
	}
	
	static func fileNameAlphabeticalComparator() -> Comparator
	{
		let comparator = { (lhs: Any, rhs: Any) -> ComparisonResult in
			guard let lhsString = lhs as? String, let rhsString = rhs as? String else { return ComparisonResult.orderedSame }
			
			return lhsString.fileName.localizedCaseInsensitiveCompare(rhsString.fileName)
		}
		
		return comparator
	}
}




