//
//  CLLocationCoordinate2D.swift
//  Sluthware
//
//  Created by Pat Sluth on 2018-01-30.
//  Copyright © 2018 Pat Sluth. All rights reserved.
//

import Foundation
import CoreLocation





public extension CLLocationCoordinate2D
{
	func bearing(toCoordinate: CLLocationCoordinate2D) -> Double
	{
		let x = sin(toCoordinate.longitude.toRad - self.longitude.toRad) * cos(toCoordinate.latitude.toRad)
		let y = cos(self.latitude.toRad) * sin(toCoordinate.latitude.toRad) - sin(self.latitude.toRad) * cos(toCoordinate.latitude.toRad) * cos(toCoordinate.longitude.toRad - self.longitude.toRad)
		return atan2(x, y)
	}
}




