//
//  TA_Wma.swift
//  ta-lib-swift
//
//  Created by Pat Sluth on 2017-09-18.
//  Copyright © 2017 patsluth. All rights reserved.
//

import Foundation





// WMA - Weighted Moving Average
public class TA_Wma
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
        
        if optInTimePeriod == 1 {
            outElementStartIndex = startIndex
            outElementCount = (endIndex - startIndex) + 1
            TA_ArrayUtils.Copy(sourceArray: inDouble,
                               sourceIndex: startIndex,
                               destinationArray: &outDouble,
                               destinationIndex: 0,
                               length: outElementCount)
            return TA_ReturnCode.Success
        }
        let divider = (optInTimePeriod * (optInTimePeriod + 1)) >> 1
        var outIdx = 0
        var trailingIdx = startIndex - lookbackTotal
        var periodSub = 0.0
        var periodSum = periodSub
        var inIdx = trailingIdx
        var i = 1
        var tempReal: Double
        while inIdx < startIndex {
            tempReal = inDouble[inIdx]
            inIdx += 1
            periodSub += tempReal
            periodSum += (tempReal * Double(i))
            i += 1
        }
        var trailingValue = 0.0
        while inIdx <= endIndex {
            tempReal = inDouble[inIdx]
            inIdx += 1
            periodSub += tempReal
            periodSub -= trailingValue
            periodSum += (tempReal * Double(optInTimePeriod))
            trailingValue = inDouble[trailingIdx]
            trailingIdx += 1
            outDouble[outIdx] = (periodSum / Double(divider))
            outIdx += 1
            periodSum -= periodSub
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
        
        if optInTimePeriod == 1 {
            outElementStartIndex = startIndex
            outElementCount = (endIndex - startIndex) + 1
            TA_ArrayUtils.CopyCandleValues(sourceArray: inCandle,
                                           sourceIndex: startIndex,
                                           sourceCandleInputType: inCandleInputType,
                                           destinationArray: &outDouble,
                                           destinationIndex: 0,
                                           length: outElementCount)
            return TA_ReturnCode.Success
        }
        let divider = (optInTimePeriod * (optInTimePeriod + 1)) >> 1
        var outIdx = 0
        var trailingIdx = startIndex - lookbackTotal
        var periodSub = 0.0
        var periodSum = periodSub
        var inIdx = trailingIdx
        var i = 1
        var tempReal: Double
        while inIdx < startIndex {
            tempReal = inCandle[inIdx][inCandleInputType]
            inIdx += 1
            periodSub += tempReal
            periodSum += (tempReal * Double(i))
            i += 1
        }
        var trailingValue = 0.0
        while inIdx <= endIndex {
            tempReal = inCandle[inIdx][inCandleInputType]
            inIdx += 1
            periodSub += tempReal
            periodSub -= trailingValue
            periodSum += (tempReal * Double(optInTimePeriod))
            trailingValue = inCandle[trailingIdx][inCandleInputType]
            trailingIdx += 1
            outDouble[outIdx] = (periodSum / Double(divider))
            outIdx += 1
            periodSum -= periodSub
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




