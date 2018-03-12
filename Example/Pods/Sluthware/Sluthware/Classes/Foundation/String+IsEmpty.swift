//
//  String+IsEmpty.swift
//  Sluthware
//
//  Created by Pat Sluth on 2017-12-19.
//

import Foundation





public extension String
{
    public static func isEmpty(_ string: String?) -> Bool
    {
        guard let string = string else { return true }
        
        return string.isEmpty
    }
}




