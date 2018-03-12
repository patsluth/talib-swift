//
//  TA_Aroon.swift
//  ta-lib-swift
//
//  Created by Pat Sluth on 2017-09-18.
//  Copyright © 2017 patsluth. All rights reserved.
//

import Foundation





// AROON - Aroon
public class TA_Aroon
{
    public static let optInTimePeriodDefault = 14
    
    public class func calculate(startIndex: Int,
                                endIndex: Int,
                                inHigh: [Double],
                                inLow: [Double],
                                optInTimePeriod: Int,
                                outElementStartIndex: inout Int,
                                outElementCount: inout Int,
                                outAroonDown: inout [Double],
                                outAroonUp: inout [Double]) -> TA_ReturnCode
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
        outAroonDown = [Double](repeating: Double.nan, count: allocationSize)
        outAroonUp = [Double](repeating: Double.nan, count: allocationSize)
        
        var i = 1
        var outIdx = 0
        var today = startIndex
        var trailingIdx = startIndex - optInTimePeriod
        var lowestIdx = -1
        var highestIdx = -1
        var lowest = 0.0
        var highest = 0.0
        var factor = 100.0 / Double(optInTimePeriod)
        var tmp = 0.0
        func Label_00BB() -> TA_ReturnCode
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
                        return Label_00FF()
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
            return Label_00FF()
        }
        func Label_00FF() -> TA_ReturnCode
        {
            tmp = inHigh[today]
            if highestIdx < trailingIdx {
                highestIdx = trailingIdx
                highest = inHigh[highestIdx]
                i = highestIdx
                while true {
                    i += 1
                    if i > today {
                        return Label_0136()
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
            return Label_0136()
        }
        func Label_0136() -> TA_ReturnCode
        {
            outAroonUp[outIdx] = factor * Double(optInTimePeriod - (today - highestIdx))
            outAroonDown[outIdx] = factor * Double(optInTimePeriod - (today - lowestIdx))
            outIdx += 1
            trailingIdx += 1
            today += 1
            return Label_00BB()
        }
        
        return Label_00BB()
    }
    
    public class func calculate(startIndex: Int,
                                endIndex: Int,
                                inCandle: [TA_Candle],
                                optInTimePeriod: Int,
                                outElementStartIndex: inout Int,
                                outElementCount: inout Int,
                                outAroonDown: inout [Double],
                                outAroonUp: inout [Double]) -> TA_ReturnCode
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
        outAroonDown = [Double](repeating: Double.nan, count: allocationSize)
        outAroonUp = [Double](repeating: Double.nan, count: allocationSize)
        
        var i = 1
        var outIdx = 0
        var today = startIndex
        var trailingIdx = startIndex - optInTimePeriod
        var lowestIdx = -1
        var highestIdx = -1
        var lowest = 0.0
        var highest = 0.0
        var factor = 100.0 / Double(optInTimePeriod)
        var tmp = 0.0
        func Label_00BB() -> TA_ReturnCode
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
                        return Label_00FF()
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
            return Label_00FF()
        }
        func Label_00FF() -> TA_ReturnCode
        {
            tmp = inCandle[today][TA_CandleInputType.High]
            if highestIdx < trailingIdx {
                highestIdx = trailingIdx
                highest = inCandle[highestIdx][TA_CandleInputType.High]
                i = highestIdx
                while true {
                    i += 1
                    if i > today {
                        return Label_0136()
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
            return Label_0136()
        }
        func Label_0136() -> TA_ReturnCode
        {
            outAroonUp[outIdx] = factor * Double(optInTimePeriod - (today - highestIdx))
            outAroonDown[outIdx] = factor * Double(optInTimePeriod - (today - lowestIdx))
            outIdx += 1
            trailingIdx += 1
            today += 1
            return Label_00BB()
        }
        
        return Label_00BB()
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




