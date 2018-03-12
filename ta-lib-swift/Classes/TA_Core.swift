//
//  TA_Core.swift
//  ta-lib-swift
//
//  Created by Pat Sluth on 2017-09-18.
//  Copyright © 2017 patsluth. All rights reserved.
//

import Foundation




// TODO: DELETE
public typealias TAFuncSuccess = (_ outDouble: [Double]) -> Void
public typealias TAFuncError = (_ returnCode: TA_ReturnCode) -> Void





@objc public final class TA_Core: NSObject
{
    static let sharedInstance = TA_Core()
    
    let globals: GlobalsType = GlobalsType()
    
    
    
    
    fileprivate override init()
    {
        super.init()
    }
    
    //    func getCompatibility() -> TA_Compatibility
    //    {
    //        return self.globals.compatibility
    //    }
    //
    //    func getUnstablePeriodFor(id: TA_FunctionUnstableId) -> Int
    //    {
    //        if id.rawValue >= TA_FunctionUnstableId.FuncUnstAll.rawValue {
    //            return 0
    //        }
    //        return self.globals.unstablePeriod[id.rawValue]
    //    }
    //
    //    func setCompatibility(compatibility: Compatibility) -> TA_ReturnCode
    //    {
    //        self.globals.compatibility = compatibility
    //        return TA_ReturnCode.Success
    //    }
    //
    //    func setUnstablePeriod(id: TA_FunctionUnstableId, unstablePeriod: Int) -> TA_ReturnCode
    //    {
    //        if id.rawValue > TA_FunctionUnstableId.FuncUnstAll.rawValue {
    //            return TA_ReturnCode.BadParam;
    //        }
    //        if id != TA_FunctionUnstableId.FuncUnstAll {
    //            self.globals.unstablePeriod[id.rawValue] = unstablePeriod
    //        } else {
    //            for i in (0..<0x17) {
    //                self.globals.unstablePeriod[i] = unstablePeriod
    //            }
    //        }
    //
    //        return TA_ReturnCode.Success
    //    }
    
    internal func TA_INT_EMA(startIndex: Int,
                             endIndex: Int,
                             inDouble: [Double],
                             optInTimePeriod: Int,
                             optInK: Double,
                             outElementStartIndex: inout Int,
                             outElementCount: inout Int,
                             outDouble: inout [Double]) -> TA_ReturnCode
    {
        var startIndex = startIndex
        var today: Int
        var prevMA: Double
        let lookbackTotal = TA_Ema.lookback(optInTimePeriod: optInTimePeriod)
        
        if startIndex < lookbackTotal {
            startIndex = lookbackTotal
        }
        if startIndex > endIndex {
            outElementStartIndex = 0
            outElementCount = 0
            return TA_ReturnCode.Success
        }
        outElementStartIndex = startIndex
        if TA_Core.sharedInstance.globals.compatibility == TA_Compatibility.Default {
            today = startIndex - lookbackTotal
            var i = optInTimePeriod
            var tempReal = 0.0
            while i - 1 > 0 {
                i -= 1
                tempReal += inDouble[today]
                today += 1
            }
            prevMA = tempReal / Double(optInTimePeriod)
        } else {
            prevMA = inDouble[0]
            today = 1
        }
        while today <= startIndex {
            prevMA = ((inDouble[today] - prevMA) * optInK) + prevMA
            today += 1
        }
        outDouble[0] = prevMA
        var outIndex = 1
        while today <= endIndex {
            prevMA = ((inDouble[today] - prevMA) * optInK) + prevMA
            today += 1
            outDouble[outIndex] = prevMA
            outIndex += 1
        }
        outElementCount = outIndex
        
        return TA_ReturnCode.Success
    }
    
    internal func TA_INT_EMA(startIndex: Int,
                             endIndex: Int,
                             inCandle: [TA_Candle],
                             inCandleInputType: TA_CandleInputType,
                             optInTimePeriod: Int,
                             optInK: Double,
                             outElementStartIndex: inout Int,
                             outElementCount: inout Int,
                             outDouble: inout [Double]) -> TA_ReturnCode
    {
        var startIndex = startIndex
        var today: Int
        var prevMA: Double
        let lookbackTotal = TA_Ema.lookback(optInTimePeriod: optInTimePeriod)
        
        if startIndex < lookbackTotal {
            startIndex = lookbackTotal
        }
        if startIndex > endIndex {
            outElementStartIndex = 0
            outElementCount = 0
            return TA_ReturnCode.Success
        }
        outElementStartIndex = startIndex
        if TA_Core.sharedInstance.globals.compatibility == TA_Compatibility.Default {
            today = startIndex - lookbackTotal
            var i = optInTimePeriod
            var tempReal = 0.0
            while i - 1 > 0 {
                i -= 1
                tempReal += inCandle[today][inCandleInputType]
                today += 1
            }
            prevMA = tempReal / Double(optInTimePeriod)
        } else {
            prevMA = inCandle[0][inCandleInputType]
            today = 1
        }
        while today <= startIndex {
            prevMA = ((inCandle[today][inCandleInputType] - prevMA) * optInK) + prevMA
            today += 1
        }
        outDouble[0] = prevMA
        var outIndex = 1
        while today <= endIndex {
            prevMA = ((inCandle[today][inCandleInputType] - prevMA) * optInK) + prevMA
            today += 1
            outDouble[outIndex] = prevMA
            outIndex += 1
        }
        outElementCount = outIndex
        
        return TA_ReturnCode.Success
    }
    
    internal func TA_INT_SMA(startIndex: Int,
                             endIndex: Int,
                             inDouble: [Double],
                             optInTimePeriod: Int,
                             outElementStartIndex: inout Int,
                             outElementCount: inout Int,
                             outDouble: inout [Double]) -> TA_ReturnCode
    {
        var startIndex = startIndex
        
        let lookbackTotal = optInTimePeriod - 1
        if startIndex < lookbackTotal {
            startIndex = lookbackTotal
        }
        if startIndex > endIndex {
            outElementStartIndex = 0
            outElementCount = 0
            return TA_ReturnCode.Success
        }
        var periodTotal = 0.0
        var trailingIdx = startIndex - lookbackTotal
        var i = trailingIdx
        if optInTimePeriod > 1 {
            while i < startIndex {
                periodTotal += inDouble[i]
                i += 1
            }
        }
        var outIdx = 0
        repeat {
            periodTotal += inDouble[i]
            i += 1
            let tempReal = periodTotal
            periodTotal -= inDouble[trailingIdx]
            trailingIdx += 1
            outDouble[outIdx] = tempReal / Double(optInTimePeriod)
            outIdx += 1
        } while i <= endIndex
        outElementCount = outIdx
        outElementStartIndex = startIndex
        
        return TA_ReturnCode.Success
    }
    
    internal func TA_INT_SMA(startIndex: Int,
                             endIndex: Int,
                             inCandle: [TA_Candle],
                             inCandleInputType: TA_CandleInputType,
                             optInTimePeriod: Int,
                             outElementStartIndex: inout Int,
                             outElementCount: inout Int,
                             outDouble: inout [Double]) -> TA_ReturnCode
    {
        var startIndex = startIndex
        
        let lookbackTotal = optInTimePeriod - 1
        if startIndex < lookbackTotal {
            startIndex = lookbackTotal
        }
        if startIndex > endIndex {
            outElementStartIndex = 0
            outElementCount = 0
            return TA_ReturnCode.Success
        }
        var periodTotal = 0.0
        var trailingIdx = startIndex - lookbackTotal
        var i = trailingIdx
        if optInTimePeriod > 1 {
            while i < startIndex {
                periodTotal += inCandle[i][inCandleInputType]
                i += 1
            }
        }
        var outIdx = 0
        repeat {
            periodTotal += inCandle[i][inCandleInputType]
            i += 1
            let tempReal = periodTotal
            periodTotal -= inCandle[trailingIdx][inCandleInputType]
            trailingIdx += 1
            outDouble[outIdx] = tempReal / Double(optInTimePeriod)
            outIdx += 1
        } while i <= endIndex
        outElementCount = outIdx
        outElementStartIndex = startIndex
        
        return TA_ReturnCode.Success
    }
    
    internal func TA_INT_stddev_using_precalc_ma(inDouble: [Double],
                                                 inMovingAverage: [Double],
                                                 inMovingAverageElementStartIndex: Int,
                                                 inMovingAverageElementCount: Int,
                                                 optInTimePeriod: Int,
                                                 outDouble: inout [Double])
    {
        var tempReal: Double
        var startSum = (inMovingAverageElementStartIndex + 1) - optInTimePeriod
        var endSum = inMovingAverageElementStartIndex
        var periodTotal2 = 0.0
        for outIdx in (startSum..<endSum) {
            tempReal = inDouble[outIdx]
            tempReal *= tempReal
            periodTotal2 += tempReal
        }
        var outIdx = 0
        while outIdx < inMovingAverageElementCount {
            tempReal = inDouble[endSum]
            tempReal *= tempReal
            periodTotal2 += tempReal
            var meanValue2 = periodTotal2 / Double(optInTimePeriod)
            tempReal = inDouble[startSum]
            tempReal *= tempReal
            periodTotal2 -= tempReal
            tempReal = inMovingAverage[outIdx]
            tempReal *= tempReal
            meanValue2 -= tempReal
            if meanValue2 >= 1E-08 {
                outDouble[outIdx] = sqrt(meanValue2)
            } else {
                outDouble[outIdx] = 0.0
            }
            outIdx += 1
            startSum += 1
            endSum += 1
        }
    }
    
    internal func TA_INT_stddev_using_precalc_ma(inCandle: [TA_Candle],
                                                 inCandleInputType: TA_CandleInputType,
                                                 inMovingAverage: [Double],
                                                 inMovingAverageElementStartIndex: Int,
                                                 inMovingAverageElementCount: Int,
                                                 optInTimePeriod: Int,
                                                 outDouble: inout [Double])
    {
        var tempReal: Double
        var startSum = (inMovingAverageElementStartIndex + 1) - optInTimePeriod
        var endSum = inMovingAverageElementStartIndex
        var periodTotal2 = 0.0
        for outIdx in (startSum..<endSum) {
            tempReal = inCandle[outIdx][inCandleInputType]
            tempReal *= tempReal
            periodTotal2 += tempReal
        }
        var outIdx = 0
        while outIdx < inMovingAverageElementCount {
            tempReal = inCandle[endSum][inCandleInputType]
            tempReal *= tempReal
            periodTotal2 += tempReal
            var meanValue2 = periodTotal2 / Double(optInTimePeriod)
            tempReal = inCandle[startSum][inCandleInputType]
            tempReal *= tempReal
            periodTotal2 -= tempReal
            tempReal = inMovingAverage[outIdx]
            tempReal *= tempReal
            meanValue2 -= tempReal
            if meanValue2 >= 1E-08 {
                outDouble[outIdx] = sqrt(meanValue2)
            } else {
                outDouble[outIdx] = 0.0
            }
            outIdx += 1
            startSum += 1
            endSum += 1
        }
    }
    
    internal func TA_INT_VAR(startIndex: Int,
                             endIndex: Int,
                             inDouble: [Double],
                             optInTimePeriod: Int,
                             outElementStartIndex: inout Int,
                             outElementCount: inout Int,
                             outDouble: inout [Double]) -> TA_ReturnCode
    {
        var startIndex = startIndex
        
        let nbInitialElementNeeded = optInTimePeriod - 1
        if startIndex < nbInitialElementNeeded {
            startIndex = nbInitialElementNeeded
        }
        if startIndex > endIndex {
            outElementStartIndex = 0
            outElementCount = 0
            return TA_ReturnCode.Success
        }
        var periodTotal1: Double = 0.0
        var periodTotal2: Double = 0.0
        var trailingIdx = startIndex - nbInitialElementNeeded
        var i = trailingIdx
        if optInTimePeriod > 1 {
            while i < startIndex {
                var tempReal = inDouble[i]
                i += 1
                periodTotal1 += tempReal
                tempReal *= tempReal
                periodTotal2 += tempReal
            }
        }
        var outIdx = 0
        repeat {
            var tempReal = inDouble[i]
            i += 1
            periodTotal1 += tempReal
            tempReal *= tempReal
            periodTotal2 += tempReal
            let meanValue1 = periodTotal1 / Double(optInTimePeriod)
            let meanValue2 = periodTotal2 / Double(optInTimePeriod)
            tempReal = inDouble[trailingIdx]
            trailingIdx += 1
            periodTotal1 -= tempReal
            tempReal *= tempReal
            periodTotal2 -= tempReal
            outDouble[outIdx] = meanValue2 - (meanValue1 * meanValue1)
            outIdx += 1
        } while i <= endIndex
        outElementStartIndex = startIndex
        outElementCount = outIdx
        return TA_ReturnCode.Success
    }
    
    internal func TA_INT_VAR(startIndex: Int,
                             endIndex: Int,
                             inCandle: [TA_Candle],
                             inCandleInputType: TA_CandleInputType,
                             optInTimePeriod: Int,
                             outElementStartIndex: inout Int,
                             outElementCount: inout Int,
                             outDouble: inout [Double]) -> TA_ReturnCode
    {
        var startIndex = startIndex
        
        let nbInitialElementNeeded = optInTimePeriod - 1
        if startIndex < nbInitialElementNeeded {
            startIndex = nbInitialElementNeeded
        }
        if startIndex > endIndex {
            outElementStartIndex = 0
            outElementCount = 0
            return TA_ReturnCode.Success
        }
        var periodTotal1: Double = 0.0
        var periodTotal2: Double = 0.0
        var trailingIdx = startIndex - nbInitialElementNeeded
        var i = trailingIdx
        if optInTimePeriod > 1 {
            while i < startIndex {
                var tempReal = inCandle[i][inCandleInputType]
                i += 1
                periodTotal1 += tempReal
                tempReal *= tempReal
                periodTotal2 += tempReal
            }
        }
        var outIdx = 0
        repeat {
            var tempReal = inCandle[i][inCandleInputType]
            i += 1
            periodTotal1 += tempReal
            tempReal *= tempReal
            periodTotal2 += tempReal
            let meanValue1 = periodTotal1 / Double(optInTimePeriod)
            let meanValue2 = periodTotal2 / Double(optInTimePeriod)
            tempReal = inCandle[trailingIdx][inCandleInputType]
            trailingIdx += 1
            periodTotal1 -= tempReal
            tempReal *= tempReal
            periodTotal2 -= tempReal
            outDouble[outIdx] = meanValue2 - (meanValue1 * meanValue1)
            outIdx += 1
        } while i <= endIndex
        outElementStartIndex = startIndex
        outElementCount = outIdx
        return TA_ReturnCode.Success
    }
    
    internal func TA_INT_MACD(startIndex: Int,
                              endIndex: Int,
                              inDouble: [Double],
                              optInFastPeriod: Int,
                              optInSlowPeriod: Int,
                              optInSignalPeriod: Int,
                              outElementStartIndex: inout Int,
                              outElementCount: inout Int,
                              outMACD: inout [Double],
                              outMACDSignal: inout [Double],
                              outMACDHist: inout [Double]) -> TA_ReturnCode
    {
        var startIndex = startIndex
        var optInFastPeriod = optInFastPeriod
        var optInSlowPeriod = optInSlowPeriod
        let optInSignalPeriod = optInSignalPeriod
        
        var tempInteger: Int = 0
        var k1: Double = 0.0
        var k2: Double = 0.0
        var outElementStartIndex1: Int = 0
        var outElementStartIndex2: Int = 0
        var outElementCount1: Int = 0
        var outElementCount2: Int = 0
        var returnCode: TA_ReturnCode
        
        if optInSlowPeriod < optInFastPeriod {
            let temp = optInSlowPeriod
            optInSlowPeriod = optInFastPeriod
            optInFastPeriod = temp
        }
        if optInSlowPeriod != 0 {
            k1 = 2.0 / Double(optInSlowPeriod + 1)
        } else {
            optInSlowPeriod = TA_Macd.optInSlowPeriodDefault
            k1 = 0.075
        }
        if optInFastPeriod != 0 {
            k2 = 2.0 / Double(optInFastPeriod + 1)
        } else {
            optInFastPeriod = TA_Macd.optInFastPeriodDefault
            k2 = 0.15
        }
        let lookbackSignal = TA_Ema.lookback(optInTimePeriod: optInSignalPeriod)
        let lookbackTotal = lookbackSignal + TA_Ema.lookback(optInTimePeriod: optInSlowPeriod)
        if startIndex < lookbackTotal {
            startIndex = lookbackTotal
        }
        if startIndex > endIndex {
            outElementStartIndex = 0
            outElementCount = 0
            return TA_ReturnCode.Success
        }
        
        tempInteger = ((endIndex - startIndex) + 1) + lookbackSignal
        var slowEMABuffer = [Double](repeating: Double.nan, count: tempInteger)
        var fastEMABuffer = [Double](repeating: Double.nan, count: tempInteger)
        tempInteger = startIndex - lookbackSignal
        
        returnCode = TA_Core.sharedInstance.TA_INT_EMA(startIndex: tempInteger,
                                                       endIndex: endIndex,
                                                       inDouble: inDouble,
                                                       optInTimePeriod: optInSlowPeriod,
                                                       optInK: k1,
                                                       outElementStartIndex: &outElementStartIndex1,
                                                       outElementCount: &outElementCount1,
                                                       outDouble: &slowEMABuffer)
        if returnCode != TA_ReturnCode.Success {
            outElementStartIndex = 0
            outElementCount = 0
            return returnCode
        }
        returnCode = TA_Core.sharedInstance.TA_INT_EMA(startIndex: tempInteger,
                                                       endIndex: endIndex,
                                                       inDouble: inDouble,
                                                       optInTimePeriod: optInFastPeriod,
                                                       optInK: k2,
                                                       outElementStartIndex: &outElementStartIndex2,
                                                       outElementCount: &outElementCount2,
                                                       outDouble: &fastEMABuffer)
        if returnCode != TA_ReturnCode.Success {
            outElementStartIndex = 0
            outElementCount = 0
            return returnCode
        }
        if outElementStartIndex1 != tempInteger ||
            outElementCount1 != outElementCount2 ||
            outElementCount1 != (((endIndex - startIndex) + 1) + lookbackSignal) {
            outElementStartIndex = 0;
            outElementCount = 0;
            return TA_ReturnCode.InternalError;
        }
        for i in (0..<outElementCount1) {
            fastEMABuffer[i] -= slowEMABuffer[i]
        }
        TA_ArrayUtils.Copy(sourceArray: fastEMABuffer,
                           sourceIndex: lookbackSignal,
                           destinationArray: &outMACD,
                           destinationIndex: 0,
                           length: (endIndex - startIndex) + 1)
        
        returnCode = TA_Core.sharedInstance.TA_INT_EMA(startIndex: 0,
                                                       endIndex: outElementCount1 - 1,
                                                       inDouble: fastEMABuffer,
                                                       optInTimePeriod: optInSignalPeriod,
                                                       optInK: 2.0 / Double(optInSignalPeriod + 1),
                                                       outElementStartIndex: &outElementStartIndex2,
                                                       outElementCount: &outElementCount2,
                                                       outDouble: &outMACDSignal)
        if returnCode != TA_ReturnCode.Success {
            outElementStartIndex = 0
            outElementCount = 0
            return returnCode
        }
        for i in stride(from: 0, to: outElementCount2, by: 1) {
            outMACDHist[i] = outMACD[i] - outMACDSignal[i]
        }
        outElementStartIndex = startIndex
        outElementCount = outElementCount2
        
        return TA_ReturnCode.Success
    }
    
    internal func TA_INT_MACD(startIndex: Int,
                              endIndex: Int,
                              inCandle: [TA_Candle],
                              inCandleInputType: TA_CandleInputType,
                              optInFastPeriod: Int,
                              optInSlowPeriod: Int,
                              optInSignalPeriod: Int,
                              outElementStartIndex: inout Int,
                              outElementCount: inout Int,
                              outMACD: inout [Double],
                              outMACDSignal: inout [Double],
                              outMACDHist: inout [Double]) -> TA_ReturnCode
    {
        var startIndex = startIndex
        var optInFastPeriod = optInFastPeriod
        var optInSlowPeriod = optInSlowPeriod
        let optInSignalPeriod = optInSignalPeriod
        
        var tempInteger: Int = 0
        var k1: Double = 0.0
        var k2: Double = 0.0
        var outElementStartIndex1: Int = 0
        var outElementStartIndex2: Int = 0
        var outElementCount1: Int = 0
        var outElementCount2: Int = 0
        var returnCode: TA_ReturnCode
        
        if optInSlowPeriod < optInFastPeriod {
            let temp = optInSlowPeriod
            optInSlowPeriod = optInFastPeriod
            optInFastPeriod = temp
        }
        if optInSlowPeriod != 0 {
            k1 = 2.0 / Double(optInSlowPeriod + 1)
        } else {
            optInSlowPeriod = TA_Macd.optInSlowPeriodDefault
            k1 = 0.075
        }
        if optInFastPeriod != 0 {
            k2 = 2.0 / Double(optInFastPeriod + 1)
        } else {
            optInFastPeriod = TA_Macd.optInFastPeriodDefault
            k2 = 0.15
        }
        let lookbackSignal = TA_Ema.lookback(optInTimePeriod: optInSignalPeriod)
        let lookbackTotal = lookbackSignal + TA_Ema.lookback(optInTimePeriod: optInSlowPeriod)
        if startIndex < lookbackTotal {
            startIndex = lookbackTotal
        }
        if startIndex > endIndex {
            outElementStartIndex = 0
            outElementCount = 0
            return TA_ReturnCode.Success
        }
        
        tempInteger = ((endIndex - startIndex) + 1) + lookbackSignal
        var slowEMABuffer = [Double](repeating: Double.nan, count: tempInteger)
        var fastEMABuffer = [Double](repeating: Double.nan, count: tempInteger)
        tempInteger = startIndex - lookbackSignal
        
        returnCode = TA_Core.sharedInstance.TA_INT_EMA(startIndex: tempInteger,
                                                       endIndex: endIndex,
                                                       inCandle: inCandle,
                                                       inCandleInputType: inCandleInputType,
                                                       optInTimePeriod: optInSlowPeriod,
                                                       optInK: k1,
                                                       outElementStartIndex: &outElementStartIndex1,
                                                       outElementCount: &outElementCount1,
                                                       outDouble: &slowEMABuffer)
        if returnCode != TA_ReturnCode.Success {
            outElementStartIndex = 0
            outElementCount = 0
            return returnCode
        }
        returnCode = TA_Core.sharedInstance.TA_INT_EMA(startIndex: tempInteger,
                                                       endIndex: endIndex,
                                                       inCandle: inCandle,
                                                       inCandleInputType: inCandleInputType,
                                                       optInTimePeriod: optInFastPeriod,
                                                       optInK: k2,
                                                       outElementStartIndex: &outElementStartIndex2,
                                                       outElementCount: &outElementCount2,
                                                       outDouble: &fastEMABuffer)
        if returnCode != TA_ReturnCode.Success {
            outElementStartIndex = 0
            outElementCount = 0
            return returnCode
        }
        if outElementStartIndex1 != tempInteger ||
            outElementCount1 != outElementCount2 ||
            outElementCount1 != (((endIndex - startIndex) + 1) + lookbackSignal) {
            outElementStartIndex = 0;
            outElementCount = 0;
            return TA_ReturnCode.InternalError;
        }
        for i in (0..<outElementCount1) {
            fastEMABuffer[i] -= slowEMABuffer[i]
        }
        TA_ArrayUtils.Copy(sourceArray: fastEMABuffer,
                           sourceIndex: lookbackSignal,
                           destinationArray: &outMACD,
                           destinationIndex: 0,
                           length: (endIndex - startIndex) + 1)
        
        returnCode = TA_Core.sharedInstance.TA_INT_EMA(startIndex: 0,
                                                       endIndex: outElementCount1 - 1,
                                                       inDouble: fastEMABuffer,
                                                       optInTimePeriod: optInSignalPeriod,
                                                       optInK: 2.0 / Double(optInSignalPeriod + 1),
                                                       outElementStartIndex: &outElementStartIndex2,
                                                       outElementCount: &outElementCount2,
                                                       outDouble: &outMACDSignal)
        if returnCode != TA_ReturnCode.Success {
            outElementStartIndex = 0
            outElementCount = 0
            return returnCode
        }
        for i in stride(from: 0, to: outElementCount2, by: 1) {
            outMACDHist[i] = outMACD[i] - outMACDSignal[i]
        }
        outElementStartIndex = startIndex
        outElementCount = outElementCount2
        
        return TA_ReturnCode.Success
    }
    
    internal func TA_INT_PO(startIndex: Int,
                            endIndex: Int,
                            inDouble: [Double],
                            optInFastPeriod: Int,
                            optInSlowPeriod: Int,
                            optinInMovingAverageType: TA_MovingAverageType,
                            doPercentageOutput: Bool,
                            outElementStartIndex: inout Int,
                            outElementCount: inout Int,
                            outDouble: inout [Double]) -> TA_ReturnCode
    {
        var optInFastPeriod = optInFastPeriod
        var optInSlowPeriod = optInSlowPeriod
        
        var tempInteger = 0
        var tempBuffer = [Double]()
        var outElementStartIndex2 = 0
        var outElementCount2 = 0
        if optInSlowPeriod < optInFastPeriod {
            tempInteger = optInSlowPeriod
            optInSlowPeriod = optInFastPeriod
            optInFastPeriod = tempInteger
        }
        var returnCode = TA_MovingAverage.calculate(startIndex: startIndex,
                                                    endIndex: endIndex,
                                                    inDouble: inDouble,
                                                    optInTimePeriod: optInFastPeriod,
                                                    optInMovingAverageType: optinInMovingAverageType,
                                                    outElementStartIndex: &outElementStartIndex2,
                                                    outElementCount: &outElementCount2,
                                                    outDouble: &tempBuffer)
        if returnCode == TA_ReturnCode.Success {
            var outElementStartIndex1 = 0
            var outElementCount1 = 0
            returnCode = TA_MovingAverage.calculate(startIndex: startIndex,
                                                    endIndex: endIndex,
                                                    inDouble: inDouble,
                                                    optInTimePeriod: optInSlowPeriod,
                                                    optInMovingAverageType: optinInMovingAverageType,
                                                    outElementStartIndex: &outElementStartIndex1,
                                                    outElementCount: &outElementCount1,
                                                    outDouble: &outDouble)
            if returnCode == TA_ReturnCode.Success {
                tempInteger = outElementStartIndex1 - outElementStartIndex2
                if doPercentageOutput {
                    var i = 0
                    var j = tempInteger
                    while i < outElementCount1 {
                        outDouble[i] = tempBuffer[j] - outDouble[i]
                        i += 1
                        j += 1
                    }
                } else {
                    var i = 0
                    for j in stride(from: tempInteger, to: outElementCount1, by: 1) {
                        let tempReal = outDouble[i]
                        if -1E-08 >= tempReal || tempReal >= 1E-08 {
                            outDouble[i] = ((tempBuffer[j] - tempReal) / tempReal) * 100.0
                        } else {
                            outDouble[i] = 0.0
                        }
                        i += 1
                    }
                }
                outElementStartIndex = outElementStartIndex1
                outElementCount = outElementCount1
            }
        }
        if returnCode != TA_ReturnCode.Success {
            outElementStartIndex = 0
            outElementCount = 0
        }
        
        return returnCode
    }
    
    internal func TA_INT_PO(startIndex: Int,
                            endIndex: Int,
                            inCandle: [TA_Candle],
                            inCandleInputType: TA_CandleInputType,
                            optInFastPeriod: Int,
                            optInSlowPeriod: Int,
                            optinInMovingAverageType: TA_MovingAverageType,
                            doPercentageOutput: Bool,
                            outElementStartIndex: inout Int,
                            outElementCount: inout Int,
                            outDouble: inout [Double]) -> TA_ReturnCode
    {
        var optInFastPeriod = optInFastPeriod
        var optInSlowPeriod = optInSlowPeriod
        
        var tempInteger = 0
        var tempBuffer = [Double]()
        var outElementStartIndex2 = 0
        var outElementCount2 = 0
        if optInSlowPeriod < optInFastPeriod {
            tempInteger = optInSlowPeriod
            optInSlowPeriod = optInFastPeriod
            optInFastPeriod = tempInteger
        }
        var returnCode = TA_MovingAverage.calculate(startIndex: startIndex,
                                                    endIndex: endIndex,
                                                    inCandle: inCandle,
                                                    inCandleInputType: inCandleInputType,
                                                    optInTimePeriod: optInFastPeriod,
                                                    optInMovingAverageType: optinInMovingAverageType,
                                                    outElementStartIndex: &outElementStartIndex2,
                                                    outElementCount: &outElementCount2,
                                                    outDouble: &tempBuffer)
        if returnCode == TA_ReturnCode.Success {
            var outElementStartIndex1 = 0
            var outElementCount1 = 0
            returnCode = TA_MovingAverage.calculate(startIndex: startIndex,
                                                    endIndex: endIndex,
                                                    inCandle: inCandle,
                                                    inCandleInputType: inCandleInputType,
                                                    optInTimePeriod: optInSlowPeriod,
                                                    optInMovingAverageType: optinInMovingAverageType,
                                                    outElementStartIndex: &outElementStartIndex1,
                                                    outElementCount: &outElementCount1,
                                                    outDouble: &outDouble)
            if returnCode == TA_ReturnCode.Success {
                tempInteger = outElementStartIndex1 - outElementStartIndex2
                if !doPercentageOutput {
                    var i = 0
                    var j = tempInteger
                    while i < outElementCount1 {
                        outDouble[i] = tempBuffer[j] - outDouble[i]
                        i += 1
                        j += 1
                    }
                } else {
                    var i = 0
                    for j in stride(from: tempInteger, to: outElementCount1, by: 1) {
                        let tempReal = outDouble[i]
                        if -1E-08 >= tempReal || tempReal >= 1E-08 {
                            outDouble[i] = ((tempBuffer[j] - tempReal) / tempReal) * 100.0
                        } else {
                            outDouble[i] = 0.0
                        }
                        i += 1
                    }
                }
                outElementStartIndex = outElementStartIndex1
                outElementCount = outElementCount1
            }
        }
        if returnCode != TA_ReturnCode.Success {
            outElementStartIndex = 0
            outElementCount = 0
        }
        
        return returnCode
    }
    
    
    
    
    
    final class CandleSetting: NSObject
    {
        var settingType: TA_CandleSettingType!
        var rangeType: TA_RangeType!
        var averagePeriod: Int!
        var factor: Double!
        
        
        
        
        override init()
        {
            super.init()
        }
    }
    
    
    
    
    
    internal final class GlobalsType: NSObject
    {
        fileprivate(set) var candleSettings: [TA_CandleSettingType: CandleSetting] = [TA_CandleSettingType: CandleSetting]()
        fileprivate(set) var compatibility: TA_Compatibility = TA_Compatibility.Default
        fileprivate(set) var unstablePeriod: [Int] = [Int](repeating: 0, count: 0x17)
        
        
        
        
        override init()
        {
            super.init()
            
            //for candleSettingType in CandleSettingType.allValues {
            //    self.candleSettings.updateValue(CandleSetting(), forKey: candleSettingType)
            //}
            
            self.restoreCandleDefaultSettings()
            
            //for _ in 0..<0x17 {
            //    self.unstablePeriod.append(0)
            //}
        }
        
        fileprivate func restoreCandleDefaultSettings()
        {
            self.setCandleSettings(settingType: TA_CandleSettingType.BodyLong, rangeType: TA_RangeType.RealBody, averagePeriod: 10, factor: 1.0)
            self.setCandleSettings(settingType: TA_CandleSettingType.BodyVeryLong, rangeType: TA_RangeType.RealBody, averagePeriod: 10, factor: 3.0)
            self.setCandleSettings(settingType: TA_CandleSettingType.BodyShort, rangeType: TA_RangeType.RealBody, averagePeriod: 10, factor: 1.0)
            self.setCandleSettings(settingType: TA_CandleSettingType.BodyDoji, rangeType: TA_RangeType.RealBody, averagePeriod: 10, factor: 0.1)
            self.setCandleSettings(settingType: TA_CandleSettingType.ShadowLong, rangeType: TA_RangeType.RealBody, averagePeriod: 0, factor: 1.0)
            self.setCandleSettings(settingType: TA_CandleSettingType.ShadowVeryLong, rangeType: TA_RangeType.RealBody, averagePeriod: 0, factor: 2.0)
            self.setCandleSettings(settingType: TA_CandleSettingType.ShadowShort, rangeType: TA_RangeType.Shadows, averagePeriod: 10, factor: 1.0)
            self.setCandleSettings(settingType: TA_CandleSettingType.ShadowVeryShort, rangeType: TA_RangeType.HighLow, averagePeriod: 10, factor: 0.1)
            self.setCandleSettings(settingType: TA_CandleSettingType.Near, rangeType: TA_RangeType.HighLow, averagePeriod: 5, factor: 0.2)
            self.setCandleSettings(settingType: TA_CandleSettingType.Far, rangeType: TA_RangeType.HighLow, averagePeriod: 5, factor: 0.6)
            self.setCandleSettings(settingType: TA_CandleSettingType.Equal, rangeType: TA_RangeType.HighLow, averagePeriod: 5, factor: 0.05)
        }
        
        fileprivate func setCandleSettings(settingType: TA_CandleSettingType, rangeType: TA_RangeType, averagePeriod: Int, factor: Double)
        {
            if let candleSettings = self.candleSettings[settingType] {
                candleSettings.settingType = settingType
                candleSettings.rangeType = rangeType
                candleSettings.averagePeriod = averagePeriod
                candleSettings.factor = factor
            } else {
                self.candleSettings.updateValue(CandleSetting(), forKey: settingType)
                self.setCandleSettings(settingType: settingType, rangeType: rangeType, averagePeriod: averagePeriod, factor: factor)
            }
        }
    }
}




