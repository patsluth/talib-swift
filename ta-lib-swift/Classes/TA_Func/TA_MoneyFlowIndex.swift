//
//  TA_MoneyFlowIndex.swift
//  ta-lib-swift
//
//  Created by Pat Sluth on 2017-09-18.
//  Copyright © 2017 patsluth. All rights reserved.
//

import Foundation

typealias TA_MoneyFlow = (negative: Double, positive: Double)





// MFI - Money Flow Index
public class TA_MoneyFlowIndex
{
    public static let optInTimePeriodDefault = 14
    
    public class func calculate(startIndex: Int,
                                endIndex: Int,
                                inHigh: [Double],
                                inLow: [Double],
                                inClose: [Double],
                                inVolume: [Double],
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
        var mflow = [TA_MoneyFlow](repeating: (negative: 0.0, positive: 0.0), count: optInTimePeriod)
        var mflow_Idx = 0
        let maxIdx_mflow = optInTimePeriod - 1
        let lookbackTotal = self.lookback(optInTimePeriod: optInTimePeriod)
        if startIndex < lookbackTotal {
            startIndex = lookbackTotal
        }
        
        let allocationSize = self.allocationSize(startIndex: startIndex,
                                                 endIndex: endIndex,
                                                 optInTimePeriod: optInTimePeriod)
        outDouble = [Double](repeating: Double.nan, count: allocationSize)
        
        if startIndex <= endIndex {
            var tempValue1: Double
            var tempValue2: Double
            var outIdx = 0
            var today = startIndex - lookbackTotal
            var prevValue = ((inHigh[today] + inLow[today]) + inClose[today]) / 3.0
            var posSumMF = 0.0
            var negSumMF = 0.0
            today += 1
            for _ in stride(from: optInTimePeriod, to: 0, by: -1) {
                tempValue1 = ((inHigh[today] + inLow[today]) + inClose[today]) / 3.0
                tempValue2 = tempValue1 - prevValue
                prevValue = tempValue1
                tempValue1 *= inVolume[today]
                today += 1
                if tempValue2 < 0.0 {
                    mflow[mflow_Idx].negative = tempValue1
                    negSumMF += tempValue1
                    mflow[mflow_Idx].positive = 0.0
                } else if tempValue2 > 0.0 {
                    mflow[mflow_Idx].positive = tempValue1
                    posSumMF += tempValue1
                    mflow[mflow_Idx].negative = 0.0
                } else {
                    mflow[mflow_Idx].positive = 0.0
                    mflow[mflow_Idx].negative = 0.0
                }
                mflow_Idx += 1
                if mflow_Idx > maxIdx_mflow {
                    mflow_Idx = 0
                }
            }
            if today > startIndex {
                tempValue1 = posSumMF + negSumMF
                if tempValue1 < 0.0 {
                    outDouble[outIdx] = 0.0
                } else {
                    outDouble[outIdx] = 100.0 * (posSumMF / tempValue1)
                }
                outIdx += 1
            } else {
                while today < startIndex {
                    posSumMF -= mflow[mflow_Idx].positive
                    negSumMF -= mflow[mflow_Idx].negative
                    tempValue1 = ((inHigh[today] + inLow[today]) + inClose[today]) / 3.0
                    tempValue2 = tempValue1 - prevValue
                    prevValue = tempValue1
                    tempValue1 *= inVolume[today]
                    today += 1
                    if tempValue2 < 0.0 {
                        mflow[mflow_Idx].negative = tempValue1
                        negSumMF += tempValue1
                        mflow[mflow_Idx].positive = 0.0
                    } else if tempValue2 > 0.0 {
                        mflow[mflow_Idx].positive = tempValue1
                        posSumMF += tempValue1
                        mflow[mflow_Idx].negative = 0.0
                    } else {
                        mflow[mflow_Idx].positive = 0.0
                        mflow[mflow_Idx].negative = 0.0
                    }
                    mflow_Idx += 1
                    if mflow_Idx > maxIdx_mflow {
                        mflow_Idx = 0
                    }
                }
            }
            while today <= endIndex {
                posSumMF -= mflow[mflow_Idx].positive
                negSumMF -= mflow[mflow_Idx].negative
                tempValue1 = ((inHigh[today] + inLow[today]) + inClose[today]) / 3.0
                tempValue2 = tempValue1 - prevValue
                prevValue = tempValue1
                tempValue1 *= inVolume[today]
                today += 1
                if tempValue2 < 0.0 {
                    mflow[mflow_Idx].negative = tempValue1
                    negSumMF += tempValue1
                    mflow[mflow_Idx].positive = 0.0
                } else if tempValue2 > 0.0 {
                    mflow[mflow_Idx].positive = tempValue1
                    posSumMF += tempValue1
                    mflow[mflow_Idx].negative = 0.0
                } else {
                    mflow[mflow_Idx].positive = 0.0
                    mflow[mflow_Idx].negative = 0.0
                }
                tempValue1 = posSumMF + negSumMF
                if tempValue1 < 1.0 {
                    outDouble[outIdx] = 0.0
                } else {
                    outDouble[outIdx] = 100.0 * (posSumMF / tempValue1)
                }
                outIdx += 1
                mflow_Idx += 1
                if mflow_Idx > maxIdx_mflow {
                    mflow_Idx = 0
                }
            }
            
            outElementStartIndex = startIndex
            outElementCount = outIdx
        }
        
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
        var mflow = [TA_MoneyFlow](repeating: (negative: 0.0, positive: 0.0), count: optInTimePeriod)
        var mflow_Idx = 0
        let maxIdx_mflow = optInTimePeriod - 1
        let lookbackTotal = self.lookback(optInTimePeriod: optInTimePeriod)
        if startIndex < lookbackTotal {
            startIndex = lookbackTotal
        }
        
        let allocationSize = self.allocationSize(startIndex: startIndex,
                                                 endIndex: endIndex,
                                                 optInTimePeriod: optInTimePeriod)
        outDouble = [Double](repeating: Double.nan, count: allocationSize)
        
        if startIndex <= endIndex {
            var tempValue1: Double
            var tempValue2: Double
            var outIdx = 0
            var today = startIndex - lookbackTotal
            var prevValue = ((inCandle[today][TA_CandleInputType.High] + inCandle[today][TA_CandleInputType.Low]) + inCandle[today][TA_CandleInputType.Close]) / 3.0
            var posSumMF = 0.0
            var negSumMF = 0.0
            today += 1
            for _ in stride(from: optInTimePeriod, to: 0, by: -1) {
                tempValue1 = ((inCandle[today][TA_CandleInputType.High] + inCandle[today][TA_CandleInputType.Low]) + inCandle[today][TA_CandleInputType.Close]) / 3.0
                tempValue2 = tempValue1 - prevValue
                prevValue = tempValue1
                tempValue1 *= inCandle[today][TA_CandleInputType.Volume]
                today += 1
                if tempValue2 < 0.0 {
                    mflow[mflow_Idx].negative = tempValue1
                    negSumMF += tempValue1
                    mflow[mflow_Idx].positive = 0.0
                } else if tempValue2 > 0.0 {
                    mflow[mflow_Idx].positive = tempValue1
                    posSumMF += tempValue1
                    mflow[mflow_Idx].negative = 0.0
                } else {
                    mflow[mflow_Idx].positive = 0.0
                    mflow[mflow_Idx].negative = 0.0
                }
                mflow_Idx += 1
                if mflow_Idx > maxIdx_mflow {
                    mflow_Idx = 0
                }
            }
            if today > startIndex {
                tempValue1 = posSumMF + negSumMF
                if tempValue1 < 0.0 {
                    outDouble[outIdx] = 0.0
                } else {
                    outDouble[outIdx] = 100.0 * (posSumMF / tempValue1)
                }
                outIdx += 1
            } else {
                while today < startIndex {
                    posSumMF -= mflow[mflow_Idx].positive
                    negSumMF -= mflow[mflow_Idx].negative
                    tempValue1 = ((inCandle[today][TA_CandleInputType.High] + inCandle[today][TA_CandleInputType.Low]) + inCandle[today][TA_CandleInputType.Close]) / 3.0
                    tempValue2 = tempValue1 - prevValue
                    prevValue = tempValue1
                    tempValue1 *= inCandle[today][TA_CandleInputType.Volume]
                    today += 1
                    if tempValue2 < 0.0 {
                        mflow[mflow_Idx].negative = tempValue1
                        negSumMF += tempValue1
                        mflow[mflow_Idx].positive = 0.0
                    } else if tempValue2 > 0.0 {
                        mflow[mflow_Idx].positive = tempValue1
                        posSumMF += tempValue1
                        mflow[mflow_Idx].negative = 0.0
                    } else {
                        mflow[mflow_Idx].positive = 0.0
                        mflow[mflow_Idx].negative = 0.0
                    }
                    mflow_Idx += 1
                    if mflow_Idx > maxIdx_mflow {
                        mflow_Idx = 0
                    }
                }
            }
            while today <= endIndex {
                posSumMF -= mflow[mflow_Idx].positive
                negSumMF -= mflow[mflow_Idx].negative
                tempValue1 = ((inCandle[today][TA_CandleInputType.High] + inCandle[today][TA_CandleInputType.Low]) + inCandle[today][TA_CandleInputType.Close]) / 3.0
                tempValue2 = tempValue1 - prevValue
                prevValue = tempValue1
                tempValue1 *= inCandle[today][TA_CandleInputType.Volume]
                today += 1
                if tempValue2 < 0.0 {
                    mflow[mflow_Idx].negative = tempValue1
                    negSumMF += tempValue1
                    mflow[mflow_Idx].positive = 0.0
                } else if tempValue2 > 0.0 {
                    mflow[mflow_Idx].positive = tempValue1
                    posSumMF += tempValue1
                    mflow[mflow_Idx].negative = 0.0
                } else {
                    mflow[mflow_Idx].positive = 0.0
                    mflow[mflow_Idx].negative = 0.0
                }
                tempValue1 = posSumMF + negSumMF
                if tempValue1 < 1.0 {
                    outDouble[outIdx] = 0.0
                } else {
                    outDouble[outIdx] = 100.0 * (posSumMF / tempValue1)
                }
                outIdx += 1
                mflow_Idx += 1
                if mflow_Idx > maxIdx_mflow {
                    mflow_Idx = 0
                }
            }
            
            outElementStartIndex = startIndex
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
        
        return (optInTimePeriod + TA_Core.sharedInstance.globals.unstablePeriod[TA_FunctionUnstableId.Mfi.rawValue])
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




