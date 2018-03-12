//
//  FloatingPointType.swift
//  Sluthware
//
//  Created by Pat Sluth on 2017-08-08.
//  Copyright © 2017 patsluth. All rights reserved.
//

import Foundation
import CoreGraphics





public protocol FloatingPointType: BinaryFloatingPoint
{
	init(_ value: Float)
	init(_ value: Double)
	init(_ value: CGFloat)
	
	func to<T: FloatingPointType>() -> T
}

extension Float:	FloatingPointType { public func to<T: FloatingPointType>() -> T { return T(self) } }
extension Double:	FloatingPointType { public func to<T: FloatingPointType>() -> T { return T(self) } }
extension CGFloat:	FloatingPointType { public func to<T: FloatingPointType>() -> T { return T(self) } }





public extension Float
{
	public init<T: FloatingPointType>(_ value: T)
	{
		let _value: Float = value.to()
		self.init(_value)
	}
}

public extension Double
{
	public init<T: FloatingPointType>(_ value: T)
	{
		let _value: Double = value.to()
		self.init(_value)
	}
}

public extension CGFloat
{
	public init<T: FloatingPointType>(_ value: T)
	{
		let _value: CGFloat = value.to()
		self.init(_value)
	}
}




