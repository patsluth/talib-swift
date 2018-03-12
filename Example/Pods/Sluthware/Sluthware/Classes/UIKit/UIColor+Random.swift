//
//  UIColor+Random.swift
//  Sluthware
//
//  Created by Pat Sluth on 2017-07-25.
//  Copyright © 2017 patsluth. All rights reserved.
//

import Foundation





public extension UIColor
{
    public static var random: UIColor {
        let hue = CGFloat(Double(arc4random() % 256) / 256.0)
        let saturation = CGFloat(Double(arc4random() % 128) / 256.0) + 0.5
        let brightness = CGFloat(Double(arc4random() % 128) / 256.0) + 0.5
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1.0)
    }
}




