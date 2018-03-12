//
//  URL.swift
//  Sluthware
//
//  Created by Pat Sluth on 2017-12-08.
//  Copyright © 2017 Pat Sluth. All rights reserved.
//

import Foundation





public extension URL
{
	func isFileTypeOf(_ pathExtension: String) -> Bool
	{
		guard self.isFileURL else { return false }
		return self.pathExtension.localizedCaseInsensitiveCompare(pathExtension) == ComparisonResult.orderedSame
	}
    
    var fileName: String {
		let fileName = self.deletingPathExtension().lastPathComponent
		return fileName.removingPercentEncoding ?? fileName
    }
	
	var fileNameWithExtension: String {
		let fileName = self.lastPathComponent
		return fileName.removingPercentEncoding ?? fileName
	}
}




