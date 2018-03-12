//
//  String+Trim.swift
//  Sluthware
//
//  Created by Pat Sluth on 2017-12-19.
//

import Foundation





public extension String
{
	public struct WhitespaceTrimOptions: OptionSet
	{
		public let rawValue: Int
		
		public static let Leading =			WhitespaceTrimOptions(rawValue: 0)
		public static let Trailing =		WhitespaceTrimOptions(rawValue: 1)
		public static let Multiple =		WhitespaceTrimOptions(rawValue: 2)
		public static let All =				WhitespaceTrimOptions(rawValue: 0 | 1 | 2)
		
		public init(rawValue: Int)
		{
			self.rawValue = rawValue
		}
	}
	
	
	
	
	
	public func trim(_ options: String.WhitespaceTrimOptions) -> String
	{
		var trimmedString = self
		
		if options.contains(String.WhitespaceTrimOptions.Leading) {
			while trimmedString.prefix(1) == " " {
				let index = trimmedString.index(trimmedString.startIndex, offsetBy: 1)
				trimmedString = String(trimmedString[index..<trimmedString.endIndex])
			}
		}
		
		if options.contains(String.WhitespaceTrimOptions.Trailing) {
			while trimmedString.suffix(1) == " " {
				let index = trimmedString.index(trimmedString.endIndex, offsetBy: -1)
				trimmedString = String(trimmedString[..<index])
			}
		}
		
		if options.contains(String.WhitespaceTrimOptions.Multiple) {
			while trimmedString.contains("  ") {
				trimmedString = trimmedString.replacingOccurrences(of: "  ", with: " ")
			}
		}
		
		return trimmedString
	}
}




