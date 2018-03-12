//
//  TA_Stoch.swift
//  ta-lib-swift
//
//  Created by Pat Sluth on 2017-09-18.
//  Copyright © 2017 patsluth. All rights reserved.
//

import Foundation





// TODO: TEST
// STOCH - Stochastic
public class TA_Stoch
{
    public static let optInFastKPeriodDefault = 5
    public static let optInSlowKPeriodDefault = 3
    public static let optInSlowKMovingAverageTypeDefault = TA_MovingAverageType.Sma
    public static let optInSlowDPeriodDefault = 3
    public static let optInSlowDMovingAverageTypeDefault = TA_MovingAverageType.Sma
    
    public class func calculate(startIndex: Int,
                                endIndex: Int,
                                inHigh: [Double],
                                inLow: [Double],
                                inClose: [Double],
                                optInFastKPeriod: Int,
                                optInSlowKPeriod: Int,
                                optInSlowKMovingAverageType: TA_MovingAverageType,
                                optInSlowDPeriod: Int,
                                optInSlowDMovingAverageType: TA_MovingAverageType,
                                outElementStartIndex: inout Int,
                                outElementCount: inout Int,
                                outSlowK: inout [Double],
                                outSlowD: inout [Double]) -> TA_ReturnCode
    {
        var startIndex = startIndex
        var optInFastKPeriod = optInFastKPeriod
        var optInSlowKPeriod = optInSlowKPeriod
        var optInSlowDPeriod = optInSlowDPeriod
        
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
        if optInSlowKPeriod == Int.min {
            optInSlowKPeriod = self.optInSlowKPeriodDefault
        } else if optInSlowKPeriod < 1 || optInSlowKPeriod > 100000 {
            return TA_ReturnCode.BadParam
        }
        if optInSlowDPeriod == Int.min {
            optInSlowDPeriod = self.optInSlowDPeriodDefault
        } else if optInSlowDPeriod < 1 || optInSlowDPeriod > 100000 {
            return TA_ReturnCode.BadParam
        }
        let lookbackK = optInFastKPeriod - 1
        let lookbackKSlow = TA_MovingAverage.lookback(optInTimePeriod: optInSlowKPeriod,
                                                      optInMovingAverageType: optInSlowKMovingAverageType)
        let lookbackDSlow = TA_MovingAverage.lookback(optInTimePeriod: optInSlowDPeriod,
                                                      optInMovingAverageType: optInSlowDMovingAverageType)
        let lookbackTotal = (lookbackK + lookbackDSlow) + lookbackKSlow
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
                                                 optInSlowKPeriod: optInSlowKPeriod,
                                                 optInSlowKMovingAverageType: optInSlowKMovingAverageType,
                                                 optInSlowDPeriod: optInSlowDPeriod,
                                                 optInSlowDMovingAverageType: optInSlowDMovingAverageType)
        outSlowK = [Double](repeating: Double.nan, count: allocationSize)
        outSlowD = [Double](repeating: Double.nan, count: allocationSize)
        
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
        if outSlowK == inHigh || outSlowD == inLow || outSlowK == inClose {
            tempBuffer = outSlowK
        } else if outSlowD == inHigh || outSlowD == inLow || outSlowD == inClose {
            tempBuffer = outSlowD
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
            /* Calculate stochastic. */
            if diff != 0.0 {
                tempBuffer[outIdx] = (inClose[today] - lowest) / diff
                outIdx += 1
            } else {
                tempBuffer[outIdx] = 0.0
                outIdx += 1
            }
            trailingIdx += 1
            today += 1
        }
        /* Un-smoothed K calculation completed. This K calculation is not returned
         * to the caller. It is always smoothed and then return.
         * Some documentation will refer to the smoothed version as being
         * "K-Slow", but often this end up to be shorten to "K".
         */
        var returnCode = TA_MovingAverage.calculate(startIndex: 0,
                                                    endIndex: outIdx - 1,
                                                    inDouble: tempBuffer,
                                                    optInTimePeriod: optInSlowKPeriod,
                                                    optInMovingAverageType: optInSlowKMovingAverageType,
                                                    outElementStartIndex: &outElementStartIndex,
                                                    outElementCount: &outElementCount,
                                                    outDouble: &tempBuffer)
        if returnCode != TA_ReturnCode.Success || outElementCount == 0 {
            outElementStartIndex = 0
            outElementCount = 0
            return returnCode
        }
        /* Calculate the %D which is simply a moving average of
         * the already smoothed %K.
         */
        returnCode = TA_MovingAverage.calculate(startIndex: 0,
                                                endIndex: outElementCount - 1,
                                                inDouble: tempBuffer,
                                                optInTimePeriod: optInSlowDPeriod,
                                                optInMovingAverageType: optInSlowDMovingAverageType,
                                                outElementStartIndex: &outElementStartIndex,
                                                outElementCount: &outElementCount,
                                                outDouble: &outSlowD)
        /* Copy tempBuffer into the caller buffer.
         * (Calculation could not be done directly in the
         *  caller buffer because more input data then the
         *  requested range was needed for doing %D).
         */
        TA_ArrayUtils.Copy(sourceArray: tempBuffer,
                           sourceIndex: lookbackDSlow,
                           destinationArray: &outSlowK,
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
                                optInSlowKPeriod: Int,
                                optInSlowKMovingAverageType: TA_MovingAverageType,
                                optInSlowDPeriod: Int,
                                optInSlowDMovingAverageType: TA_MovingAverageType,
                                outElementStartIndex: inout Int,
                                outElementCount: inout Int,
                                outSlowK: inout [Double],
                                outSlowD: inout [Double]) -> TA_ReturnCode
    {
        var startIndex = startIndex
        var optInFastKPeriod = optInFastKPeriod
        var optInSlowKPeriod = optInSlowKPeriod
        var optInSlowDPeriod = optInSlowDPeriod
        
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
        if optInSlowKPeriod == Int.min {
            optInSlowKPeriod = self.optInSlowKPeriodDefault
        } else if optInSlowKPeriod < 1 || optInSlowKPeriod > 100000 {
            return TA_ReturnCode.BadParam
        }
        if optInSlowDPeriod == Int.min {
            optInSlowDPeriod = self.optInSlowDPeriodDefault
        } else if optInSlowDPeriod < 1 || optInSlowDPeriod > 100000 {
            return TA_ReturnCode.BadParam
        }
        let lookbackK = optInFastKPeriod - 1
        let lookbackKSlow = TA_MovingAverage.lookback(optInTimePeriod: optInSlowKPeriod,
                                                      optInMovingAverageType: optInSlowKMovingAverageType)
        let lookbackDSlow = TA_MovingAverage.lookback(optInTimePeriod: optInSlowDPeriod,
                                                      optInMovingAverageType: optInSlowDMovingAverageType)
        let lookbackTotal = (lookbackK + lookbackDSlow) + lookbackKSlow
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
                                                 optInSlowKPeriod: optInSlowKPeriod,
                                                 optInSlowKMovingAverageType: optInSlowKMovingAverageType,
                                                 optInSlowDPeriod: optInSlowDPeriod,
                                                 optInSlowDMovingAverageType: optInSlowDMovingAverageType)
        outSlowK = [Double](repeating: Double.nan, count: allocationSize)
        outSlowD = [Double](repeating: Double.nan, count: allocationSize)
        
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
//        if outSlowK == inHigh || outSlowD == inLow || outSlowK == inClose {
//            tempBuffer = outSlowK
//        } else if outSlowD == inHigh || outSlowD == inLow || outSlowD == inClose {
//            tempBuffer = outSlowD
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
            /* Calculate stochastic. */
            if diff != 0.0 {
                tempBuffer[outIdx] = (inCandle[today][TA_CandleInputType.Close] - lowest) / diff
                outIdx += 1
            } else {
                tempBuffer[outIdx] = 0.0
                outIdx += 1
            }
            trailingIdx += 1
            today += 1
        }
        /* Un-smoothed K calculation completed. This K calculation is not returned
         * to the caller. It is always smoothed and then return.
         * Some documentation will refer to the smoothed version as being
         * "K-Slow", but often this end up to be shorten to "K".
         */
        var returnCode = TA_MovingAverage.calculate(startIndex: 0,
                                                    endIndex: outIdx - 1,
                                                    inDouble: tempBuffer,
                                                    optInTimePeriod: optInSlowKPeriod,
                                                    optInMovingAverageType: optInSlowKMovingAverageType,
                                                    outElementStartIndex: &outElementStartIndex,
                                                    outElementCount: &outElementCount,
                                                    outDouble: &tempBuffer)
        if returnCode != TA_ReturnCode.Success || outElementCount == 0 {
            outElementStartIndex = 0
            outElementCount = 0
            return returnCode
        }
        /* Calculate the %D which is simply a moving average of
         * the already smoothed %K.
         */
        returnCode = TA_MovingAverage.calculate(startIndex: 0,
                                                endIndex: outElementCount - 1,
                                                inDouble: tempBuffer,
                                                optInTimePeriod: optInSlowDPeriod,
                                                optInMovingAverageType: optInSlowDMovingAverageType,
                                                outElementStartIndex: &outElementStartIndex,
                                                outElementCount: &outElementCount,
                                                outDouble: &outSlowD)
        /* Copy tempBuffer into the caller buffer.
         * (Calculation could not be done directly in the
         *  caller buffer because more input data then the
         *  requested range was needed for doing %D).
         */
        TA_ArrayUtils.Copy(sourceArray: tempBuffer,
                           sourceIndex: lookbackDSlow,
                           destinationArray: &outSlowK,
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
                               optInSlowKPeriod: Int,
                               optInSlowKMovingAverageType: TA_MovingAverageType,
                               optInSlowDPeriod: Int,
                               optInSlowDMovingAverageType: TA_MovingAverageType) -> Int
    {
        var optInFastKPeriod = optInFastKPeriod
        var optInSlowKPeriod = optInSlowKPeriod
        var optInSlowDPeriod = optInSlowDPeriod
        
        if optInFastKPeriod == Int.min {
            optInFastKPeriod = self.optInFastKPeriodDefault
        } else if optInFastKPeriod < 1 || optInFastKPeriod > 100000 {
            return -1
        }
        if optInSlowKPeriod == Int.min {
            optInSlowKPeriod = self.optInSlowKPeriodDefault
        } else if optInSlowKPeriod < 1 || optInSlowKPeriod > 100000 {
            return -1
        }
        if optInSlowDPeriod == Int.min {
            optInSlowDPeriod = self.optInSlowDPeriodDefault
        } else if optInSlowDPeriod < 1 || optInSlowDPeriod > 100000 {
            return -1
        }
        var returnValue = optInFastKPeriod - 1
        returnValue += TA_MovingAverage.lookback(optInTimePeriod: optInSlowKPeriod,
                                                 optInMovingAverageType: optInSlowKMovingAverageType)
        return returnValue + TA_MovingAverage.lookback(optInTimePeriod: optInSlowDPeriod,
                                                       optInMovingAverageType: optInSlowDMovingAverageType)
    }
    
    public class func allocationSize(startIndex: Int,
                                     endIndex: Int,
                                     optInFastKPeriod: Int,
                                     optInSlowKPeriod: Int,
                                     optInSlowKMovingAverageType: TA_MovingAverageType,
                                     optInSlowDPeriod: Int,
                                     optInSlowDMovingAverageType: TA_MovingAverageType) -> Int
    {
        let lookback = self.lookback(optInFastKPeriod: optInFastKPeriod,
                                     optInSlowKPeriod: optInSlowKPeriod,
                                     optInSlowKMovingAverageType: optInSlowKMovingAverageType,
                                     optInSlowDPeriod: optInSlowDPeriod,
                                     optInSlowDMovingAverageType: optInSlowDMovingAverageType)
        let temp = max(lookback, startIndex)
        var allocationSize = 0
        if temp > endIndex {
        } else {
            allocationSize = endIndex - temp + 1
        }
        
        return allocationSize
    }
}




