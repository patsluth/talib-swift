//
//  NSObject+StringForClass.swift
//  Sluthware
//
//  Created by Pat Sluth on 2017-12-03.
//  Copyright © 2017 Pat Sluth. All rights reserved.
//

import Foundation





public extension NSObject
{
    public var stringForClass: String {
		return String(describing: self.classForCoder)
	}
	
	public static var stringForClass: String {
		return String(describing: self)
	}
}




