//
//  TA_Min.swift
//  ta-lib-swift
//
//  Created by Pat Sluth on 2017-09-18.
//  Copyright © 2017 patsluth. All rights reserved.
//

import Foundation





// MIN - Lowest value over a specified period
public class TA_Min
{
    public static let optInTimePeriodDefault = 30
    
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
        var trailingIdx = startIndex - allocationSize
        var lowestIdx = -1
        var lowest = 0.0
        var tmp: Double
        
        while today <= endIndex {
            tmp = inDouble[today]
            if lowestIdx < trailingIdx {
                lowestIdx = trailingIdx
                lowest = inDouble[lowestIdx]
                var i = lowestIdx
                while i + 1 <= today {
                    i += 1
                    tmp = inDouble[i]
                    if tmp < lowest {
                        lowestIdx = i
                        lowest = tmp
                    }
                }
            } else if tmp <= lowest {
                lowestIdx = today
                lowest = tmp
            }
            outDouble[outIdx] = lowest
            outIdx += 1
            trailingIdx += 1
            today += 1
        }
        
        outElementStartIndex = startIndex
        outElementCount = outIdx
        
        return TA_ReturnCode.Success
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
        var trailingIdx = startIndex - allocationSize
        var lowestIdx = -1
        var lowest = 0.0
        var tmp: Double
        
        while today <= endIndex {
            tmp = inCandle[today][inCandleInputType]
            if lowestIdx < trailingIdx {
                lowestIdx = trailingIdx
                lowest = inCandle[lowestIdx][inCandleInputType]
                var i = lowestIdx
                while i + 1 <= today {
                    i += 1
                    tmp = inCandle[i][inCandleInputType]
                    if tmp < lowest {
                        lowestIdx = i
                        lowest = tmp
                    }
                }
            } else if tmp <= lowest {
                lowestIdx = today
                lowest = tmp
            }
            outDouble[outIdx] = lowest
            outIdx += 1
            trailingIdx += 1
            today += 1
        }
        
        outElementStartIndex = startIndex
        outElementCount = outIdx
        
        return TA_ReturnCode.Success
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




