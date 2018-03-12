//
//  TA_MacdExt.swift
//  ta-lib-swift
//
//  Created by Pat Sluth on 2017-09-18.
//  Copyright © 2017 patsluth. All rights reserved.
//

import Foundation





// TODO: INDEX OUT OF BOUNDS!!
// MACDEXT - MACD with controllable MA type
public class TA_MacdExt
{
    public class func calculate(startIndex: Int,
                                endIndex: Int,
                                inDouble: [Double],
                                optInFastPeriod: Int,
                                optInFastMovingAverageType: TA_MovingAverageType,
                                optInSlowPeriod: Int,
                                optInSlowMovingAverageType: TA_MovingAverageType,
                                optInSignalPeriod: Int,
                                optInSignalMovingAverageType: TA_MovingAverageType,
                                outElementStartIndex: inout Int,
                                outElementCount: inout Int,
                                outMACD: inout [Double],
                                outMACDSignal: inout [Double],
                                outMACDHist: inout [Double]) -> TA_ReturnCode
    {
        var startIndex = startIndex
        var optInFastPeriod = optInFastPeriod
        var optInFastMovingAverageType = optInFastMovingAverageType
        var optInSlowPeriod = optInSlowPeriod
        var optInSlowMovingAverageType = optInSlowMovingAverageType
        var optInSignalPeriod = optInSignalPeriod
        
        outElementStartIndex = 0
        outElementCount = 0
        
        if startIndex < 0 {
            return TA_ReturnCode.OutOfRangeStartIndex
        }
        if endIndex < 0 || endIndex < startIndex {
            return TA_ReturnCode.OutOfRangeStartIndex
        }
        if optInFastPeriod == Int.min {
            optInFastPeriod = TA_Macd.optInFastPeriodDefault
        } else if optInFastPeriod < 2 || optInFastPeriod > 100000 {
            return TA_ReturnCode.BadParam
        }
        if optInSlowPeriod == Int.min {
            optInSlowPeriod = TA_Macd.optInSlowPeriodDefault
        } else if optInSlowPeriod < 2 || optInSlowPeriod > 100000 {
            return TA_ReturnCode.BadParam
        }
        if optInSignalPeriod == Int.min {
            optInSignalPeriod = TA_Macd.optInSignalPeriodDefault
        } else if optInSignalPeriod < 1 || optInSignalPeriod > 100000 {
            return TA_ReturnCode.BadParam
        }
        
        var tempInteger = 0
        var outElementStartIndex1 = 0
        var outElementCount1 = 0
        var outElementStartIndex2 = 0
        var outElementCount2 = 0
        if optInSlowPeriod < optInFastPeriod {
            tempInteger = optInSlowPeriod
            optInSlowPeriod = optInFastPeriod
            optInFastPeriod = tempInteger
            let tempMAType = optInSlowMovingAverageType
            optInSlowMovingAverageType = optInFastMovingAverageType
            optInFastMovingAverageType = tempMAType
        }
        var lookbackLargest = TA_MovingAverage.lookback(optInTimePeriod: optInFastPeriod,
                                                        optInMovingAverageType: optInFastMovingAverageType)
        tempInteger = TA_MovingAverage.lookback(optInTimePeriod: optInSlowPeriod,
                                                optInMovingAverageType: optInSlowMovingAverageType)
        if tempInteger > lookbackLargest {
            lookbackLargest = tempInteger
        }
        let lookbackSignal = TA_MovingAverage.lookback(optInTimePeriod: optInFastPeriod,
                                                       optInMovingAverageType: optInFastMovingAverageType)
        let lookbackTotal = lookbackSignal + lookbackLargest
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
                                                 optInFastPeriod: optInFastPeriod,
                                                 optInFastMovingAverageType: optInFastMovingAverageType,
                                                 optInSlowPeriod: optInSlowPeriod,
                                                 optInSlowMovingAverageType: optInSlowMovingAverageType,
                                                 optInSignalPeriod: optInSignalPeriod,
                                                 optInSignalMovingAverageType: optInSignalMovingAverageType)
        outMACD = [Double](repeating: Double.nan, count: allocationSize)
        outMACDSignal = [Double](repeating: Double.nan, count: allocationSize)
        outMACDHist = [Double](repeating: Double.nan, count: allocationSize)
        
        tempInteger = ((endIndex - startIndex) + 1) + lookbackSignal
        if tempInteger < 0 {
            outElementStartIndex = 0
            outElementCount = 0
            return TA_ReturnCode.AllocErr
        }
        var fastMABuffer = [Double](repeating: Double.nan, count: tempInteger)
        var slowMABuffer = [Double](repeating: Double.nan, count: tempInteger)
        tempInteger = startIndex - lookbackSignal
        var returnCode = TA_MovingAverage.calculate(startIndex: tempInteger,
                                                    endIndex: endIndex,
                                                    inDouble: inDouble,
                                                    optInTimePeriod: optInSlowPeriod,
                                                    optInMovingAverageType: optInSlowMovingAverageType,
                                                    outElementStartIndex: &outElementStartIndex1,
                                                    outElementCount: &outElementCount1,
                                                    outDouble: &slowMABuffer)
        if returnCode != TA_ReturnCode.Success {
            outElementStartIndex = 0
            outElementCount = 0
            return returnCode
        }
        returnCode = TA_MovingAverage.calculate(startIndex: tempInteger,
                                                    endIndex: endIndex,
                                                    inDouble: inDouble,
                                                    optInTimePeriod: optInFastPeriod,
                                                    optInMovingAverageType: optInFastMovingAverageType,
                                                    outElementStartIndex: &outElementStartIndex2,
                                                    outElementCount: &outElementCount2,
                                                    outDouble: &fastMABuffer)
        if returnCode != TA_ReturnCode.Success {
            outElementStartIndex = 0
            outElementCount = 0
            return returnCode
        }
        if outElementStartIndex1 != tempInteger ||
            outElementStartIndex2 != tempInteger ||
            outElementCount1 != outElementCount2 ||
            outElementCount1 != (((endIndex - startIndex) + 1) + lookbackSignal) {
            outElementStartIndex = 0
            outElementCount = 0
            return TA_ReturnCode.InternalError
        }
        for i in stride(from: 0, to: outElementCount1, by: 1) {
            fastMABuffer[i] -= slowMABuffer[i]
        }
        TA_ArrayUtils.Copy(sourceArray: fastMABuffer,
                           sourceIndex: lookbackSignal,
                           destinationArray: &outMACD,
                           destinationIndex: 0,
                           length: (endIndex - startIndex) + 1)
        returnCode = TA_MovingAverage.calculate(startIndex: 0,
                                                endIndex: outElementCount1 - 1,
                                                inDouble: fastMABuffer,
                                                optInTimePeriod: optInSignalPeriod,
                                                optInMovingAverageType: optInSignalMovingAverageType,
                                                outElementStartIndex: &outElementStartIndex2,
                                                outElementCount: &outElementCount2,
                                                outDouble: &outMACDSignal)
        if returnCode != TA_ReturnCode.Success {
            outElementStartIndex = 0
            outElementCount = 0
            return returnCode
        }
        if outElementCount1 != outElementCount2 {
            outElementStartIndex = 0
            outElementCount = 0
            return TA_ReturnCode.InternalError
        }
        for i in stride(from: 0, to: outElementCount2, by: 1) {
            outMACDHist[i] = outMACD[i] - outMACDSignal[i]
        }
        
        outElementStartIndex = startIndex
        outElementCount = outElementCount2
        
        return TA_ReturnCode.Success
    }
    
    public class func calculate(startIndex: Int,
                                endIndex: Int,
                                inCandle: [TA_Candle],
                                inCandleInputType: TA_CandleInputType,
                                optInFastPeriod: Int,
                                optInFastMovingAverageType: TA_MovingAverageType,
                                optInSlowPeriod: Int,
                                optInSlowMovingAverageType: TA_MovingAverageType,
                                optInSignalPeriod: Int,
                                optInSignalMovingAverageType: TA_MovingAverageType,
                                outElementStartIndex: inout Int,
                                outElementCount: inout Int,
                                outMACD: inout [Double],
                                outMACDSignal: inout [Double],
                                outMACDHist: inout [Double]) -> TA_ReturnCode
    {
        var startIndex = startIndex
        var optInFastPeriod = optInFastPeriod
        var optInFastMovingAverageType = optInFastMovingAverageType
        var optInSlowPeriod = optInSlowPeriod
        var optInSlowMovingAverageType = optInSlowMovingAverageType
        var optInSignalPeriod = optInSignalPeriod
        
        outElementStartIndex = 0
        outElementCount = 0
        
        if startIndex < 0 {
            return TA_ReturnCode.OutOfRangeStartIndex
        }
        if endIndex < 0 || endIndex < startIndex {
            return TA_ReturnCode.OutOfRangeStartIndex
        }
        if optInFastPeriod == Int.min {
            optInFastPeriod = TA_Macd.optInFastPeriodDefault
        } else if optInFastPeriod < 2 || optInFastPeriod > 100000 {
            return TA_ReturnCode.BadParam
        }
        if optInSlowPeriod == Int.min {
            optInSlowPeriod = TA_Macd.optInSlowPeriodDefault
        } else if optInSlowPeriod < 2 || optInSlowPeriod > 100000 {
            return TA_ReturnCode.BadParam
        }
        if optInSignalPeriod == Int.min {
            optInSignalPeriod = TA_Macd.optInSignalPeriodDefault
        } else if optInSignalPeriod < 1 || optInSignalPeriod > 100000 {
            return TA_ReturnCode.BadParam
        }
        
        var tempInteger = 0
        var outElementStartIndex1 = 0
        var outElementCount1 = 0
        var outElementStartIndex2 = 0
        var outElementCount2 = 0
        if optInSlowPeriod < optInFastPeriod {
            tempInteger = optInSlowPeriod
            optInSlowPeriod = optInFastPeriod
            optInFastPeriod = tempInteger
            let tempMAType = optInSlowMovingAverageType
            optInSlowMovingAverageType = optInFastMovingAverageType
            optInFastMovingAverageType = tempMAType
        }
        var lookbackLargest = TA_MovingAverage.lookback(optInTimePeriod: optInFastPeriod,
                                                        optInMovingAverageType: optInFastMovingAverageType)
        tempInteger = TA_MovingAverage.lookback(optInTimePeriod: optInSlowPeriod,
                                                optInMovingAverageType: optInSlowMovingAverageType)
        if tempInteger > lookbackLargest {
            lookbackLargest = tempInteger
        }
        let lookbackSignal = TA_MovingAverage.lookback(optInTimePeriod: optInFastPeriod,
                                                       optInMovingAverageType: optInFastMovingAverageType)
        let lookbackTotal = lookbackSignal + lookbackLargest
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
                                                 optInFastPeriod: optInFastPeriod,
                                                 optInFastMovingAverageType: optInFastMovingAverageType,
                                                 optInSlowPeriod: optInSlowPeriod,
                                                 optInSlowMovingAverageType: optInSlowMovingAverageType,
                                                 optInSignalPeriod: optInSignalPeriod,
                                                 optInSignalMovingAverageType: optInSignalMovingAverageType)
        outMACD = [Double](repeating: Double.nan, count: allocationSize)
        outMACDSignal = [Double](repeating: Double.nan, count: allocationSize)
        outMACDHist = [Double](repeating: Double.nan, count: allocationSize)
        
        tempInteger = ((endIndex - startIndex) + 1) + lookbackSignal
        if tempInteger < 0 {
            outElementStartIndex = 0
            outElementCount = 0
            return TA_ReturnCode.AllocErr
        }
        var fastMABuffer = [Double](repeating: Double.nan, count: tempInteger)
        var slowMABuffer = [Double](repeating: Double.nan, count: tempInteger)
        tempInteger = startIndex - lookbackSignal
        var returnCode = TA_MovingAverage.calculate(startIndex: tempInteger,
                                                    endIndex: endIndex,
                                                    inCandle: inCandle,
                                                    inCandleInputType: inCandleInputType,
                                                    optInTimePeriod: optInSlowPeriod,
                                                    optInMovingAverageType: optInSlowMovingAverageType,
                                                    outElementStartIndex: &outElementStartIndex1,
                                                    outElementCount: &outElementCount1,
                                                    outDouble: &slowMABuffer)
        if returnCode != TA_ReturnCode.Success {
            outElementStartIndex = 0
            outElementCount = 0
            return returnCode
        }
        returnCode = TA_MovingAverage.calculate(startIndex: tempInteger,
                                                endIndex: endIndex,
                                                inCandle: inCandle,
                                                inCandleInputType: inCandleInputType,
                                                optInTimePeriod: optInFastPeriod,
                                                optInMovingAverageType: optInFastMovingAverageType,
                                                outElementStartIndex: &outElementStartIndex2,
                                                outElementCount: &outElementCount2,
                                                outDouble: &fastMABuffer)
        if returnCode != TA_ReturnCode.Success {
            outElementStartIndex = 0
            outElementCount = 0
            return returnCode
        }
        if outElementStartIndex1 != tempInteger ||
            outElementStartIndex2 != tempInteger ||
            outElementCount1 != outElementCount2 ||
            outElementCount1 != (((endIndex - startIndex) + 1) + lookbackSignal) {
            outElementStartIndex = 0
            outElementCount = 0
            return TA_ReturnCode.InternalError
        }
        for i in stride(from: 0, to: outElementCount1, by: 1) {
            fastMABuffer[i] -= slowMABuffer[i]
        }
        TA_ArrayUtils.Copy(sourceArray: fastMABuffer,
                           sourceIndex: lookbackSignal,
                           destinationArray: &outMACD,
                           destinationIndex: 0,
                           length: (endIndex - startIndex) + 1)
        returnCode = TA_MovingAverage.calculate(startIndex: 0,
                                                endIndex: outElementCount1 - 1,
                                                inDouble: fastMABuffer,
                                                optInTimePeriod: optInSignalPeriod,
                                                optInMovingAverageType: optInSignalMovingAverageType,
                                                outElementStartIndex: &outElementStartIndex2,
                                                outElementCount: &outElementCount2,
                                                outDouble: &outMACDSignal)
        if returnCode != TA_ReturnCode.Success {
            outElementStartIndex = 0
            outElementCount = 0
            return returnCode
        }
        if outElementCount1 != outElementCount2 {
            outElementStartIndex = 0
            outElementCount = 0
            return TA_ReturnCode.InternalError
        }
        for i in stride(from: 0, to: outElementCount2, by: 1) {
            outMACDHist[i] = outMACD[i] - outMACDSignal[i]
        }
        
        outElementStartIndex = startIndex
        outElementCount = outElementCount2
        
        return TA_ReturnCode.Success
    }
    
    public class func lookback(optInFastPeriod: Int,
                               optInFastMovingAverageType: TA_MovingAverageType,
                               optInSlowPeriod: Int,
                               optInSlowMovingAverageType: TA_MovingAverageType,
                               optInSignalPeriod: Int,
                               optInSignalMovingAverageType: TA_MovingAverageType) -> Int
    {
        var optInFastPeriod = optInFastPeriod
        var optInSlowPeriod = optInSlowPeriod
        var optInSignalPeriod = optInSignalPeriod
        
        if optInFastPeriod == Int.min {
            optInFastPeriod = TA_Macd.optInFastPeriodDefault
        } else if optInFastPeriod < 2 || optInFastPeriod > 100000 {
            return -1
        }
        if optInSlowPeriod == Int.min {
            optInSlowPeriod = TA_Macd.optInSlowPeriodDefault
        } else if optInSlowPeriod < 2 || optInSlowPeriod > 100000 {
            return -1
        }
        if optInSignalPeriod == Int.min {
            optInSignalPeriod = TA_Macd.optInSignalPeriodDefault
        } else if optInSignalPeriod < 1 || optInSignalPeriod > 100000 {
            return -1
        }
        var lookbackLargest = TA_MovingAverage.lookback(optInTimePeriod: optInFastPeriod,
                                                        optInMovingAverageType: optInFastMovingAverageType)
        let tempInteger = TA_MovingAverage.lookback(optInTimePeriod: optInSlowPeriod,
                                                    optInMovingAverageType: optInSlowMovingAverageType)
        if tempInteger > lookbackLargest {
            lookbackLargest = tempInteger
        }
        
        return (lookbackLargest + TA_MovingAverage.lookback(optInTimePeriod: optInSignalPeriod,
                                                            optInMovingAverageType: optInSignalMovingAverageType))
    }
    
    public class func allocationSize(startIndex: Int,
                                     endIndex: Int,
                                     optInFastPeriod: Int,
                                     optInFastMovingAverageType: TA_MovingAverageType,
                                     optInSlowPeriod: Int,
                                     optInSlowMovingAverageType: TA_MovingAverageType,
                                     optInSignalPeriod: Int,
                                     optInSignalMovingAverageType: TA_MovingAverageType) -> Int
    {
        let lookback = self.lookback(optInFastPeriod: optInFastPeriod,
                                     optInFastMovingAverageType: optInFastMovingAverageType,
                                     optInSlowPeriod: optInSlowPeriod,
                                     optInSlowMovingAverageType: optInSlowMovingAverageType,
                                     optInSignalPeriod: optInSignalPeriod,
                                     optInSignalMovingAverageType: optInSignalMovingAverageType)
        let temp = max(lookback, startIndex)
        var allocationSize = 0
        if temp > endIndex {
        } else {
            allocationSize = endIndex - temp + 1
        }
        
        return allocationSize
    }
}




