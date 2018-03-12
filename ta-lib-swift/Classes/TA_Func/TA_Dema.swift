//
//  TA_Dema.swift
//  ta-lib-swift
//
//  Created by Pat Sluth on 2017-09-18.
//  Copyright © 2017 patsluth. All rights reserved.
//

import Foundation





// DEMA - Double Exponential Moving Average
public class TA_Dema
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
        let lookbackEMA = TA_Ema.lookback(optInTimePeriod: optInTimePeriod)
        let lookbackTotal = lookbackEMA * 2
        if startIndex < lookbackTotal {
            startIndex = lookbackTotal
        }
        
        let allocationSize = self.allocationSize(startIndex: startIndex,
                                                 endIndex: endIndex,
                                                 optInTimePeriod: optInTimePeriod)
        outDouble = [Double](repeating: Double.nan, count: allocationSize)
        
        if startIndex <= endIndex {
            var firstEMA: [Double]
            var firstEMAElementCount = 0
            var secondEMAElementCount = 0
            var secondEMAElementStartIndex = 0
            var firstEMAElementStartIndex = 0
            if inDouble == outDouble {
                firstEMA = outDouble
            } else {
                let tempInt = (lookbackTotal + (endIndex - startIndex)) + 1
                if tempInt < 0 {
                    return TA_ReturnCode.AllocErr
                }
                firstEMA = [Double](repeating: 0.0, count: tempInt)
            }
            let k = 2.0 / Double(optInTimePeriod + 1)
            var returnCode = TA_Core.sharedInstance.TA_INT_EMA(startIndex: startIndex - lookbackEMA,
                                                               endIndex: endIndex,
                                                               inDouble: inDouble,
                                                               optInTimePeriod: optInTimePeriod,
                                                               optInK: k,
                                                               outElementStartIndex: &firstEMAElementStartIndex,
                                                               outElementCount: &firstEMAElementCount,
                                                               outDouble: &firstEMA)
            if returnCode != TA_ReturnCode.Success || firstEMAElementCount == 0 {
                return returnCode
            }
            if firstEMAElementCount < 0 {
                return TA_ReturnCode.AllocErr
            }
            var secondEMA = [Double](repeating: 0.0, count: firstEMAElementCount)
            returnCode = TA_Core.sharedInstance.TA_INT_EMA(startIndex: 0,
                                                           endIndex: firstEMAElementCount - 1,
                                                           inDouble: firstEMA,
                                                           optInTimePeriod: optInTimePeriod,
                                                           optInK: k,
                                                           outElementStartIndex: &secondEMAElementStartIndex,
                                                           outElementCount: &secondEMAElementCount,
                                                           outDouble: &secondEMA)
            if returnCode != TA_ReturnCode.Success || secondEMAElementCount == 0 {
                return returnCode
            }
            var firstEMAIdx = secondEMAElementStartIndex
            var outIdx = 0
            while true {
                if outIdx >= secondEMAElementCount {
                    break
                }
                outDouble[outIdx] = (2.0 * firstEMA[firstEMAIdx]) - secondEMA[outIdx]
                firstEMAIdx += 1
                outIdx += 1
            }
            outElementStartIndex = firstEMAElementStartIndex + secondEMAElementStartIndex
            outElementCount = outIdx
        }
        
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
        let lookbackEMA = TA_Ema.lookback(optInTimePeriod: optInTimePeriod)
        let lookbackTotal = lookbackEMA * 2
        if startIndex < lookbackTotal {
            startIndex = lookbackTotal
        }
        
        let allocationSize = self.allocationSize(startIndex: startIndex,
                                                 endIndex: endIndex,
                                                 optInTimePeriod: optInTimePeriod)
        outDouble = [Double](repeating: Double.nan, count: allocationSize)
        
        if startIndex <= endIndex {
            var firstEMA: [Double]
            var firstEMAElementCount = 0
            var secondEMAElementCount = 0
            var secondEMAElementStartIndex = 0
            var firstEMAElementStartIndex = 0
            // TODO: TEST
//            if inCandle == outDouble {
//                firstEMA = outDouble
//            } else {
                let tempInt = (lookbackTotal + (endIndex - startIndex)) + 1
                if tempInt < 0 {
                    return TA_ReturnCode.AllocErr
                }
                firstEMA = [Double](repeating: 0.0, count: tempInt)
//            }
            let k = 2.0 / Double(optInTimePeriod + 1)
            var returnCode = TA_Core.sharedInstance.TA_INT_EMA(startIndex: startIndex - lookbackEMA,
                                                               endIndex: endIndex,
                                                               inCandle: inCandle,
                                                               inCandleInputType: inCandleInputType,
                                                               optInTimePeriod: optInTimePeriod,
                                                               optInK: k,
                                                               outElementStartIndex: &firstEMAElementStartIndex,
                                                               outElementCount: &firstEMAElementCount,
                                                               outDouble: &firstEMA)
            if returnCode != TA_ReturnCode.Success || firstEMAElementCount == 0 {
                return returnCode
            }
            if firstEMAElementCount < 0 {
                return TA_ReturnCode.AllocErr
            }
            var secondEMA = [Double](repeating: 0.0, count: firstEMAElementCount)
            returnCode = TA_Core.sharedInstance.TA_INT_EMA(startIndex: 0,
                                                           endIndex: firstEMAElementCount - 1,
                                                           inDouble: firstEMA,
                                                           optInTimePeriod: optInTimePeriod,
                                                           optInK: k,
                                                           outElementStartIndex: &secondEMAElementStartIndex,
                                                           outElementCount: &secondEMAElementCount,
                                                           outDouble: &secondEMA)
            if returnCode != TA_ReturnCode.Success || secondEMAElementCount == 0 {
                return returnCode
            }
            var firstEMAIdx = secondEMAElementStartIndex
            var outIdx = 0
            while true {
                if outIdx >= secondEMAElementCount {
                    break
                }
                outDouble[outIdx] = (2.0 * firstEMA[firstEMAIdx]) - secondEMA[outIdx]
                firstEMAIdx += 1
                outIdx += 1
            }
            outElementStartIndex = firstEMAElementStartIndex + secondEMAElementStartIndex
            outElementCount = outIdx
        }
        
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
        
        return (TA_Ema.lookback(optInTimePeriod: optInTimePeriod) * 2)
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




