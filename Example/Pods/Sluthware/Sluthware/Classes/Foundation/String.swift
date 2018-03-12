//
//  String.swift
//  Sluthware
//
//  Created by Pat Sluth on 2017-12-19.
//

import Foundation





public extension String
{
	var fileName: String {
		var fileName = (self as NSString)
		fileName = (fileName.deletingPathExtension as NSString)
		fileName = (fileName.lastPathComponent as NSString)
		return fileName.removingPercentEncoding ?? (fileName as String)
	}
	
	var fileNameWithExtension: String {
		var fileName = (self as NSString)
		fileName = (fileName.lastPathComponent as NSString)
		return fileName.removingPercentEncoding ?? (fileName as String)
	}
	
	var camelCaseToWords: String {
		return unicodeScalars.reduce("") {
			if CharacterSet.uppercaseLetters.contains($1) == true {
				return ($0 + " " + String($1))
			} else {
				return $0 + String($1)
			}
		}
	}
}




