//
//  JSONDecoder.swift
//  Sluthware
//
//  Created by Pat Sluth on 2017-10-08.
//  Copyright © 2017 patsluth. All rights reserved.
//

import Foundation





public extension JSONDecoder
{
	static func decode<T>(_ type: T.Type, data: Data) throws -> T where T : Decodable
	{
		let decoder = JSONDecoder()
		return try decoder.decode(type, from: data)
	}
	
	static func decode<T>(_ type: T.Type, jsonDictionary: [AnyHashable: Any]) throws -> T where T : Decodable
	{
		let data = try JSONSerialization.data(withJSONObject: jsonDictionary)
		let decoder = JSONDecoder()
		return try decoder.decode(type, from: data)
	}
}




