//
//  TA_Correl.swift
//  ta-lib-swift
//
//  Created by Pat Sluth on 2017-09-18.
//  Copyright © 2017 patsluth. All rights reserved.
//

import Foundation





// CORREL - Pearson's Correlation Coefficient (r)
public class TA_Correl
{
    public static let optInTimePeriodDefault = 30
    
    public class func calculate(startIndex: Int,
                                endIndex: Int,
                                inDouble0: [Double],
                                inDouble1: [Double],
                                optInTimePeriod: Int,
                                outElementStartIndex: inout Int,
                                outElementCount: inout Int,
                                outDouble: inout [Double]) -> TA_ReturnCode
    {
        var startIndex = startIndex
        
        outElementStartIndex = 0
        outElementCount = 0
        
        if startIndex < 0 {
            return TA_ReturnCode.OutOfRangeStartIndex
        }
        if endIndex < 0 || endIndex < startIndex {
            return TA_ReturnCode.OutOfRangeStartIndex
        }
        let lookbackTotal = self.lookback(optInTimePeriod: optInTimePeriod)
        if startIndex < lookbackTotal {
            startIndex = lookbackTotal
        }
        
        let allocationSize = self.allocationSize(startIndex: startIndex,
                                                 endIndex: endIndex,
                                                 optInTimePeriod: optInTimePeriod)
        outDouble = [Double](repeating: Double.nan, count: allocationSize)
        
        if startIndex > endIndex {
            outElementStartIndex = 0
            outElementCount = 0
            return TA_ReturnCode.Success
        }
        outElementStartIndex = startIndex
        var trailingIdx = startIndex - lookbackTotal
        var x: Double
        var y: Double
        var sumY2 = 0.0
        var sumX2 = sumY2
        var sumY = sumX2
        var sumX = sumY
        var sumXY = sumX
        var today = trailingIdx
        while today <= startIndex {
            x = inDouble0[today]
            sumX += x
            sumX2 += x * x
            y = inDouble1[today]
            sumXY += x * y
            sumY += y
            sumY2 += y * y
            today += 1
        }
        var trailingX = inDouble0[trailingIdx]
        var trailingY = inDouble1[trailingIdx]
        trailingIdx += 1
        var tempReal = (sumX2 - ((sumX * sumX) / (Double(optInTimePeriod)))) * (sumY2 - ((sumY * sumY) / (Double(optInTimePeriod))))
        if tempReal >= 1E-08 {
            outDouble[0] = (sumXY - ((sumX * sumY) / (Double(optInTimePeriod)))) / sqrt(tempReal)
        } else {
            outDouble[0] = 0.0
        }
        var outIdx = 1
        while today <= endIndex {
            sumX -= trailingX
            sumX2 -= trailingX * trailingX
            sumXY -= trailingX * trailingY
            sumY -= trailingY
            sumY2 -= trailingY * trailingY
            x = inDouble0[today]
            sumX += x
            sumX2 += x * x
            y = inDouble1[today]
            today += 1
            sumXY += x * y
            sumY += y
            sumY2 += y * y
            trailingX = inDouble0[trailingIdx]
            trailingY = inDouble1[trailingIdx]
            trailingIdx += 1
            tempReal = (sumX2 - ((sumX * sumX) / (Double(optInTimePeriod)))) * (sumY2 - ((sumY * sumY) / (Double(optInTimePeriod))))
            if tempReal >= 1E-08 {
                outDouble[outIdx] = (sumXY - ((sumX * sumY) / (Double(optInTimePeriod)))) / sqrt(tempReal)
            } else {
                outDouble[outIdx] = 0.0
            }
            outIdx += 1
        }
        
        outElementCount = outIdx
        
        return TA_ReturnCode.Success
    }
    
    public class func calculate(startIndex: Int,
                                endIndex: Int,
                                inCandle: [TA_Candle],
                                inCandleInputType0: TA_CandleInputType,
                                inCandleInputType1: TA_CandleInputType,
                                optInTimePeriod: Int,
                                outElementStartIndex: inout Int,
                                outElementCount: inout Int,
                                outDouble: inout [Double]) -> TA_ReturnCode
    {
        var startIndex = startIndex
        
        outElementStartIndex = 0
        outElementCount = 0
        
        if startIndex < 0 {
            return TA_ReturnCode.OutOfRangeStartIndex
        }
        if endIndex < 0 || endIndex < startIndex {
            return TA_ReturnCode.OutOfRangeStartIndex
        }
        let lookbackTotal = self.lookback(optInTimePeriod: optInTimePeriod)
        if startIndex < lookbackTotal {
            startIndex = lookbackTotal
        }
        
        let allocationSize = self.allocationSize(startIndex: startIndex,
                                                 endIndex: endIndex,
                                                 optInTimePeriod: optInTimePeriod)
        outDouble = [Double](repeating: Double.nan, count: allocationSize)
        
        if startIndex > endIndex {
            outElementStartIndex = 0
            outElementCount = 0
            return TA_ReturnCode.Success
        }
        outElementStartIndex = startIndex
        var trailingIdx = startIndex - lookbackTotal
        var x: Double
        var y: Double
        var sumY2 = 0.0
        var sumX2 = sumY2
        var sumY = sumX2
        var sumX = sumY
        var sumXY = sumX
        var today = trailingIdx
        while today <= startIndex {
            x = inCandle[today][inCandleInputType0]
            sumX += x
            sumX2 += x * x
            y = inCandle[today][inCandleInputType1]
            sumXY += x * y
            sumY += y
            sumY2 += y * y
            today += 1
        }
        var trailingX = inCandle[trailingIdx][inCandleInputType0]
        var trailingY = inCandle[trailingIdx][inCandleInputType1]
        trailingIdx += 1
        var tempReal = (sumX2 - ((sumX * sumX) / (Double(optInTimePeriod)))) * (sumY2 - ((sumY * sumY) / (Double(optInTimePeriod))))
        if tempReal >= 1E-08 {
            outDouble[0] = (sumXY - ((sumX * sumY) / (Double(optInTimePeriod)))) / sqrt(tempReal)
        } else {
            outDouble[0] = 0.0
        }
        var outIdx = 1
        while today <= endIndex {
            sumX -= trailingX
            sumX2 -= trailingX * trailingX
            sumXY -= trailingX * trailingY
            sumY -= trailingY
            sumY2 -= trailingY * trailingY
            x = inCandle[today][inCandleInputType0]
            sumX += x
            sumX2 += x * x
            y = inCandle[today][inCandleInputType1]
            today += 1
            sumXY += x * y
            sumY += y
            sumY2 += y * y
            trailingX = inCandle[trailingIdx][inCandleInputType0]
            trailingY = inCandle[trailingIdx][inCandleInputType1]
            trailingIdx += 1
            tempReal = (sumX2 - ((sumX * sumX) / (Double(optInTimePeriod)))) * (sumY2 - ((sumY * sumY) / (Double(optInTimePeriod))))
            if tempReal >= 1E-08 {
                outDouble[outIdx] = (sumXY - ((sumX * sumY) / (Double(optInTimePeriod)))) / sqrt(tempReal)
            } else {
                outDouble[outIdx] = 0.0
            }
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




