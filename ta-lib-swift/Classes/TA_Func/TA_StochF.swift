//
//  TA_StochF.swift
//  ta-lib-swift
//
//  Created by Pat Sluth on 2017-09-18.
//  Copyright © 2017 patsluth. All rights reserved.
//

import Foundation





// STOCHF - Stochastic Fast
public class TA_StochF
{
    public static let optInFastKPeriodDefault = 5
    public static let optInFastDPeriodDefault = 3
    public static let optInFastDPeriodMovingAverageTypeDefault = TA_MovingAverageType.Sma
    
    public class func calculate(startIndex: Int,
                                endIndex: Int,
                                inHigh: [Double],
                                inLow: [Double],
                                inClose: [Double],
                                optInFastKPeriod: Int,
                                optInFastDPeriod: Int,
                                optInFastDPeriodMovingAverageType: TA_MovingAverageType,
                                outElementStartIndex: inout Int,
                                outElementCount: inout Int,
                                outFastK: inout [Double],
                                outFastD: inout [Double]) -> TA_ReturnCode
    {
        var startIndex = startIndex
        var optInFastKPeriod = optInFastKPeriod
        var optInFastDPeriod = optInFastDPeriod
        
        outElementStartIndex = 0
        outElementCount = 0
        
        if startIndex < 0 {
            return TA_ReturnCode.OutOfRangeStartIndex
        }
        if endIndex < 0 || endIndex < startIndex {
            return TA_ReturnCode.OutOfRangeStartIndex
        }
        if optInFastKPeriod == Int.min {
            optInFastKPeriod = self.optInFastKPeriodDefault
        } else if optInFastKPeriod < 1 || optInFastKPeriod > 100000 {
            return TA_ReturnCode.BadParam
        }
        if optInFastDPeriod == Int.min {
            optInFastDPeriod = self.optInFastDPeriodDefault
        } else if optInFastDPeriod < 1 || optInFastDPeriod > 100000 {
            return TA_ReturnCode.BadParam
        }
        let lookbackK = optInFastKPeriod - 1
        let lookbackFastD = TA_MovingAverage.lookback(optInTimePeriod: optInFastDPeriod,
                                                      optInMovingAverageType: optInFastDPeriodMovingAverageType)
        let lookbackTotal = lookbackK + lookbackFastD
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
                                                 optInFastKPeriod: optInFastKPeriod,
                                                 optInFastDPeriod: optInFastDPeriod,
                                                 optInFastDPeriodMovingAverageType: optInFastDPeriodMovingAverageType)
        outFastK = [Double](repeating: Double.nan, count: allocationSize)
        outFastD = [Double](repeating: Double.nan, count: allocationSize)
        
        var i: Int
        var outIdx = 0
        var trailingIdx = startIndex - lookbackTotal
        var today = trailingIdx + lookbackK
        var highestIdx = 0
        var lowestIdx = 0
        var tmp = 0.0
        var diff = 0.0
        var highest = 0.0
        var lowest = 0.0
        var tempBuffer: [Double]
        if outFastK == inHigh || outFastK == inLow || outFastK == inClose {
            tempBuffer = outFastK
        } else if outFastD == inHigh || outFastD == inLow || outFastD == inClose {
            tempBuffer = outFastD
        } else {
            tempBuffer = [Double](repeating: Double.nan, count: (endIndex - today) + 1)
        }
        /* Do the K calculation */
        while today <= endIndex {
            /* Set the lowest low */
            tmp = inLow[today]
            if lowestIdx < trailingIdx {
                lowestIdx = trailingIdx
                lowest = inLow[lowestIdx]
                i = lowestIdx
                while i + 1 <= today {
                    i += 1
                    tmp = inLow[i]
                    if tmp < lowest {
                        lowestIdx = i
                        lowest = tmp
                    }
                }
                diff = (highest - lowest) / 100.0
            } else if tmp <= lowest {
                lowestIdx = today
                lowest = tmp
                diff = (highest - lowest) / 100.0
            }
            tmp = inHigh[today]
            if highestIdx < trailingIdx {
                highestIdx = trailingIdx
                highest = inHigh[highestIdx]
                i = highestIdx
                while i + 1 <= today {
                    i += 1
                    tmp = inHigh[i]
                    if tmp > highest {
                        highestIdx = i
                        highest = tmp
                    }
                }
                diff = (highest - lowest) / 100.0
            } else if tmp >= highest {
                highestIdx = today
                highest = tmp
                diff = (highest - lowest) / 100.0
            }
            if diff != 0.0 {
                tempBuffer[outIdx] = (inClose[today] - lowest) / diff
            } else {
                tempBuffer[outIdx] = 0.0
            }
            outIdx += 1
            trailingIdx += 1
            today += 1
        }
        let returnCode = TA_MovingAverage.calculate(startIndex: 0,
                                                    endIndex: outIdx - 1,
                                                    inDouble: tempBuffer,
                                                    optInTimePeriod: optInFastDPeriod,
                                                    optInMovingAverageType: optInFastDPeriodMovingAverageType,
                                                    outElementStartIndex: &outElementStartIndex,
                                                    outElementCount: &outElementCount,
                                                    outDouble: &outFastD)
        if returnCode != TA_ReturnCode.Success || outElementCount == 0 {
            outElementStartIndex = 0
            outElementCount = 0
            return returnCode
        }
        TA_ArrayUtils.Copy(sourceArray: tempBuffer,
                           sourceIndex: lookbackFastD,
                           destinationArray: &outFastK,
                           destinationIndex: 0,
                           length: outElementCount)
        if returnCode != TA_ReturnCode.Success {
            outElementStartIndex = 0
            outElementCount = 0
            return returnCode
        }
        
        outElementStartIndex = startIndex
        
        return TA_ReturnCode.Success
    }
    
    public class func calculate(startIndex: Int,
                                endIndex: Int,
                                inCandle: [TA_Candle],
                                optInFastKPeriod: Int,
                                optInFastDPeriod: Int,
                                optInFastDPeriodMovingAverageType: TA_MovingAverageType,
                                outElementStartIndex: inout Int,
                                outElementCount: inout Int,
                                outFastK: inout [Double],
                                outFastD: inout [Double]) -> TA_ReturnCode
    {
        var startIndex = startIndex
        var optInFastKPeriod = optInFastKPeriod
        var optInFastDPeriod = optInFastDPeriod
        
        outElementStartIndex = 0
        outElementCount = 0
        
        if startIndex < 0 {
            return TA_ReturnCode.OutOfRangeStartIndex
        }
        if endIndex < 0 || endIndex < startIndex {
            return TA_ReturnCode.OutOfRangeStartIndex
        }
        if optInFastKPeriod == Int.min {
            optInFastKPeriod = self.optInFastKPeriodDefault
        } else if optInFastKPeriod < 1 || optInFastKPeriod > 100000 {
            return TA_ReturnCode.BadParam
        }
        if optInFastDPeriod == Int.min {
            optInFastDPeriod = self.optInFastDPeriodDefault
        } else if optInFastDPeriod < 1 || optInFastDPeriod > 100000 {
            return TA_ReturnCode.BadParam
        }
        let lookbackK = optInFastKPeriod - 1
        let lookbackFastD = TA_MovingAverage.lookback(optInTimePeriod: optInFastDPeriod,
                                                      optInMovingAverageType: optInFastDPeriodMovingAverageType)
        let lookbackTotal = lookbackK + lookbackFastD
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
                                                 optInFastKPeriod: optInFastKPeriod,
                                                 optInFastDPeriod: optInFastDPeriod,
                                                 optInFastDPeriodMovingAverageType: optInFastDPeriodMovingAverageType)
        outFastK = [Double](repeating: Double.nan, count: allocationSize)
        outFastD = [Double](repeating: Double.nan, count: allocationSize)
        
        var i: Int
        var outIdx = 0
        var trailingIdx = startIndex - lookbackTotal
        var today = trailingIdx + lookbackK
        var highestIdx = 0
        var lowestIdx = 0
        var tmp = 0.0
        var diff = 0.0
        var highest = 0.0
        var lowest = 0.0
        var tempBuffer: [Double]
//        if outFastK == inHigh || outFastK == inLow || outFastK == inClose {
//            tempBuffer = outFastK
//        } else if outFastD == inHigh || outFastD == inLow || outFastD == inClose {
//            tempBuffer = outFastD
//        } else {
            tempBuffer = [Double](repeating: Double.nan, count: (endIndex - today) + 1)
//        }
        /* Do the K calculation */
        while today <= endIndex {
            /* Set the lowest low */
            tmp = inCandle[today][TA_CandleInputType.Low]
            if lowestIdx < trailingIdx {
                lowestIdx = trailingIdx
                lowest = inCandle[lowestIdx][TA_CandleInputType.Low]
                i = lowestIdx
                while i + 1 <= today {
                    i += 1
                    tmp = inCandle[i][TA_CandleInputType.Low]
                    if tmp < lowest {
                        lowestIdx = i
                        lowest = tmp
                    }
                }
                diff = (highest - lowest) / 100.0
            } else if tmp <= lowest {
                lowestIdx = today
                lowest = tmp
                diff = (highest - lowest) / 100.0
            }
            tmp = inCandle[today][TA_CandleInputType.High]
            if highestIdx < trailingIdx {
                highestIdx = trailingIdx
                highest = inCandle[highestIdx][TA_CandleInputType.High]
                i = highestIdx
                while i + 1 <= today {
                    i += 1
                    tmp = inCandle[i][TA_CandleInputType.High]
                    if tmp > highest {
                        highestIdx = i
                        highest = tmp
                    }
                }
                diff = (highest - lowest) / 100.0
            } else if tmp >= highest {
                highestIdx = today
                highest = tmp
                diff = (highest - lowest) / 100.0
            }
            if diff != 0.0 {
                tempBuffer[outIdx] = (inCandle[today][TA_CandleInputType.Close] - lowest) / diff
            } else {
                tempBuffer[outIdx] = 0.0
            }
            outIdx += 1
            trailingIdx += 1
            today += 1
        }
        let returnCode = TA_MovingAverage.calculate(startIndex: 0,
                                                    endIndex: outIdx - 1,
                                                    inDouble: tempBuffer,
                                                    optInTimePeriod: optInFastDPeriod,
                                                    optInMovingAverageType: optInFastDPeriodMovingAverageType,
                                                    outElementStartIndex: &outElementStartIndex,
                                                    outElementCount: &outElementCount,
                                                    outDouble: &outFastD)
        if returnCode != TA_ReturnCode.Success || outElementCount == 0 {
            outElementStartIndex = 0
            outElementCount = 0
            return returnCode
        }
        TA_ArrayUtils.Copy(sourceArray: tempBuffer,
                           sourceIndex: lookbackFastD,
                           destinationArray: &outFastK,
                           destinationIndex: 0,
                           length: outElementCount)
        if returnCode != TA_ReturnCode.Success {
            outElementStartIndex = 0
            outElementCount = 0
            return returnCode
        }
        
        outElementStartIndex = startIndex
        
        return TA_ReturnCode.Success
    }
    
    public class func lookback(optInFastKPeriod: Int,
                               optInFastDPeriod: Int,
                               optInFastDPeriodMovingAverageType: TA_MovingAverageType) -> Int
    {
        var optInFastKPeriod = optInFastKPeriod
        var optInFastDPeriod = optInFastDPeriod
        
        if optInFastKPeriod == Int.min {
            optInFastKPeriod = self.optInFastKPeriodDefault
        } else if optInFastKPeriod < 1 || optInFastKPeriod > 100000 {
            return -1
        }
        if optInFastDPeriod == Int.min {
            optInFastDPeriod = self.optInFastDPeriodDefault
        } else if optInFastDPeriod < 1 || optInFastDPeriod > 100000 {
            return -1
        }
        
        let returnValue = optInFastKPeriod - 1
        return (returnValue + TA_MovingAverage.lookback(optInTimePeriod: optInFastDPeriod,
                                                        optInMovingAverageType: optInFastDPeriodMovingAverageType))
    }
    
    public class func allocationSize(startIndex: Int,
                                     endIndex: Int,
                                     optInFastKPeriod: Int,
                                     optInFastDPeriod: Int,
                                     optInFastDPeriodMovingAverageType: TA_MovingAverageType) -> Int
    {
        let lookback = self.lookback(optInFastKPeriod: optInFastKPeriod,
                                     optInFastDPeriod: optInFastDPeriod,
                                     optInFastDPeriodMovingAverageType: optInFastDPeriodMovingAverageType)
        let temp = max(lookback, startIndex)
        var allocationSize = 0
        if temp > endIndex {
        } else {
            allocationSize = endIndex - temp + 1
        }
        
        return allocationSize
    }
}




