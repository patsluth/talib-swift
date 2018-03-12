//
//  Codable.swift
//  Sluthware
//
//  Created by Pat Sluth on 2017-10-08.
//  Copyright © 2017 patsluth. All rights reserved.
//

import Foundation
import CoreGraphics





public extension CGSize
{
	public static func +(lhs: CGSize, rhs: CGSize) -> CGSize
	{
		return CGSize(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
	}
	
	public static func +=(lhs: inout CGSize, rhs: CGSize)
	{
		lhs = lhs + rhs
	}
	
	public static func +(lhs: CGSize, rhs: CGFloat) -> CGSize
	{
		return CGSize(width: lhs.width + rhs, height: lhs.height + rhs)
	}
	
	public static func +=(lhs: inout CGSize, rhs: CGFloat)
	{
		lhs = lhs + rhs
	}
	
	
	
	public static func -(lhs: CGSize, rhs: CGSize) -> CGSize
	{
		return CGSize(width: lhs.width - rhs.width, height: lhs.height - rhs.height)
	}
	
	public static func -=(lhs: inout CGSize, rhs: CGSize)
	{
		lhs = lhs - rhs
	}
	
	public static func -(lhs: CGSize, rhs: CGFloat) -> CGSize
	{
		return CGSize(width: lhs.width - rhs, height: lhs.height - rhs)
	}
	
	public static func -=(lhs: inout CGSize, rhs: CGFloat)
	{
		lhs = lhs - rhs
	}
	
	
	
	public static func *(lhs: CGSize, rhs: CGSize) -> CGSize
	{
		return CGSize(width: lhs.width * rhs.width, height: lhs.height * rhs.height)
	}
	
	public static func *=(lhs: inout CGSize, rhs: CGSize)
	{
		lhs = lhs * rhs
	}
	
	public static func *(lhs: CGSize, rhs: CGFloat) -> CGSize
	{
		return CGSize(width: lhs.width * rhs, height: lhs.height * rhs)
	}
	
	public static func *=(lhs: inout CGSize, rhs: CGFloat)
	{
		lhs = lhs * rhs
	}
	
	
	
	public static func /(lhs: CGSize, rhs: CGSize) -> CGSize
	{
		return CGSize(width: lhs.width / rhs.width, height: lhs.height / rhs.height)
	}
	
	public static func /=(lhs: inout CGSize, rhs: CGSize)
	{
		lhs = lhs / rhs
	}
	
	public static func /(lhs: CGSize, rhs: CGFloat) -> CGSize
	{
		return CGSize(width: lhs.width / rhs, height: lhs.height / rhs)
	}
	
	public static func /=(lhs: inout CGSize, rhs: CGFloat)
	{
		lhs = lhs / rhs
	}
}




