//
//  TA_Kama.swift
//  ta-lib-swift
//
//  Created by Pat Sluth on 2017-09-18.
//  Copyright © 2017 patsluth. All rights reserved.
//

import Foundation





// KAMA- Kaufman Adaptive Moving Average
public class TA_Kama
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
        
        var tempReal: Double
        let constMax = 0.064516129032258063
        let constDiff = 0.66666666666666663 - constMax
        var sumROC1 = 0.0
        var today = startIndex - lookbackTotal
        var trailingIdx = today
        var i = optInTimePeriod
        while true {
            i -= 1
            if i <= 0 {
                break
            }
            tempReal = inDouble[today]
            today += 1
            tempReal -= inDouble[today]
            sumROC1 += fabs(tempReal)
        }
        var prevKAMA = inDouble[today - 1]
        tempReal = inDouble[today]
        var tempReal2 = inDouble[trailingIdx]
        trailingIdx += 1
        var periodROC = tempReal - tempReal2
        let trailingValue = tempReal2
        tempReal = (tempReal * constDiff) + constMax
        tempReal *= tempReal
        prevKAMA = ((inDouble[today] - prevKAMA) * tempReal) + prevKAMA
        today += 1
        while true {
            if today > startIndex {
                break
            }
            tempReal = inDouble[today]
            tempReal2 = inDouble[trailingIdx]
            trailingIdx += 1
            periodROC = tempReal - tempReal2
            sumROC1 -= fabs(trailingValue - tempReal2)
            sumROC1 += fabs(tempReal - inDouble[today - 1])
            if sumROC1 <= periodROC || (-1E-08 < sumROC1 && sumROC1 < 1E-08) {
                tempReal = 1.0;
            } else {
                tempReal = fabs(periodROC / sumROC1)
            }
            tempReal = (tempReal * constDiff) + constMax
            tempReal *= tempReal
            prevKAMA = ((inDouble[today] - prevKAMA) * tempReal) + prevKAMA
            today += 1
        }
        outDouble[0] = prevKAMA
        var outIdx = 0
        outElementStartIndex = today - 1
        while true {
            if today > endIndex {
                break
            }
            tempReal = inDouble[today]
            tempReal2 = inDouble[trailingIdx]
            trailingIdx += 1
            periodROC = tempReal - tempReal2
            sumROC1 -= fabs(trailingValue - tempReal2)
            sumROC1 += fabs(tempReal - inDouble[today - 1])
            if sumROC1 <= periodROC || (-1E-08 < sumROC1 && sumROC1 < 1E-08) {
                tempReal = 1.0;
            } else {
                tempReal = fabs(periodROC / sumROC1)
            }
            tempReal = (tempReal * constDiff) + constMax
            tempReal *= tempReal
            prevKAMA = ((inDouble[today] - prevKAMA) * tempReal) + prevKAMA
            today += 1
            outDouble[outIdx] = prevKAMA
            outIdx += 1
        }
        
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
        
        var tempReal: Double
        let constMax = 0.064516129032258063
        let constDiff = 0.66666666666666663 - constMax
        var sumROC1 = 0.0
        var today = startIndex - lookbackTotal
        var trailingIdx = today
        var i = optInTimePeriod
        while true {
            i -= 1
            if i <= 0 {
                break
            }
            tempReal = inCandle[today][inCandleInputType]
            today += 1
            tempReal -= inCandle[today][inCandleInputType]
            sumROC1 += fabs(tempReal)
        }
        var prevKAMA = inCandle[today - 1][inCandleInputType]
        tempReal = inCandle[today][inCandleInputType]
        var tempReal2 = inCandle[trailingIdx][inCandleInputType]
        trailingIdx += 1
        var periodROC = tempReal - tempReal2
        let trailingValue = tempReal2
        tempReal = (tempReal * constDiff) + constMax
        tempReal *= tempReal
        prevKAMA = ((inCandle[today][inCandleInputType] - prevKAMA) * tempReal) + prevKAMA
        today += 1
        while true {
            if today > startIndex {
                break
            }
            tempReal = inCandle[today][inCandleInputType]
            tempReal2 = inCandle[trailingIdx][inCandleInputType]
            trailingIdx += 1
            periodROC = tempReal - tempReal2
            sumROC1 -= fabs(trailingValue - tempReal2)
            sumROC1 += fabs(tempReal - inCandle[today - 1][inCandleInputType])
            if sumROC1 <= periodROC || (-1E-08 < sumROC1 && sumROC1 < 1E-08) {
                tempReal = 1.0;
            } else {
                tempReal = fabs(periodROC / sumROC1)
            }
            tempReal = (tempReal * constDiff) + constMax
            tempReal *= tempReal
            prevKAMA = ((inCandle[today][inCandleInputType] - prevKAMA) * tempReal) + prevKAMA
            today += 1
        }
        outDouble[0] = prevKAMA
        var outIdx = 0
        outElementStartIndex = today - 1
        while true {
            if today > endIndex {
                break
            }
            tempReal = inCandle[today][inCandleInputType]
            tempReal2 = inCandle[trailingIdx][inCandleInputType]
            trailingIdx += 1
            periodROC = tempReal - tempReal2
            sumROC1 -= fabs(trailingValue - tempReal2)
            sumROC1 += fabs(tempReal - inCandle[today - 1][inCandleInputType])
            if sumROC1 <= periodROC || (-1E-08 < sumROC1 && sumROC1 < 1E-08) {
                tempReal = 1.0;
            } else {
                tempReal = fabs(periodROC / sumROC1)
            }
            tempReal = (tempReal * constDiff) + constMax
            tempReal *= tempReal
            prevKAMA = ((inCandle[today][inCandleInputType] - prevKAMA) * tempReal) + prevKAMA
            today += 1
            outDouble[outIdx] = prevKAMA
            outIdx += 1
        }
        
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
        
        return (optInTimePeriod + TA_Core.sharedInstance.globals.unstablePeriod[TA_FunctionUnstableId.Kama.rawValue])
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




