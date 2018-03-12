//
//  TA_Beta.swift
//  ta-lib-swift
//
//  Created by Pat Sluth on 2017-09-18.
//  Copyright © 2017 patsluth. All rights reserved.
//

import Foundation





public class TA_Beta
{
    public static let optInTimePeriodDefault = 5
    
    public class func calculate(startIndex: Int,
                                endIndex: Int,
                                inDouble0: [Double],
                                inDouble1: [Double],
                                optInTimePeriod: Int,
                                outElementStartIndex: inout Int,
                                outElementCount: inout Int,
                                outDouble: inout [Double]) -> TA_ReturnCode
    {
        var startIndex = startIndex
        var optInTimePeriod = optInTimePeriod
        
        outElementStartIndex = 0
        outElementCount = 0
        
        if startIndex < 0 {
            return TA_ReturnCode.OutOfRangeStartIndex
        }
        if endIndex < 0 || endIndex < startIndex {
            return TA_ReturnCode.OutOfRangeStartIndex
        }
        if optInTimePeriod == Int.min {
            optInTimePeriod = self.optInTimePeriodDefault
        }else if optInTimePeriod < 1 || optInTimePeriod > 100000 {
            return TA_ReturnCode.BadParam
        }
        let nbInitialElementNeeded = optInTimePeriod
        if startIndex < nbInitialElementNeeded {
            startIndex = nbInitialElementNeeded
        }
        if startIndex > endIndex {
            outElementStartIndex = 0
            outElementCount = 0
            return TA_ReturnCode.Success
        }
        
        let allocationSize = self.allocationSize(startIndex: startIndex,
                                                 endIndex: endIndex,
                                                 optInTimePeriod: optInTimePeriod)
        outDouble = [Double](repeating: Double.nan, count: allocationSize)
        
        var x: Double
        var y: Double
        var S_xx = 0.0
        var S_xy = 0.0
        var S_x = 0.0
        var S_y = 0.0
        var last_price_x = 0.0
        var last_price_y = 0.0
        var trailing_last_price_x = 0.0
        var trailing_last_price_y = 0.0
        var tmp_real = 0.0
        var trailingIdx = startIndex - nbInitialElementNeeded
        trailing_last_price_x = inDouble0[trailingIdx]
        last_price_x = trailing_last_price_x
        trailing_last_price_y = inDouble1[trailingIdx]
        last_price_y = trailing_last_price_y
        trailingIdx += 1
        var i = trailingIdx
        while true {
            if i >= startIndex {
                break
            }
            tmp_real = inDouble0[i]
            if -1E-08 >= last_price_x || last_price_x >= 1E-08 {
                x = (tmp_real - last_price_x) / last_price_x
            } else {
                x = 0.0
            }
            last_price_x = tmp_real
            tmp_real = inDouble1[i]
            i += 1
            if -1E-08 >= last_price_y || last_price_y >= 1E-08 {
                y = (tmp_real - last_price_y) / last_price_y
            } else {
                y = 0.0
            }
            last_price_y = tmp_real
            S_xx += (x * x)
            S_xy += (x * y)
            S_x += x
            S_y += y
        }
        var outIdx = 0
        repeat {
            tmp_real = inDouble0[i]
            if -1E-08 >= last_price_x || last_price_x >= 1E-08 {
                x = (tmp_real - last_price_x) / last_price_x
            } else {
                x = 0.0
            }
            last_price_x = tmp_real
            tmp_real = inDouble1[i]
            i += 1
            if -1E-08 >= last_price_y || last_price_y >= 1E-08 {
                y = (tmp_real - last_price_y) / last_price_y
            } else {
                y = 0.0
            }
            last_price_y = tmp_real
            S_xx += (x * x)
            S_xy += (x * y)
            S_x += x
            S_y += y
            tmp_real = inDouble0[trailingIdx]
            if -1E-08 >= trailing_last_price_x || trailing_last_price_x >= 1E-08 {
                x = (tmp_real - trailing_last_price_x) / trailing_last_price_x
            } else {
                x = 0.0
            }
            trailing_last_price_x = tmp_real
            tmp_real = inDouble1[trailingIdx]
            trailingIdx += 1
            if -1E-08 >= trailing_last_price_y || trailing_last_price_y >= 1E-08 {
                y = (tmp_real - trailing_last_price_y) / trailing_last_price_y
            } else {
                y = 0.0
            }
            trailing_last_price_y = tmp_real
            tmp_real = (Double(optInTimePeriod) * S_xy) - (S_x * S_y)
            if -1E-08 >= tmp_real || tmp_real >= 1E-08 {
                outDouble[outIdx] = ((Double(optInTimePeriod) * S_xy) - (S_x * S_y)) / tmp_real
            } else {
                outDouble[outIdx] = 0.0
            }
            outIdx += 1
            S_xx -= (x * x)
            S_xy -= (x * y)
            S_x -= x
            S_y -= y
        } while i <= endIndex

        outElementStartIndex = startIndex
        outElementCount = outIdx
        
        return TA_ReturnCode.Success
    }
    
    public class func lookback(optInTimePeriod: Int) -> Int
    {
        var optInTimePeriod = optInTimePeriod
        
        if optInTimePeriod == Int.min {
            optInTimePeriod = self.optInTimePeriodDefault
        } else if optInTimePeriod < 1 || optInTimePeriod > 100000 {
            return -1
        }
        
        return optInTimePeriod
    }
    
    public class func allocationSize(startIndex: Int,
                                     endIndex: Int,
                                     optInTimePeriod: Int) -> Int
    {
        let lookback = self.lookback(optInTimePeriod: optInTimePeriod)
        let temp = max(lookback, startIndex)
        var allocationSize = 0
        if temp > endIndex {
        } else {
            allocationSize = endIndex - temp + 1
        }
        
        return allocationSize
    }
}




