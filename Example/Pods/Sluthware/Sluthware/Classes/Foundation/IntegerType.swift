//
//  IntegerType.swift
//  Sluthware
//
//  Created by Pat Sluth on 2017-08-08.
//  Copyright © 2017 patsluth. All rights reserved.
//

import Foundation





public protocol IntegerType: BinaryInteger
{
	init(_ value: Int)
	init(_ value: UInt)
	init(_ value: Int8)
	init(_ value: UInt8)
	init(_ value: Int16)
	init(_ value: UInt16)
	init(_ value: Int32)
	init(_ value: UInt32)
	init(_ value: Int64)
	init(_ value: UInt64)
	
	func to<T: IntegerType>() -> T
}

extension Int:		IntegerType { public func to<T: IntegerType>() -> T { return T(self) } }
extension UInt:		IntegerType { public func to<T: IntegerType>() -> T { return T(self) } }
extension Int8:		IntegerType { public func to<T: IntegerType>() -> T { return T(self) } }
extension UInt8:	IntegerType { public func to<T: IntegerType>() -> T { return T(self) } }
extension Int16:	IntegerType { public func to<T: IntegerType>() -> T { return T(self) } }
extension UInt16:	IntegerType { public func to<T: IntegerType>() -> T { return T(self) } }
extension Int32:	IntegerType { public func to<T: IntegerType>() -> T { return T(self) } }
extension UInt32:	IntegerType { public func to<T: IntegerType>() -> T { return T(self) } }
extension Int64:	IntegerType { public func to<T: IntegerType>() -> T { return T(self) } }
extension UInt64:	IntegerType { public func to<T: IntegerType>() -> T { return T(self) } }




