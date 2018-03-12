//
//  Codable.swift
//  Sluthware
//
//  Created by Pat Sluth on 2017-10-08.
//  Copyright © 2017 patsluth. All rights reserved.
//

import Foundation





public extension Decodable
{
    func decode(data: Data) throws -> Self
    {
        let decoder = JSONDecoder()
        return try decoder.decode(Self.self, from: data)
    }
    
    static func decode(data: Data) throws -> Self
    {
        let decoder = JSONDecoder()
        return try decoder.decode(Self.self, from: data)
    }
    
	static func decode<K, V>(jsonDictionary: [K: V]) throws -> Self
    {
        let data = try JSONSerialization.data(withJSONObject: jsonDictionary)
        return try self.decode(data: data)
    }
}




