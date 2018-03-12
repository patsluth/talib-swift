//
//  UIColor+ContrastingColor.swift
//  Sluthware
//
//  Created by Pat Sluth on 2017-11-02.
//  Copyright © 2017 patsluth. All rights reserved.
//

import Foundation





public extension UIColor
{
    /// Calculates a nice constrasting color (good for selecting a text color that looks good over a background color)
    /// Converted from https://stackoverflow.com/questions/28644311/how-to-get-the-rgb-code-int-from-an-uicolor-in-swift
    public func contrastingColor(fallback: UIColor) -> UIColor
    {
        var red: CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue: CGFloat = 0.0
        var alpha: CGFloat = 0.0
        
        if self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            // Counting the perceptive luminance - human eye favors green color...
            let a: CGFloat = 1.0 - (0.299 * red + 0.587 * green + 0.114 * blue)// / 255.0
            if a < 0.5 {    // bright colors - black font
                return UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
            } else {        // dark colors - white font
                return UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            }
        }
        
        return fallback
    }
}




