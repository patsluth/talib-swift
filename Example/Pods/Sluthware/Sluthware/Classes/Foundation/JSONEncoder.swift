//
//  JSONEncoder.swift
//  Sluthware
//
//  Created by Pat Sluth on 2017-10-08.
//  Copyright © 2017 patsluth. All rights reserved.
//

import Foundation





public extension JSONEncoder
{
	static func encodeData<T>(_ value: T) throws -> Data where T : Encodable
	{
		let encoder = JSONEncoder()
		encoder.outputFormatting = JSONEncoder.OutputFormatting.prettyPrinted
		return try encoder.encode(value)
	}
	
	static func encodeJSONDictionary<T>(_ value: T) throws -> [AnyHashable: Any] where T : Encodable
	{
		let encoder = JSONEncoder()
		encoder.outputFormatting = JSONEncoder.OutputFormatting.prettyPrinted
		let data = try encoder.encode(value)
		return try JSONSerialization.jsonObject(with: data) as! [AnyHashable: Any]
	}
}




