//
//  TA_LinearRegAngle.swift
//  ta-lib-swift
//
//  Created by Pat Sluth on 2017-09-18.
//  Copyright © 2017 patsluth. All rights reserved.
//

import Foundation





// LINEARREG_ANGLE - Linear Regression Angle
public class TA_LinearRegAngle
{
    public static let optInTimePeriodDefault = 14
    
    public class func calculate(startIndex: Int,
                                endIndex: Int,
                                inDouble: [Double],
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
        } else if optInTimePeriod < 2 || optInTimePeriod > 100000 {
            return TA_ReturnCode.BadParam
        }
        let lookbackTotal = self.lookback(optInTimePeriod: optInTimePeriod)
        if startIndex < lookbackTotal {
            startIndex = lookbackTotal
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
        
        var outIdx: Int = 0
        var today: Int = startIndex
        let sumX: Double = Double(optInTimePeriod * (optInTimePeriod - 1)) * 0.5
        let sumXSqr: Double = Double((optInTimePeriod * (optInTimePeriod - 1)) * ((optInTimePeriod * 2) - 1)) / 6.0
        let divisor: Double = (sumX * sumX) - (Double(optInTimePeriod) * sumXSqr)
        while true {
            if today > endIndex {
                outElementStartIndex = startIndex
                outElementCount = outIdx
                return TA_ReturnCode.Success
            }
            var sumXY: Double = 0.0
            var sumY: Double = 0.0
            var i: Int = optInTimePeriod
            while true {
                i -= 1
                if i == 0 {
                    break
                }
                let tempValue = inDouble[today - i]
                sumY += tempValue
                sumXY += Double(i) * tempValue
            }
            let m: Double = ((Double(optInTimePeriod) * sumXY) - (sumX * sumY)) / divisor
            outDouble[outIdx] = atan(m) * 57.295779513082323
            outIdx += 1
            today += 1
        }
    }
    
    public class func calculate(startIndex: Int,
                                endIndex: Int,
                                inCandle: [TA_Candle],
                                inCandleInputType: TA_CandleInputType,
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
        } else if optInTimePeriod < 2 || optInTimePeriod > 100000 {
            return TA_ReturnCode.BadParam
        }
        let lookbackTotal = self.lookback(optInTimePeriod: optInTimePeriod)
        if startIndex < lookbackTotal {
            startIndex = lookbackTotal
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
        
        var outIdx: Int = 0
        var today: Int = startIndex
        let sumX: Double = Double(optInTimePeriod * (optInTimePeriod - 1)) * 0.5
        let sumXSqr: Double = Double((optInTimePeriod * (optInTimePeriod - 1)) * ((optInTimePeriod * 2) - 1)) / 6.0
        let divisor: Double = (sumX * sumX) - (Double(optInTimePeriod) * sumXSqr)
        while true {
            if today > endIndex {
                outElementStartIndex = startIndex
                outElementCount = outIdx
                return TA_ReturnCode.Success
            }
            var sumXY: Double = 0.0
            var sumY: Double = 0.0
            var i: Int = optInTimePeriod
            while true {
                i -= 1
                if i == 0 {
                    break
                }
                let tempValue = inCandle[today - i][inCandleInputType]
                sumY += tempValue
                sumXY += Double(i) * tempValue
            }
            let m: Double = ((Double(optInTimePeriod) * sumXY) - (sumX * sumY)) / divisor
            outDouble[outIdx] = atan(m) * 57.295779513082323
            outIdx += 1
            today += 1
        }
    }
    
    public class func lookback(optInTimePeriod: Int) -> Int
    {
        var optInTimePeriod = optInTimePeriod
        
        if optInTimePeriod == Int.min {
            optInTimePeriod = self.optInTimePeriodDefault
        } else if optInTimePeriod < 2 || optInTimePeriod > 100000 {
            return -1
        }
        
        return (optInTimePeriod - 1)
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




