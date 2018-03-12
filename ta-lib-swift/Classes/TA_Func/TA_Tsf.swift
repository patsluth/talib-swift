//
//  TA_Tsf.swift
//  ta-lib-swift
//
//  Created by Pat Sluth on 2017-09-18.
//  Copyright © 2017 patsluth. All rights reserved.
//

import Foundation





// TSF - Time Series Forecast
public class TA_Tsf
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
        
        var outIdx = 0
        var today = startIndex
        let SumX = (Double(optInTimePeriod) * (Double(optInTimePeriod) - 1.0)) * 0.5
        let SumXSqr = ((Double(optInTimePeriod) * (Double(optInTimePeriod) - 1.0)) * ((Double(optInTimePeriod) * 2.0) - 1.0)) / 6.0
        let Divisor = (SumX * SumX) - (Double(optInTimePeriod) * SumXSqr)
        while true {
            if today > endIndex {
                outElementStartIndex = startIndex
                outElementCount = outIdx
                return TA_ReturnCode.Success
            }
            var SumXY = 0.0
            var SumY = 0.0
            var i = optInTimePeriod
            while true {
                i -= 1
                if i == 0 {
                    break
                }
                let tempValue1 = inDouble[today - i]
                SumY += tempValue1
                SumXY += Double(i) * tempValue1
            }
            let m = ((Double(optInTimePeriod) * SumXY) - (SumX * SumY)) / Divisor
            let b = (SumY - (m * SumX)) / (Double(optInTimePeriod))
            outDouble[outIdx] = b + (m * Double(optInTimePeriod))
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
        
        var outIdx = 0
        var today = startIndex
        let SumX = (Double(optInTimePeriod) * (Double(optInTimePeriod) - 1.0)) * 0.5
        let SumXSqr = ((Double(optInTimePeriod) * (Double(optInTimePeriod) - 1.0)) * ((Double(optInTimePeriod) * 2.0) - 1.0)) / 6.0
        let Divisor = (SumX * SumX) - (Double(optInTimePeriod) * SumXSqr)
        while true {
            if today > endIndex {
                outElementStartIndex = startIndex
                outElementCount = outIdx
                return TA_ReturnCode.Success
            }
            var SumXY = 0.0
            var SumY = 0.0
            var i = optInTimePeriod
            while true {
                i -= 1
                if i == 0 {
                    break
                }
                let tempValue1 = inCandle[today - i][inCandleInputType]
                SumY += tempValue1
                SumXY += Double(i) * tempValue1
            }
            let m = ((Double(optInTimePeriod) * SumXY) - (SumX * SumY)) / Divisor
            let b = (SumY - (m * SumX)) / (Double(optInTimePeriod))
            outDouble[outIdx] = b + (m * Double(optInTimePeriod))
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
        var returnValue = optInTimePeriod + TA_Core.sharedInstance.globals.unstablePeriod[TA_FunctionUnstableId.Rsi.rawValue]
        if TA_Core.sharedInstance.globals.compatibility == TA_Compatibility.Metastock {
            returnValue -= 1
        }
        
        return returnValue
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




