//
//  TA_Trima.swift
//  ta-lib-swift
//
//  Created by Pat Sluth on 2017-09-18.
//  Copyright © 2017 patsluth. All rights reserved.
//

import Foundation





// TRIMA - Triangular Moving Average
public class TA_Trima
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
        
        var i: Int
        var tempReal: Double
        var numerator: Double
        var numeratorAdd: Double
        var numeratorSub: Double
        var middleIdx: Int
        var trailingIdx: Int
        var todayIdx: Int
        var factor: Double
        var outIdx = 0
        if (optInTimePeriod % 2) != 1 {
            i = optInTimePeriod >> 1
            factor = Double(i) * (Double(i) + 1.0)
            factor = 1.0 / factor
            trailingIdx = startIndex - lookbackTotal
            middleIdx = (trailingIdx + i) - 1
            todayIdx = middleIdx + i
            numerator = 0.0
            numeratorSub = 0.0
            i = middleIdx
            while i >= trailingIdx {
                tempReal = inDouble[i]
                numeratorSub += tempReal
                numerator += numeratorSub
                i -= 1
            }
            numeratorAdd = 0.0
            middleIdx += 1
            for j in stride(from: middleIdx, through: todayIdx, by: 1) {
                tempReal = inDouble[j]
                numeratorAdd += tempReal
                numerator += numeratorAdd
            }
            outIdx = 0
            tempReal = inDouble[trailingIdx]
            trailingIdx += 1
            outDouble[outIdx] = numerator * factor
            outIdx += 1
            todayIdx += 1
            while todayIdx <= endIndex {
                numerator -= numeratorSub
                numeratorSub -= tempReal
                tempReal = inDouble[middleIdx]
                middleIdx += 1
                numeratorSub += tempReal
                numeratorAdd -= tempReal
                numerator += numeratorAdd
                tempReal = inDouble[todayIdx]
                todayIdx += 1
                numeratorAdd += tempReal
                numerator += tempReal
                tempReal = inDouble[trailingIdx]
                trailingIdx += 1
                outDouble[outIdx] = numerator * factor
                outIdx += 1
            }
        } else {
            i = optInTimePeriod >> 1
            factor = (Double(i) + 1.0) * (Double(i) + 1.0)
            factor = 1.0 / factor
            trailingIdx = startIndex - lookbackTotal
            middleIdx = trailingIdx + i
            todayIdx = middleIdx + i
            numerator = 0.0
            numeratorSub = 0.0
            for j in stride(from: middleIdx, through: trailingIdx, by: -1) {
                tempReal = inDouble[j]
                numeratorSub += tempReal
                numerator += numeratorSub
            }
            numeratorAdd = 0.0
            middleIdx += 1
            for j in stride(from: middleIdx, through: todayIdx, by: 1) {
                tempReal = inDouble[j]
                numeratorAdd += tempReal
                numerator += numeratorAdd
            }
            outIdx = 0
            tempReal = inDouble[trailingIdx]
            trailingIdx += 1
            outDouble[outIdx] = numerator * factor
            outIdx += 1
            todayIdx += 1
            while todayIdx <= endIndex {
                numerator -= numeratorSub
                numeratorSub -= tempReal
                tempReal = inDouble[middleIdx]
                middleIdx += 1
                numeratorSub += tempReal
                numerator += numeratorAdd
                numeratorAdd -= tempReal
                tempReal = inDouble[todayIdx]
                todayIdx += 1
                numeratorAdd += tempReal
                numerator += tempReal
                tempReal = inDouble[trailingIdx]
                trailingIdx += 1
                outDouble[outIdx] = numerator * factor
                outIdx += 1
            }
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
        
        var i: Int
        var tempReal: Double
        var numerator: Double
        var numeratorAdd: Double
        var numeratorSub: Double
        var middleIdx: Int
        var trailingIdx: Int
        var todayIdx: Int
        var factor: Double
        var outIdx = 0
        if (optInTimePeriod % 2) != 1 {
            i = optInTimePeriod >> 1
            factor = Double(i) * (Double(i) + 1.0)
            factor = 1.0 / factor
            trailingIdx = startIndex - lookbackTotal
            middleIdx = (trailingIdx + i) - 1
            todayIdx = middleIdx + i
            numerator = 0.0
            numeratorSub = 0.0
            i = middleIdx
            while i >= trailingIdx {
                tempReal = inCandle[i][inCandleInputType]
                numeratorSub += tempReal
                numerator += numeratorSub
                i -= 1
            }
            numeratorAdd = 0.0
            middleIdx += 1
            for j in stride(from: middleIdx, through: todayIdx, by: 1) {
                tempReal = inCandle[j][inCandleInputType]
                numeratorAdd += tempReal
                numerator += numeratorAdd
            }
            outIdx = 0
            tempReal = inCandle[trailingIdx][inCandleInputType]
            trailingIdx += 1
            outDouble[outIdx] = numerator * factor
            outIdx += 1
            todayIdx += 1
            while todayIdx <= endIndex {
                numerator -= numeratorSub
                numeratorSub -= tempReal
                tempReal = inCandle[middleIdx][inCandleInputType]
                middleIdx += 1
                numeratorSub += tempReal
                numeratorAdd -= tempReal
                numerator += numeratorAdd
                tempReal = inCandle[todayIdx][inCandleInputType]
                todayIdx += 1
                numeratorAdd += tempReal
                numerator += tempReal
                tempReal = inCandle[trailingIdx][inCandleInputType]
                trailingIdx += 1
                outDouble[outIdx] = numerator * factor
                outIdx += 1
            }
        } else {
            i = optInTimePeriod >> 1
            factor = (Double(i) + 1.0) * (Double(i) + 1.0)
            factor = 1.0 / factor
            trailingIdx = startIndex - lookbackTotal
            middleIdx = trailingIdx + i
            todayIdx = middleIdx + i
            numerator = 0.0
            numeratorSub = 0.0
            for j in stride(from: middleIdx, through: trailingIdx, by: -1) {
                tempReal = inCandle[j][inCandleInputType]
                numeratorSub += tempReal
                numerator += numeratorSub
            }
            numeratorAdd = 0.0
            middleIdx += 1
            for j in stride(from: middleIdx, through: todayIdx, by: 1) {
                tempReal = inCandle[j][inCandleInputType]
                numeratorAdd += tempReal
                numerator += numeratorAdd
            }
            outIdx = 0
            tempReal = inCandle[trailingIdx][inCandleInputType]
            trailingIdx += 1
            outDouble[outIdx] = numerator * factor
            outIdx += 1
            todayIdx += 1
            while todayIdx <= endIndex {
                numerator -= numeratorSub
                numeratorSub -= tempReal
                tempReal = inCandle[middleIdx][inCandleInputType]
                middleIdx += 1
                numeratorSub += tempReal
                numerator += numeratorAdd
                numeratorAdd -= tempReal
                tempReal = inCandle[todayIdx][inCandleInputType]
                todayIdx += 1
                numeratorAdd += tempReal
                numerator += tempReal
                tempReal = inCandle[trailingIdx][inCandleInputType]
                trailingIdx += 1
                outDouble[outIdx] = numerator * factor
                outIdx += 1
            }
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




