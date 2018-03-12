//
//  Collection+NumericOperations.swift
//  Sluthware
//
//  Created by Pat Sluth on 2017-11-28.
//  Copyright © 2017 patsluth. All rights reserved.
//

import Foundation



//protocol Numeric {
//
//	/// + operator must be defined for this type
//	static func +(lhs: Self, rhs: Self) -> Self
//}







public extension Collection where Element: NumbericType, IndexDistance == Int
{
	var sum: Element {
		return self.reduce(Element.zero, +)
	}
	
	var average: Element {
		let s: Double = self.sum.to()
		let c: Double = self.count.to()
		
		return (s / c).to()
	}
	
//	var average: Element {
////		let summ: Double = self.sum
////
////		let average = summ / Double(self.count)
////		return (Double(self.sum) / Double(self.count)
//	}
	
	
	
//	var average: Element {
//		guard !self.isEmpty else { return Element(0.0) }
//
//		let sum = reduce(Float(0)) { current, next -> Float in
//			return current + next.to()
//		}
//
//		return (sum / Float(count)).to()
//	}
//	var average: Iterator.Element? {
//		guard !self.isEmpty else { return nil }
//
//		let sum = reduce(Element(0)) { current, next -> Element in
//			return current + next
//		}
//
//		return sum / Element(count)
//	}

//	func average<T>() -> T where T.Type == FloatingPointType{
//
//	}
}




