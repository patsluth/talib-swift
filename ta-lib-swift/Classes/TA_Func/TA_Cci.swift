//
//  TA_Cci.swift
//  ta-lib-swift
//
//  Created by Pat Sluth on 2017-09-18.
//  Copyright © 2017 patsluth. All rights reserved.
//

import Foundation





// CCI - Commodity Channel Index
public class TA_Cci
{
    public static let optInTimePeriodDefault = 14
    
    public class func calculate(startIndex: Int,
                                endIndex: Int,
                                inHigh: [Double],
                                inLow: [Double],
                                inClose: [Double],
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
        
        var circBuffer_Idx = 0
        var maxIdx_circBuffer = 29
        var circBuffer = [Double](repeating: 0.0, count: optInTimePeriod)
        maxIdx_circBuffer = optInTimePeriod - 1
        var i = startIndex - lookbackTotal
        if optInTimePeriod > 1 {
            while i < startIndex {
                circBuffer[circBuffer_Idx] = ((inHigh[i] + inLow[i]) + inClose[i]) / 3.0
                i += 1
                circBuffer_Idx += 1
                if circBuffer_Idx > maxIdx_circBuffer {
                    circBuffer_Idx = 0
                }
            }
        }
        var outIdx = 0
        repeat {
            let lastValue = ((inHigh[i] + inLow[i]) + inClose[i]) / 3.0
            circBuffer[circBuffer_Idx] = lastValue
            var theAverage = 0.0
            var j = 0
            while j < optInTimePeriod {
                theAverage += circBuffer[j]
                j += 1
            }
            theAverage /= Double(optInTimePeriod)
            var tempReal2 = 0.0
            for k in stride(from: 0, to: optInTimePeriod, by: 1) {
                tempReal2 += fabs(circBuffer[k] - theAverage)
            }
            let tempReal = lastValue - theAverage
            if tempReal != 0.0 && tempReal2 != 0.0 {
                outDouble[outIdx] = tempReal / (0.015 * (tempReal2 / Double(optInTimePeriod)))
            } else {
                outDouble[outIdx] = 0.0
            }
            outIdx += 1
            circBuffer_Idx += 1
            if circBuffer_Idx > maxIdx_circBuffer {
                circBuffer_Idx = 0
            }
            i += 1
        } while i <= endIndex
        
        outElementStartIndex = startIndex
        outElementCount = outIdx
        
        return TA_ReturnCode.Success
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
        
        var circBuffer_Idx = 0
        var maxIdx_circBuffer = 29
        var circBuffer = [Double](repeating: 0.0, count: optInTimePeriod)
        maxIdx_circBuffer = optInTimePeriod - 1
        var i = startIndex - lookbackTotal
        if optInTimePeriod > 1 {
            while i < startIndex {
                circBuffer[circBuffer_Idx] = ((inCandle[i][TA_CandleInputType.High] + inCandle[i][TA_CandleInputType.Low]) + inCandle[i][TA_CandleInputType.Close]) / 3.0
                i += 1
                circBuffer_Idx += 1
                if circBuffer_Idx > maxIdx_circBuffer {
                    circBuffer_Idx = 0
                }
            }
        }
        var outIdx = 0
        repeat {
            let lastValue = ((inCandle[i][TA_CandleInputType.High] + inCandle[i][TA_CandleInputType.Low]) + inCandle[i][TA_CandleInputType.Close]) / 3.0
            circBuffer[circBuffer_Idx] = lastValue
            var theAverage = 0.0
            var j = 0
            while j < optInTimePeriod {
                theAverage += circBuffer[j]
                j += 1
            }
            theAverage /= Double(optInTimePeriod)
            var tempReal2 = 0.0
            for k in stride(from: 0, to: optInTimePeriod, by: 1) {
                tempReal2 += fabs(circBuffer[k] - theAverage)
            }
            let tempReal = lastValue - theAverage
            if tempReal != 0.0 && tempReal2 != 0.0 {
                outDouble[outIdx] = tempReal / (0.015 * (tempReal2 / Double(optInTimePeriod)))
            } else {
                outDouble[outIdx] = 0.0
            }
            outIdx += 1
            circBuffer_Idx += 1
            if circBuffer_Idx > maxIdx_circBuffer {
                circBuffer_Idx = 0
            }
            i += 1
        } while i <= endIndex
        
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




