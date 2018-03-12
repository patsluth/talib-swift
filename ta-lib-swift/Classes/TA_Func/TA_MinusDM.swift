//
//  TA_MinusDM.swift
//  ta-lib-swift
//
//  Created by Pat Sluth on 2017-09-18.
//  Copyright © 2017 patsluth. All rights reserved.
//

import Foundation





// MINUS_DM - Minus Directional Movement
public class TA_MinusDM
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
        } else if optInTimePeriod < 1 || optInTimePeriod > 100000 {
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
        
        var tempReal = 0.0
        var today = 0
        var diffM = 0.0
        var prevLow = 0.0
        var prevHigh = 0.0
        var diffP = 0.0
        var outIdx = 0
        if optInTimePeriod <= 1 {
            outElementStartIndex = startIndex
            today = startIndex - 1
            prevHigh = inHigh[today]
            prevLow = inLow[today]
            while today < endIndex {
                today += 1
                tempReal = inHigh[today]
                diffP = tempReal - prevHigh
                prevHigh = tempReal
                tempReal = inLow[today]
                diffM = prevLow - tempReal
                prevLow = tempReal
                if diffM > 0.0 && diffP < diffM {
                    outDouble[outIdx] = diffM
                } else {
                    outDouble[outIdx] = 0.0
                }
                outIdx += 1
            }
            outElementCount = outIdx
            return TA_ReturnCode.Success
        }
        outElementStartIndex = startIndex
        var prevMinusDM = 0.0
        today = startIndex - lookbackTotal
        prevHigh = inHigh[today]
        prevLow = inLow[today]
        var i = optInTimePeriod - 1
        func Label_0138() -> TA_ReturnCode
        {
            i -= 1
            if i > 0 {
                today += 1
                tempReal = inHigh[today]
                diffP = tempReal - prevHigh
                prevHigh = tempReal
                tempReal = inLow[today]
                diffM = prevLow - tempReal
                prevLow = tempReal
                if diffM > 0.0 && diffP < diffM {
                    prevMinusDM += diffM
                }
                return Label_0138()
            }
            i = TA_Core.sharedInstance.globals.unstablePeriod[TA_FunctionUnstableId.MinusDM.rawValue]
            return Label_0186()
        }
        func Label_0186() -> TA_ReturnCode
        {
            i -= 1
            if i > 0 {
                today += 1
                tempReal = inHigh[today]
                diffP = tempReal - prevHigh
                prevHigh = tempReal
                tempReal = inLow[today]
                diffM = prevLow - tempReal
                prevLow = tempReal
                if diffM > 0.0 && diffP < diffM {
                    prevMinusDM = (prevMinusDM - (prevMinusDM / Double(optInTimePeriod))) + diffM
                } else {
                    prevMinusDM -= prevMinusDM / Double(optInTimePeriod)
                }
                return Label_0186()
            }
            outDouble[0] = prevMinusDM
            outIdx = 1
            while true {
                if today >= endIndex {
                    break
                }
                today += 1
                tempReal = inHigh[today]
                diffP = tempReal - prevHigh
                prevHigh = tempReal
                tempReal = inLow[today]
                diffM = prevLow - tempReal
                prevLow = tempReal
                if diffM > 0.0 && diffP < diffM {
                    prevMinusDM = (prevMinusDM - (prevMinusDM / Double(optInTimePeriod))) + diffM
                } else {
                    prevMinusDM -= prevMinusDM / Double(optInTimePeriod)
                }
                outDouble[outIdx] = prevMinusDM
                outIdx += 1
            }
            outElementCount = outIdx
            return TA_ReturnCode.Success
        }
        
        return Label_0138()
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
        } else if optInTimePeriod < 1 || optInTimePeriod > 100000 {
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
        
        var tempReal = 0.0
        var today = 0
        var diffM = 0.0
        var prevLow = 0.0
        var prevHigh = 0.0
        var diffP = 0.0
        var outIdx = 0
        if optInTimePeriod <= 1 {
            outElementStartIndex = startIndex
            today = startIndex - 1
            prevHigh = inCandle[today][TA_CandleInputType.High]
            prevLow = inCandle[today][TA_CandleInputType.Low]
            while today < endIndex {
                today += 1
                tempReal = inCandle[today][TA_CandleInputType.High]
                diffP = tempReal - prevHigh
                prevHigh = tempReal
                tempReal = inCandle[today][TA_CandleInputType.Low]
                diffM = prevLow - tempReal
                prevLow = tempReal
                if diffM > 0.0 && diffP < diffM {
                    outDouble[outIdx] = diffM
                } else {
                    outDouble[outIdx] = 0.0
                }
                outIdx += 1
            }
            outElementCount = outIdx
            return TA_ReturnCode.Success
        }
        outElementStartIndex = startIndex
        var prevMinusDM = 0.0
        today = startIndex - lookbackTotal
        prevHigh = inCandle[today][TA_CandleInputType.High]
        prevLow = inCandle[today][TA_CandleInputType.Low]
        var i = optInTimePeriod - 1
        func Label_0138() -> TA_ReturnCode
        {
            i -= 1
            if i > 0 {
                today += 1
                tempReal = inCandle[today][TA_CandleInputType.High]
                diffP = tempReal - prevHigh
                prevHigh = tempReal
                tempReal = inCandle[today][TA_CandleInputType.Low]
                diffM = prevLow - tempReal
                prevLow = tempReal
                if diffM > 0.0 && diffP < diffM {
                    prevMinusDM += diffM
                }
                return Label_0138()
            }
            i = TA_Core.sharedInstance.globals.unstablePeriod[TA_FunctionUnstableId.MinusDM.rawValue]
            return Label_0186()
        }
        func Label_0186() -> TA_ReturnCode
        {
            i -= 1
            if i > 0 {
                today += 1
                tempReal = inCandle[today][TA_CandleInputType.High]
                diffP = tempReal - prevHigh
                prevHigh = tempReal
                tempReal = inCandle[today][TA_CandleInputType.Low]
                diffM = prevLow - tempReal
                prevLow = tempReal
                if diffM > 0.0 && diffP < diffM {
                    prevMinusDM = (prevMinusDM - (prevMinusDM / Double(optInTimePeriod))) + diffM
                } else {
                    prevMinusDM -= prevMinusDM / Double(optInTimePeriod)
                }
                return Label_0186()
            }
            outDouble[0] = prevMinusDM
            outIdx = 1
            while true {
                if today >= endIndex {
                    break
                }
                today += 1
                tempReal = inCandle[today][TA_CandleInputType.High]
                diffP = tempReal - prevHigh
                prevHigh = tempReal
                tempReal = inCandle[today][TA_CandleInputType.Low]
                diffM = prevLow - tempReal
                prevLow = tempReal
                if diffM > 0.0 && diffP < diffM {
                    prevMinusDM = (prevMinusDM - (prevMinusDM / Double(optInTimePeriod))) + diffM
                } else {
                    prevMinusDM -= prevMinusDM / Double(optInTimePeriod)
                }
                outDouble[outIdx] = prevMinusDM
                outIdx += 1
            }
            outElementCount = outIdx
            return TA_ReturnCode.Success
        }
        
        return Label_0138()
    }
    
    public class func lookback(optInTimePeriod: Int) -> Int
    {
        var optInTimePeriod = optInTimePeriod
        
        if optInTimePeriod == Int.min {
            optInTimePeriod = self.optInTimePeriodDefault
        } else if optInTimePeriod < 1 || optInTimePeriod > 100000 {
            return -1
        }
        if optInTimePeriod > 1 {
            return ((optInTimePeriod + TA_Core.sharedInstance.globals.unstablePeriod[TA_FunctionUnstableId.MinusDM.rawValue]) - 1)
        }
        return 1
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




