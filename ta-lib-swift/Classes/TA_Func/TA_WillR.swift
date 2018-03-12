//
//  TA_WillR.swift
//  ta-lib-swift
//
//  Created by Pat Sluth on 2017-09-18.
//  Copyright © 2017 patsluth. All rights reserved.
//

import Foundation





// WILLR - Williams' %R
public class TA_WillR
{
    public static let optInTimePeriodDefault = 14
    
    public class func calculate(startIndex: Int,
                                endIndex: Int,
                                inHigh: [Double],
                                inLow: [Double],
                                inClose: [Double],
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
        var trailingIdx = startIndex - lookbackTotal
        var highestIdx = -1
        var lowestIdx = highestIdx
        var lowest = 0.0
        var highest = lowest
        var diff = highest
        var i = 0
        var tmp = 0.0
        func Label_00B1() -> TA_ReturnCode
        {
            if today > endIndex {
                outElementStartIndex = startIndex
                outElementCount = outIdx
                return TA_ReturnCode.Success
            }
            tmp = inLow[today]
            if lowestIdx >= trailingIdx {
                if tmp <= lowest {
                    lowestIdx = today
                    lowest = tmp
                    diff = (highest - lowest) / -100.0
                }
                return Label_0112()
            }
            lowestIdx = trailingIdx
            lowest = inLow[lowestIdx]
            i = lowestIdx
            Label_00D0()
            return Label_0112()
        }
        func Label_00D0()
        {
            i += 1
            if i <= today {
                tmp = inLow[i]
                if tmp < lowest {
                    lowestIdx = i
                    lowest = tmp
                }
                Label_00D0()
            }
            diff = (highest - lowest) / -100.0
        }
        func Label_0112() -> TA_ReturnCode
        {
            tmp = inHigh[today]
            if highestIdx >= trailingIdx {
                if tmp >= highest {
                    highestIdx = today
                    highest = tmp
                    diff = (highest - lowest) / -100.0
                }
                return Label_016B()
            }
            highestIdx = trailingIdx
            highest = inHigh[highestIdx]
            i = highestIdx
            return Label_0129()
        }
        func Label_0129() -> TA_ReturnCode
        {
            i += 1
            if i <= today {
                tmp = inHigh[today]
                if tmp > highest {
                    highestIdx = i
                    highest = tmp
                }
                return Label_0129()
            }
            diff = (highest - lowest) / -100.0
            return Label_016B()
        }
        func Label_016B() -> TA_ReturnCode
        {
            if diff != 0.0 {
                outDouble[outIdx] = (highest - inClose[today]) / diff
            } else {
                outDouble[outIdx] = 0.0
            }
            outIdx += 1
            trailingIdx += 1
            today += 1
            return Label_00B1()
        }
        
        return Label_00B1()
    }
    
    public class func calculate(startIndex: Int,
                                endIndex: Int,
                                inCandle: [TA_Candle],
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
        var trailingIdx = startIndex - lookbackTotal
        var highestIdx = -1
        var lowestIdx = highestIdx
        var lowest = 0.0
        var highest = lowest
        var diff = highest
        var i = 0
        var tmp = 0.0
        func Label_00B1() -> TA_ReturnCode
        {
            if today > endIndex {
                outElementStartIndex = startIndex
                outElementCount = outIdx
                return TA_ReturnCode.Success
            }
            tmp = inCandle[today][TA_CandleInputType.Low]
            if lowestIdx >= trailingIdx {
                if tmp <= lowest {
                    lowestIdx = today
                    lowest = tmp
                    diff = (highest - lowest) / -100.0
                }
                return Label_0112()
            }
            lowestIdx = trailingIdx
            lowest = inCandle[lowestIdx][TA_CandleInputType.Low]
            i = lowestIdx
            Label_00D0()
            return Label_0112()
        }
        func Label_00D0()
        {
            i += 1
            if i <= today {
                tmp = inCandle[i][TA_CandleInputType.Low]
                if tmp < lowest {
                    lowestIdx = i
                    lowest = tmp
                }
                Label_00D0()
            }
            diff = (highest - lowest) / -100.0
        }
        func Label_0112() -> TA_ReturnCode
        {
            tmp = inCandle[today][TA_CandleInputType.High]
            if highestIdx >= trailingIdx {
                if tmp >= highest {
                    highestIdx = today
                    highest = tmp
                    diff = (highest - lowest) / -100.0
                }
                return Label_016B()
            }
            highestIdx = trailingIdx
            highest = inCandle[highestIdx][TA_CandleInputType.High]
            i = highestIdx
            return Label_0129()
        }
        func Label_0129() -> TA_ReturnCode
        {
            i += 1
            if i <= today {
                tmp = inCandle[today][TA_CandleInputType.High]
                if tmp > highest {
                    highestIdx = i
                    highest = tmp
                }
                return Label_0129()
            }
            diff = (highest - lowest) / -100.0
            return Label_016B()
        }
        func Label_016B() -> TA_ReturnCode
        {
            if diff != 0.0 {
                outDouble[outIdx] = (highest - inCandle[today][TA_CandleInputType.Close]) / diff
            } else {
                outDouble[outIdx] = 0.0
            }
            outIdx += 1
            trailingIdx += 1
            today += 1
            return Label_00B1()
        }
        
        return Label_00B1()
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




