//
//  Codable.swift
//  Sluthware
//
//  Created by Pat Sluth on 2017-10-08.
//  Copyright © 2017 patsluth. All rights reserved.
//

import Foundation





public extension Encodable
{
    func encode() throws -> Data
    {
        let encoder = JSONEncoder()
        encoder.outputFormatting = JSONEncoder.OutputFormatting.prettyPrinted
        return try encoder.encode(self)
    }
	
	func encodeDictionary<K, V>(_ keyType: K.Type, _ valueType: V.Type) throws -> [K: V]
	{
		let encoder = JSONEncoder()
		encoder.outputFormatting = JSONEncoder.OutputFormatting.prettyPrinted
		let data = try encoder.encode(self)
		return try JSONSerialization.jsonObject(with: data) as! [K: V]
	}
}




