//
//  TA_AroonnOsc.swift
//  ta-lib-swift
//
//  Created by Pat Sluth on 2017-09-18.
//  Copyright © 2017 patsluth. All rights reserved.
//

import Foundation





// AROONOSC - Aroon Oscillator
public class TA_AroonnOsc
{
    public static let optInTimePeriodDefault = 14
    
    public class func calculate(startIndex: Int,
                                endIndex: Int,
                                inHigh: [Double],
                                inLow: [Double],
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
        
        var i = 0
        var aroon = 0.0
        var outIdx = 0
        var today = startIndex
        var trailingIdx = startIndex - optInTimePeriod
        var lowestIdx = -1
        var highestIdx = -1
        var lowest = 0.0
        var highest = 0.0
        var factor = 100.0 / Double(optInTimePeriod)
        var tmp = 0.0
        func Label_00AF() -> TA_ReturnCode
        {
            if today > endIndex {
                outElementStartIndex = startIndex
                outElementCount = outIdx
                return TA_ReturnCode.Success
            }
            tmp = inLow[today]
            if lowestIdx < trailingIdx {
                lowestIdx = trailingIdx
                lowest = inLow[lowestIdx]
                i = lowestIdx
                while true {
                    i += 1
                    if i > today {
                        return Label_00F3()
                    }
                    tmp = inLow[i]
                    if tmp <= lowest {
                        lowestIdx = i
                        lowest = tmp
                    }
                }
            }
            if tmp <= lowest {
                lowestIdx = today
                lowest = tmp
            }
            return Label_00F3()
        }
        func Label_00F3() -> TA_ReturnCode
        {
            tmp = inHigh[today]
            if highestIdx < trailingIdx {
                highestIdx = trailingIdx
                highest = inHigh[highestIdx]
                i = highestIdx
                while true {
                    i += 1
                    if i > today {
                        return Label_012A()
                    }
                    tmp = inHigh[i]
                    if tmp >= highest {
                        highestIdx = i
                        highest = tmp
                    }
                }
            }
            if tmp >= highest {
                highestIdx = today
                highest = tmp
            }
            return Label_012A()
        }
        func Label_012A() -> TA_ReturnCode
        {
            aroon = factor * Double(highestIdx - lowestIdx)
            outDouble[outIdx] = aroon
            outIdx += 1
            trailingIdx += 1
            today += 1
            return Label_00AF()
        }
        
        return Label_00AF()
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
        
        var i = 0
        var aroon = 0.0
        var outIdx = 0
        var today = startIndex
        var trailingIdx = startIndex - optInTimePeriod
        var lowestIdx = -1
        var highestIdx = -1
        var lowest = 0.0
        var highest = 0.0
        var factor = 100.0 / Double(optInTimePeriod)
        var tmp = 0.0
        func Label_00AF() -> TA_ReturnCode
        {
            if today > endIndex {
                outElementStartIndex = startIndex
                outElementCount = outIdx
                return TA_ReturnCode.Success
            }
            tmp = inCandle[today][TA_CandleInputType.Low]
            if lowestIdx < trailingIdx {
                lowestIdx = trailingIdx
                lowest = inCandle[lowestIdx][TA_CandleInputType.Low]
                i = lowestIdx
                while true {
                    i += 1
                    if i > today {
                        return Label_00F3()
                    }
                    tmp = inCandle[i][TA_CandleInputType.Low]
                    if tmp <= lowest {
                        lowestIdx = i
                        lowest = tmp
                    }
                }
            }
            if tmp <= lowest {
                lowestIdx = today
                lowest = tmp
            }
            return Label_00F3()
        }
        func Label_00F3() -> TA_ReturnCode
        {
            tmp = inCandle[today][TA_CandleInputType.High]
            if highestIdx < trailingIdx {
                highestIdx = trailingIdx
                highest = inCandle[highestIdx][TA_CandleInputType.High]
                i = highestIdx
                while true {
                    i += 1
                    if i > today {
                        return Label_012A()
                    }
                    tmp = inCandle[i][TA_CandleInputType.High]
                    if tmp >= highest {
                        highestIdx = i
                        highest = tmp
                    }
                }
            }
            if tmp >= highest {
                highestIdx = today
                highest = tmp
            }
            return Label_012A()
        }
        func Label_012A() -> TA_ReturnCode
        {
            aroon = factor * Double(highestIdx - lowestIdx)
            outDouble[outIdx] = aroon
            outIdx += 1
            trailingIdx += 1
            today += 1
            return Label_00AF()
        }
        
        return Label_00AF()
    }
    
    public class func lookback(optInTimePeriod: Int) -> Int
    {
        var optInTimePeriod = optInTimePeriod
        
        if optInTimePeriod == Int.min {
            optInTimePeriod = self.optInTimePeriodDefault
        } else if optInTimePeriod < 2 || optInTimePeriod > 100000 {
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




