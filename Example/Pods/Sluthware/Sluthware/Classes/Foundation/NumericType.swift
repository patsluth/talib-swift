//
//  FloatingPointType.swift
//  Sluthware
//
//  Created by Pat Sluth on 2017-08-08.
//  Copyright © 2017 patsluth. All rights reserved.
//

import Foundation
import CoreGraphics





public protocol NumbericType: Numeric
{
	// FloatingPointType
	init(_ value: Float)
	init(_ value: Double)
	init(_ value: CGFloat)
	// IntegerType
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
	
	func to<T: NumbericType>() -> T
}

public extension NumbericType
{
	static var zero: Self {
		return (0.0).to()
	}
}

// FloatingPointType
extension Float:	NumbericType { public func to<T: NumbericType>() -> T { return T(self) } }
extension Double:	NumbericType { public func to<T: NumbericType>() -> T { return T(self) } }
extension CGFloat:	NumbericType { public func to<T: NumbericType>() -> T { return T(self) } }
// IntegerType
extension Int:		NumbericType { public func to<T: NumbericType>() -> T { return T(self) } }
extension UInt:		NumbericType { public func to<T: NumbericType>() -> T { return T(self) } }
extension Int8:		NumbericType { public func to<T: NumbericType>() -> T { return T(self) } }
extension UInt8:	NumbericType { public func to<T: NumbericType>() -> T { return T(self) } }
extension Int16:	NumbericType { public func to<T: NumbericType>() -> T { return T(self) } }
extension UInt16:	NumbericType { public func to<T: NumbericType>() -> T { return T(self) } }
extension Int32:	NumbericType { public func to<T: NumbericType>() -> T { return T(self) } }
extension UInt32:	NumbericType { public func to<T: NumbericType>() -> T { return T(self) } }
extension Int64:	NumbericType { public func to<T: NumbericType>() -> T { return T(self) } }
extension UInt64:	NumbericType { public func to<T: NumbericType>() -> T { return T(self) } }




