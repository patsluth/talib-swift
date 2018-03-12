//
//  TA_MinMaxIndex.swift
//  ta-lib-swift
//
//  Created by Pat Sluth on 2017-09-18.
//  Copyright © 2017 patsluth. All rights reserved.
//

import Foundation





// MINMAXINDEX - Indexes of lowest and highest values over a specified period
public class TA_MinMaxIndex
{
    public static let optInTimePeriodDefault = 30
    
    public class func calculate(startIndex: Int,
                                endIndex: Int,
                                inDouble: [Double],
                                optInTimePeriod: Int,
                                outElementStartIndex: inout Int,
                                outElementCount: inout Int,
                                outMinIndex: inout [Int],
                                outMaxIndex: inout [Int]) -> TA_ReturnCode
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
        outMinIndex = [Int](repeating: 0, count: allocationSize)
        outMaxIndex = [Int](repeating: 0, count: allocationSize)
        
        var i = 0
        var outIdx = 0
        var today = startIndex
        var trailingIdx = startIndex - lookbackTotal
        var highestIdx = -1
        var highest = 0.0
        var lowestIdx = -1
        var lowest = 0.0
        var tmpHigh = Double.infinity
        var tmpLow = -Double.infinity
        func Label_00A5() -> TA_ReturnCode
        {
            if today > endIndex {
                outElementStartIndex = startIndex
                outElementCount = outIdx
                return TA_ReturnCode.Success
            }
            tmpHigh = inDouble[today]
            tmpLow = tmpHigh
            if highestIdx < trailingIdx {
                highestIdx = trailingIdx
                highest = inDouble[highestIdx]
                i = highestIdx
                while true {
                    i += 1
                    if i > today {
                        return Label_00EC()
                    }
                    tmpHigh = inDouble[i]
                    if tmpHigh > highest {
                        highestIdx = i
                        highest = tmpHigh
                    }
                }
            }
            if tmpHigh >= highest {
                highestIdx = today
                highest = tmpHigh
            }
            return Label_00EC()
        }
        func Label_00EC() -> TA_ReturnCode
        {
            if lowestIdx < trailingIdx {
                lowestIdx = trailingIdx
                lowest = inDouble[lowestIdx]
                i = lowestIdx
                while true {
                    i += 1
                    if i > today {
                        return Label_012A()
                    }
                    tmpLow = inDouble[i]
                    if tmpLow < lowest {
                        lowestIdx = i
                        lowest = tmpLow
                    }
                }
            }
            if tmpLow <= lowest {
                lowestIdx = today
                lowest = tmpLow
            }
            return Label_012A()
        }
        func Label_012A() -> TA_ReturnCode
        {
            outMaxIndex[outIdx] = highestIdx
            outMinIndex[outIdx] = lowestIdx
            outIdx += 1
            trailingIdx += 1
            today += 1
            return Label_00A5()
        }
        
        return Label_00A5()
    }
    
    public class func calculate(startIndex: Int,
                                endIndex: Int,
                                inCandle: [TA_Candle],
                                inCandleInputType: TA_CandleInputType,
                                optInTimePeriod: Int,
                                outElementStartIndex: inout Int,
                                outElementCount: inout Int,
                                outMinIndex: inout [Int],
                                outMaxIndex: inout [Int]) -> TA_ReturnCode
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
        outMinIndex = [Int](repeating: 0, count: allocationSize)
        outMaxIndex = [Int](repeating: 0, count: allocationSize)
        
        var i = 0
        var outIdx = 0
        var today = startIndex
        var trailingIdx = startIndex - lookbackTotal
        var highestIdx = -1
        var highest = 0.0
        var lowestIdx = -1
        var lowest = 0.0
        var tmpHigh = Double.infinity
        var tmpLow = -Double.infinity
        func Label_00A5() -> TA_ReturnCode
        {
            if today > endIndex {
                outElementStartIndex = startIndex
                outElementCount = outIdx
                return TA_ReturnCode.Success
            }
            tmpHigh = inCandle[today][inCandleInputType]
            tmpLow = tmpHigh
            if highestIdx < trailingIdx {
                highestIdx = trailingIdx
                highest = inCandle[highestIdx][inCandleInputType]
                i = highestIdx
                while true {
                    i += 1
                    if i > today {
                        return Label_00EC()
                    }
                    tmpHigh = inCandle[i][inCandleInputType]
                    if tmpHigh > highest {
                        highestIdx = i
                        highest = tmpHigh
                    }
                }
            }
            if tmpHigh >= highest {
                highestIdx = today
                highest = tmpHigh
            }
            return Label_00EC()
        }
        func Label_00EC() -> TA_ReturnCode
        {
            if lowestIdx < trailingIdx {
                lowestIdx = trailingIdx
                lowest = inCandle[lowestIdx][inCandleInputType]
                i = lowestIdx
                while true {
                    i += 1
                    if i > today {
                        return Label_012A()
                    }
                    tmpLow = inCandle[i][inCandleInputType]
                    if tmpLow < lowest {
                        lowestIdx = i
                        lowest = tmpLow
                    }
                }
            }
            if tmpLow <= lowest {
                lowestIdx = today
                lowest = tmpLow
            }
            return Label_012A()
        }
        func Label_012A() -> TA_ReturnCode
        {
            outMaxIndex[outIdx] = highestIdx
            outMinIndex[outIdx] = lowestIdx
            outIdx += 1
            trailingIdx += 1
            today += 1
            return Label_00A5()
        }
        
        return Label_00A5()
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




