//
//  TA_T3.swift
//  ta-lib-swift
//
//  Created by Pat Sluth on 2017-09-18.
//  Copyright © 2017 patsluth. All rights reserved.
//

import Foundation





// T3 - Triple Exponential Moving Average (T3)
public class TA_T3
{
    public static let optInTimePeriodDefault = 5
    public static let optInVFactorDefault = 0.7
    
    public class func calculate(startIndex: Int,
                                endIndex: Int,
                                inDouble: [Double],
                                optInTimePeriod: Int,
                                optInVFactor: Double,
                                outElementStartIndex: inout Int,
                                outElementCount: inout Int,
                                outDouble: inout [Double]) -> TA_ReturnCode
    {
        var startIndex = startIndex
        var optInTimePeriod = optInTimePeriod
        var optInVFactor = optInVFactor
        
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
        if optInVFactor == -4E+37 {
            optInVFactor = self.optInVFactorDefault
        } else if optInVFactor < 0.0 || optInVFactor > 1.0 {
            return TA_ReturnCode.BadParam
        }
        let lookbackTotal = self.lookback(optInTimePeriod: optInTimePeriod, optInVFactor: optInVFactor)
        if startIndex <= lookbackTotal {
            startIndex = lookbackTotal
        }
        if startIndex > endIndex {
            outElementStartIndex = 0
            outElementCount = 0
            return TA_ReturnCode.Success
        }
        
        let allocationSize = self.allocationSize(startIndex: startIndex,
                                                 endIndex: endIndex,
                                                 optInTimePeriod: optInTimePeriod,
                                                 optInVFactor: optInVFactor)
        outDouble = [Double](repeating: Double.nan, count: allocationSize)
    
        outElementStartIndex = startIndex
        var today = startIndex - lookbackTotal
        let k = 2.0 / (Double(optInTimePeriod) + 1.0)
        let one_minus_k = 1.0 - k
        var tempReal = inDouble[today]
        today += 1
        for _ in stride(from: optInTimePeriod - 1, to: 0, by: -1) {
            tempReal += inDouble[today]
            today += 1
        }
        var e1 = tempReal / Double(optInTimePeriod)
        tempReal = e1
        for _ in stride(from: optInTimePeriod - 1, to: 0, by: -1) {
            e1 = (k * inDouble[today]) + (one_minus_k * e1)
            today += 1
            tempReal += e1
        }
        var e2 = tempReal / Double(optInTimePeriod)
        tempReal = e2
        for _ in stride(from: optInTimePeriod - 1, to: 0, by: -1) {
            e1 = (k * inDouble[today]) + (one_minus_k * e1)
            today += 1
            e2 = (k * e1) + (one_minus_k * e2)
            tempReal += e2
        }
        var e3 = tempReal / Double(optInTimePeriod)
        tempReal = e3
        for _ in stride(from: optInTimePeriod - 1, to: 0, by: -1) {
            e1 = (k * inDouble[today]) + (one_minus_k * e1)
            today += 1
            e2 = (k * e1) + (one_minus_k * e2)
            e3 = (k * e2) + (one_minus_k * e3)
            tempReal += e3
        }
        var e4 = tempReal / Double(optInTimePeriod)
        tempReal = e4
        for _ in stride(from: optInTimePeriod - 1, to: 0, by: -1) {
            e1 = (k * inDouble[today]) + (one_minus_k * e1)
            today += 1
            e2 = (k * e1) + (one_minus_k * e2)
            e3 = (k * e2) + (one_minus_k * e3)
            e4 = (k * e3) + (one_minus_k * e4)
            tempReal += e4
        }
        var e5 = tempReal / Double(optInTimePeriod)
        tempReal = e5
        for _ in stride(from: optInTimePeriod - 1, to: 0, by: -1) {
            e1 = (k * inDouble[today]) + (one_minus_k * e1)
            today += 1
            e2 = (k * e1) + (one_minus_k * e2)
            e3 = (k * e2) + (one_minus_k * e3)
            e4 = (k * e3) + (one_minus_k * e4)
            e5 = (k * e4) + (one_minus_k * e5)
            tempReal += e5
        }
        var e6 = tempReal / Double(optInTimePeriod)
        while true {
            if today > startIndex {
                break
            }
            e1 = (k * inDouble[today]) + (one_minus_k * e1)
            today += 1
            e2 = (k * e1) + (one_minus_k * e2)
            e3 = (k * e2) + (one_minus_k * e3)
            e4 = (k * e3) + (one_minus_k * e4)
            e5 = (k * e4) + (one_minus_k * e5)
            e6 = (k * e5) + (one_minus_k * e6)
        }
        tempReal = optInVFactor * optInVFactor
        let c1 = -(tempReal * optInVFactor)
        let c2 = 3.0 * (tempReal - c1)
        let c3 = (-6.0 * tempReal) - (3.0 * (optInVFactor - c1))
        let c4 = ((1.0 + (3.0 * optInVFactor)) - c1) + (3.0 * tempReal)
        var outIdx = 0
        outDouble[outIdx] = (((c1 * e6) + (c2 * e5)) + (c3 * e4)) + (c4 * e3)
        outIdx += 1
        while true  {
            if today > endIndex {
                break
            }
            e1 = (k * inDouble[today]) + (one_minus_k * e1)
            today += 1
            e2 = (k * e1) + (one_minus_k * e2)
            e3 = (k * e2) + (one_minus_k * e3)
            e4 = (k * e3) + (one_minus_k * e4)
            e5 = (k * e4) + (one_minus_k * e5)
            e6 = (k * e5) + (one_minus_k * e6)
            outDouble[outIdx] = (((c1 * e6) + (c2 * e5)) + (c3 * e4)) + (c4 * e3)
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
                                optInVFactor: Double,
                                outElementStartIndex: inout Int,
                                outElementCount: inout Int,
                                outDouble: inout [Double]) -> TA_ReturnCode
    {
        var startIndex = startIndex
        var optInTimePeriod = optInTimePeriod
        var optInVFactor = optInVFactor
        
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
        if optInVFactor == -4E+37 {
            optInVFactor = self.optInVFactorDefault
        } else if optInVFactor < 0.0 || optInVFactor > 1.0 {
            return TA_ReturnCode.BadParam
        }
        let lookbackTotal = self.lookback(optInTimePeriod: optInTimePeriod, optInVFactor: optInVFactor)
        if startIndex <= lookbackTotal {
            startIndex = lookbackTotal
        }
        if startIndex > endIndex {
            outElementStartIndex = 0
            outElementCount = 0
            return TA_ReturnCode.Success
        }
        
        let allocationSize = self.allocationSize(startIndex: startIndex,
                                                 endIndex: endIndex,
                                                 optInTimePeriod: optInTimePeriod,
                                                 optInVFactor: optInVFactor)
        outDouble = [Double](repeating: Double.nan, count: allocationSize)
        
        outElementStartIndex = startIndex
        var today = startIndex - lookbackTotal
        let k = 2.0 / (Double(optInTimePeriod) + 1.0)
        let one_minus_k = 1.0 - k
        var tempReal = inCandle[today][inCandleInputType]
        today += 1
        for _ in stride(from: optInTimePeriod - 1, to: 0, by: -1) {
            tempReal += inCandle[today][inCandleInputType]
            today += 1
        }
        var e1 = tempReal / Double(optInTimePeriod)
        tempReal = e1
        for _ in stride(from: optInTimePeriod - 1, to: 0, by: -1) {
            e1 = (k * inCandle[today][inCandleInputType]) + (one_minus_k * e1)
            today += 1
            tempReal += e1
        }
        var e2 = tempReal / Double(optInTimePeriod)
        tempReal = e2
        for _ in stride(from: optInTimePeriod - 1, to: 0, by: -1) {
            e1 = (k * inCandle[today][inCandleInputType]) + (one_minus_k * e1)
            today += 1
            e2 = (k * e1) + (one_minus_k * e2)
            tempReal += e2
        }
        var e3 = tempReal / Double(optInTimePeriod)
        tempReal = e3
        for _ in stride(from: optInTimePeriod - 1, to: 0, by: -1) {
            e1 = (k * inCandle[today][inCandleInputType]) + (one_minus_k * e1)
            today += 1
            e2 = (k * e1) + (one_minus_k * e2)
            e3 = (k * e2) + (one_minus_k * e3)
            tempReal += e3
        }
        var e4 = tempReal / Double(optInTimePeriod)
        tempReal = e4
        for _ in stride(from: optInTimePeriod - 1, to: 0, by: -1) {
            e1 = (k * inCandle[today][inCandleInputType]) + (one_minus_k * e1)
            today += 1
            e2 = (k * e1) + (one_minus_k * e2)
            e3 = (k * e2) + (one_minus_k * e3)
            e4 = (k * e3) + (one_minus_k * e4)
            tempReal += e4
        }
        var e5 = tempReal / Double(optInTimePeriod)
        tempReal = e5
        for _ in stride(from: optInTimePeriod - 1, to: 0, by: -1) {
            e1 = (k * inCandle[today][inCandleInputType]) + (one_minus_k * e1)
            today += 1
            e2 = (k * e1) + (one_minus_k * e2)
            e3 = (k * e2) + (one_minus_k * e3)
            e4 = (k * e3) + (one_minus_k * e4)
            e5 = (k * e4) + (one_minus_k * e5)
            tempReal += e5
        }
        var e6 = tempReal / Double(optInTimePeriod)
        while true {
            if today > startIndex {
                break
            }
            e1 = (k * inCandle[today][inCandleInputType]) + (one_minus_k * e1)
            today += 1
            e2 = (k * e1) + (one_minus_k * e2)
            e3 = (k * e2) + (one_minus_k * e3)
            e4 = (k * e3) + (one_minus_k * e4)
            e5 = (k * e4) + (one_minus_k * e5)
            e6 = (k * e5) + (one_minus_k * e6)
        }
        tempReal = optInVFactor * optInVFactor
        let c1 = -(tempReal * optInVFactor)
        let c2 = 3.0 * (tempReal - c1)
        let c3 = (-6.0 * tempReal) - (3.0 * (optInVFactor - c1))
        let c4 = ((1.0 + (3.0 * optInVFactor)) - c1) + (3.0 * tempReal)
        var outIdx = 0
        outDouble[outIdx] = (((c1 * e6) + (c2 * e5)) + (c3 * e4)) + (c4 * e3)
        outIdx += 1
        while true  {
            if today > endIndex {
                break
            }
            e1 = (k * inCandle[today][inCandleInputType]) + (one_minus_k * e1)
            today += 1
            e2 = (k * e1) + (one_minus_k * e2)
            e3 = (k * e2) + (one_minus_k * e3)
            e4 = (k * e3) + (one_minus_k * e4)
            e5 = (k * e4) + (one_minus_k * e5)
            e6 = (k * e5) + (one_minus_k * e6)
            outDouble[outIdx] = (((c1 * e6) + (c2 * e5)) + (c3 * e4)) + (c4 * e3)
            outIdx += 1
        }
        
        outElementCount = outIdx
        
        return TA_ReturnCode.Success
    }
    
    public class func lookback(optInTimePeriod: Int,
                               optInVFactor: Double) -> Int
    {
        var optInTimePeriod = optInTimePeriod
        var optInVFactor = optInVFactor
        
        if optInTimePeriod == Int.min {
            optInTimePeriod = self.optInTimePeriodDefault
        } else if optInTimePeriod < 2 || optInTimePeriod > 100000 {
            return -1
        }
        if optInVFactor == -4e+37 {
            optInVFactor = self.optInVFactorDefault
        } else if optInVFactor < 0.0 || optInVFactor > 1.0 {
            return -1
        }
        
        return (((optInTimePeriod - 1) * 6) + TA_Core.sharedInstance.globals.unstablePeriod[TA_FunctionUnstableId.T3.rawValue])
    }
    
    public class func allocationSize(startIndex: Int,
                                     endIndex: Int,
                                     optInTimePeriod: Int,
                                     optInVFactor: Double) -> Int
    {
        let lookback = self.lookback(optInTimePeriod: optInTimePeriod,
                                     optInVFactor: optInVFactor)
        let temp = max(lookback, startIndex)
        var allocationSize = 0
        if temp > endIndex {
        } else {
            allocationSize = endIndex - temp + 1
        }
        
        return allocationSize
    }
}




