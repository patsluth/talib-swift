//
//  TA_BBands.swift
//  ta-lib-swift
//
//  Created by Pat Sluth on 2017-09-18.
//  Copyright © 2017 patsluth. All rights reserved.
//

import Foundation





// BBANDS - Bollinger Bands
public class TA_BBands
{
    public static let optInTimePeriodDefault = 5
    public static let optInDeviationUpDefault = 2.0
    public static let optInDeviationDownDefault = 2.0
    
    public class func calculate(startIndex: Int,
                                endIndex: Int,
                                inDouble: [Double],
                                optInTimePeriod: Int,
                                optInDeviationUp: Double,
                                optInDeviationDown: Double,
                                optInMovingAverageType: TA_MovingAverageType,
                                outElementStartIndex: inout Int,
                                outElementCount: inout Int,
                                outDoubleUpperBand: inout [Double],
                                outDoubleMiddleBand: inout [Double],
                                outDoubleLowerBand: inout [Double]) -> TA_ReturnCode
    {
        var optInTimePeriod = optInTimePeriod
        var optInDeviationUp = optInDeviationUp
        var optInDeviationDown = optInDeviationDown
        
        outElementStartIndex = 0
        outElementCount = 0
        
        if startIndex < 0 {
            return TA_ReturnCode.OutOfRangeStartIndex
        }
        if endIndex < 0 || endIndex < startIndex {
            return TA_ReturnCode.OutOfRangeStartIndex
        }
        if optInTimePeriod == Int.min {
            optInTimePeriod = 5
        } else if optInTimePeriod < 2 || optInTimePeriod > 100000 {
            return TA_ReturnCode.BadParam
        }
        if optInDeviationUp == -4E+37 {
            optInDeviationUp = self.optInDeviationUpDefault
        } else if optInDeviationUp < -3E+37 || optInDeviationUp > 3E+37 {
            return TA_ReturnCode.BadParam
        }
        if optInDeviationDown == -4E+37 {
            optInDeviationDown = self.optInDeviationDownDefault
        } else if optInDeviationDown < -3E+37 || optInDeviationDown > 3E+37 {
            return TA_ReturnCode.BadParam
        }
        
        let allocationSize = self.allocationSize(startIndex: startIndex,
                                                 endIndex: endIndex,
                                                 optInTimePeriod: optInTimePeriod,
                                                 optInDeviationUp: optInDeviationUp,
                                                 optInDeviationDown: optInDeviationDown,
                                                 optInMovingAverageType: optInMovingAverageType)
        outDoubleUpperBand = [Double](repeating: Double.nan, count: allocationSize)
        outDoubleMiddleBand = [Double](repeating: Double.nan, count: allocationSize)
        outDoubleLowerBand = [Double](repeating: Double.nan, count: allocationSize)
        
        var i: Int
        var tempReal1: Double
        var tempReal2: Double
        var tempBuffer1: [Double]
        var tempBuffer2: [Double]
        if inDouble == outDoubleUpperBand {
            tempBuffer1 = outDoubleMiddleBand
            tempBuffer2 = outDoubleLowerBand
        } else if inDouble == outDoubleLowerBand {
            tempBuffer1 = outDoubleMiddleBand
            tempBuffer2 = outDoubleUpperBand
        } else if inDouble == outDoubleMiddleBand {
            tempBuffer1 = outDoubleLowerBand
            tempBuffer2 = outDoubleUpperBand
        } else {
            tempBuffer1 = outDoubleMiddleBand
            tempBuffer2 = outDoubleUpperBand
        }
        if tempBuffer1 == inDouble || tempBuffer2 == inDouble {
            return TA_ReturnCode.BadParam
        }
        var returnCode = TA_MovingAverage.calculate(startIndex: startIndex,
                                                    endIndex: endIndex,
                                                    inDouble: inDouble,
                                                    optInTimePeriod: optInTimePeriod,
                                                    optInMovingAverageType: optInMovingAverageType,
                                                    outElementStartIndex: &outElementStartIndex,
                                                    outElementCount: &outElementCount,
                                                    outDouble: &tempBuffer1)
        if returnCode != TA_ReturnCode.Success || outElementCount == 0 {
            outElementCount = 0
            return returnCode
        }
        if optInMovingAverageType == TA_MovingAverageType.Sma {
            TA_Core.sharedInstance.TA_INT_stddev_using_precalc_ma(inDouble: inDouble,
                                                                  inMovingAverage: tempBuffer1,
                                                                  inMovingAverageElementStartIndex: outElementStartIndex,
                                                                  inMovingAverageElementCount: outElementCount,
                                                                  optInTimePeriod: optInTimePeriod,
                                                                  outDouble: &tempBuffer2)
        } else {
            returnCode = TA_StdDev.calculate(startIndex: outElementStartIndex,
                                             endIndex: endIndex,
                                             inDouble: inDouble,
                                             optInTimePeriod: optInTimePeriod,
                                             optInDeviation: TA_StdDev.optInDeviationDefault,
                                             outElementStartIndex: &outElementStartIndex,
                                             outElementCount: &outElementCount,
                                             outDouble: &tempBuffer2)
            if returnCode != TA_ReturnCode.Success {
                outElementCount = 0
                return returnCode
            }
        }
        if tempBuffer1 != outDoubleMiddleBand {
            TA_ArrayUtils.Copy(sourceArray: tempBuffer1,
                               sourceIndex: 0,
                               destinationArray: &outDoubleMiddleBand,
                               destinationIndex: 0,
                               length: outElementCount)
        }
        if optInDeviationUp != optInDeviationDown {
            if optInDeviationUp != 1.0 {
                if optInDeviationDown != 1.0 {
                    i = 0
                    while i < outElementCount {
                        tempReal1 = tempBuffer2[i]
                        tempReal2 = outDoubleMiddleBand[i]
                        outDoubleUpperBand[i] = tempReal2 + (tempReal1 * optInDeviationUp)
                        outDoubleLowerBand[i] = tempReal2 - (tempReal1 * optInDeviationDown)
                    }
                    return TA_ReturnCode.Success
                }
                i = 0
                while i < outElementCount {
                    tempReal1 = tempBuffer2[i]
                    tempReal2 = outDoubleMiddleBand[i]
                    outDoubleLowerBand[i] = tempReal2 - tempReal1
                    outDoubleUpperBand[i] = tempReal2 + (tempReal1 * optInDeviationUp)
                    i += 1
                }
                return TA_ReturnCode.Success
            }
            i = 0
        } else {
            if optInDeviationUp != 1.0 {
                i = 0
            } else {
                i = 0
                while i < outElementCount {
                    tempReal1 = tempBuffer2[i]
                    tempReal2 = outDoubleMiddleBand[i]
                    outDoubleUpperBand[i] = tempReal2 + tempReal1
                    outDoubleLowerBand[i] = tempReal2 - tempReal1
                    i += 1
                }
                return TA_ReturnCode.Success
            }
            while i < outElementCount {
                tempReal1 = tempBuffer2[i] * optInDeviationUp
                tempReal2 = outDoubleMiddleBand[i]
                outDoubleUpperBand[i] = tempReal2 + tempReal1
                outDoubleLowerBand[i] = tempReal2 - tempReal1
                i += 1
            }
            return TA_ReturnCode.Success
        }
        while true {
            if i >= outElementCount {
                break
            }
            tempReal1 = tempBuffer2[i]
            tempReal2 = outDoubleMiddleBand[i]
            outDoubleUpperBand[i] = tempReal2 + tempReal1
            outDoubleLowerBand[i] = tempReal2 - (tempReal1 * optInDeviationDown)
            i += 1
        }
        return TA_ReturnCode.Success
    }
    
    public class func calculate(startIndex: Int,
                                endIndex: Int,
                                inCandle: [TA_Candle],
                                inCandleInputType: TA_CandleInputType,
                                optInTimePeriod: Int,
                                optInDeviationUp: Double,
                                optInDeviationDown: Double,
                                optInMovingAverageType: TA_MovingAverageType,
                                outElementStartIndex: inout Int,
                                outElementCount: inout Int,
                                outDoubleUpperBand: inout [Double],
                                outDoubleMiddleBand: inout [Double],
                                outDoubleLowerBand: inout [Double]) -> TA_ReturnCode
    {
        var optInTimePeriod = optInTimePeriod
        var optInDeviationUp = optInDeviationUp
        var optInDeviationDown = optInDeviationDown
        
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
        if optInDeviationUp == -4E+37 {
            optInDeviationUp = self.optInDeviationUpDefault
        } else if optInDeviationUp < -3E+37 || optInDeviationUp > 3E+37 {
            return TA_ReturnCode.BadParam
        }
        if optInDeviationDown == -4E+37 {
            optInDeviationDown = self.optInDeviationDownDefault
        } else if optInDeviationDown < -3E+37 || optInDeviationDown > 3E+37 {
            return TA_ReturnCode.BadParam
        }
        
        let allocationSize = self.allocationSize(startIndex: startIndex,
                                                 endIndex: endIndex,
                                                 optInTimePeriod: optInTimePeriod,
                                                 optInDeviationUp: optInDeviationUp,
                                                 optInDeviationDown: optInDeviationDown,
                                                 optInMovingAverageType: optInMovingAverageType)
        outDoubleUpperBand = [Double](repeating: Double.nan, count: allocationSize)
        outDoubleMiddleBand = [Double](repeating: Double.nan, count: allocationSize)
        outDoubleLowerBand = [Double](repeating: Double.nan, count: allocationSize)
        
        var i: Int
        var tempReal1: Double
        var tempReal2: Double
        var tempBuffer1: [Double]
        var tempBuffer2: [Double]
        // TODO: Implement array compare
        //        if inCandle == outDoubleUpperBand {
        //            tempBuffer1 = outDoubleMiddleBand
        //            tempBuffer2 = outDoubleLowerBand
        //        } else if inCandle == outDoubleLowerBand {
        //            tempBuffer1 = outDoubleMiddleBand
        //            tempBuffer2 = outDoubleUpperBand
        //        } else if inCandle == outDoubleMiddleBand {
        //            tempBuffer1 = outDoubleLowerBand
        //            tempBuffer2 = outDoubleUpperBand
        //        } else {
        tempBuffer1 = outDoubleMiddleBand
        tempBuffer2 = outDoubleUpperBand
        //        }
        //        if tempBuffer1 == inCandle || tempBuffer2 == inCandle {
        //            return TA_ReturnCode.BadParam
        //        }
        var returnCode = TA_MovingAverage.calculate(startIndex: startIndex,
                                                    endIndex: endIndex,
                                                    inCandle: inCandle,
                                                    inCandleInputType: inCandleInputType,
                                                    optInTimePeriod: optInTimePeriod,
                                                    optInMovingAverageType: optInMovingAverageType,
                                                    outElementStartIndex: &outElementStartIndex,
                                                    outElementCount: &outElementCount,
                                                    outDouble: &tempBuffer1)
        if returnCode != TA_ReturnCode.Success || outElementCount == 0 {
            outElementCount = 0
            return returnCode
        }
        if optInMovingAverageType == TA_MovingAverageType.Sma {
            TA_Core.sharedInstance.TA_INT_stddev_using_precalc_ma(inCandle: inCandle,
                                                                  inCandleInputType: inCandleInputType,
                                                                  inMovingAverage: tempBuffer1,
                                                                  inMovingAverageElementStartIndex: outElementStartIndex,
                                                                  inMovingAverageElementCount: outElementCount,
                                                                  optInTimePeriod: optInTimePeriod,
                                                                  outDouble: &tempBuffer2)
        } else {
            returnCode = TA_StdDev.calculate(startIndex: outElementStartIndex,
                                             endIndex: endIndex,
                                             inCandle: inCandle,
                                             inCandleInputType: inCandleInputType,
                                             optInTimePeriod: optInTimePeriod,
                                             optInDeviation: TA_StdDev.optInDeviationDefault,
                                             outElementStartIndex: &outElementStartIndex,
                                             outElementCount: &outElementCount,
                                             outDouble: &tempBuffer2)
            if returnCode != TA_ReturnCode.Success {
                outElementCount = 0
                return returnCode
            }
        }
        if tempBuffer1 != outDoubleMiddleBand {
            TA_ArrayUtils.Copy(sourceArray: tempBuffer1,
                               sourceIndex: 0,
                               destinationArray: &outDoubleMiddleBand,
                               destinationIndex: 0,
                               length: outElementCount)
        }
        if optInDeviationUp != optInDeviationDown {
            if optInDeviationUp != 1.0 {
                if optInDeviationDown != 1.0 {
                    i = 0
                    while i < outElementCount {
                        tempReal1 = tempBuffer2[i]
                        tempReal2 = outDoubleMiddleBand[i]
                        outDoubleUpperBand[i] = tempReal2 + (tempReal1 * optInDeviationUp)
                        outDoubleLowerBand[i] = tempReal2 - (tempReal1 * optInDeviationDown)
                    }
                    return TA_ReturnCode.Success
                }
                i = 0
                while i < outElementCount {
                    tempReal1 = tempBuffer2[i]
                    tempReal2 = outDoubleMiddleBand[i]
                    outDoubleLowerBand[i] = tempReal2 - tempReal1
                    outDoubleUpperBand[i] = tempReal2 + (tempReal1 * optInDeviationUp)
                    i += 1
                }
                return TA_ReturnCode.Success
            }
            i = 0
        } else {
            if optInDeviationUp != 1.0 {
                i = 0
            } else {
                i = 0
                while i < outElementCount {
                    tempReal1 = tempBuffer2[i]
                    tempReal2 = outDoubleMiddleBand[i]
                    outDoubleUpperBand[i] = tempReal2 + tempReal1
                    outDoubleLowerBand[i] = tempReal2 - tempReal1
                    i += 1
                }
                return TA_ReturnCode.Success
            }
            while i < outElementCount {
                tempReal1 = tempBuffer2[i] * optInDeviationUp
                tempReal2 = outDoubleMiddleBand[i]
                outDoubleUpperBand[i] = tempReal2 + tempReal1
                outDoubleLowerBand[i] = tempReal2 - tempReal1
                i += 1
            }
            return TA_ReturnCode.Success
        }
        while true {
            if i >= outElementCount {
                break
            }
            tempReal1 = tempBuffer2[i]
            tempReal2 = outDoubleMiddleBand[i]
            outDoubleUpperBand[i] = tempReal2 + tempReal1
            outDoubleLowerBand[i] = tempReal2 - (tempReal1 * optInDeviationDown)
            i += 1
        }
        return TA_ReturnCode.Success
    }
    
    public class func lookback(optInTimePeriod: Int,
                               optInDeviationUp: Double,
                               optInDeviationDown: Double,
                               optInMovingAverageType: TA_MovingAverageType) -> Int
    {
        var optInTimePeriod = optInTimePeriod
        var optInDeviationUp = optInDeviationUp
        var optInDeviationDown = optInDeviationDown
        
        if optInTimePeriod == Int.min {
            optInTimePeriod = self.optInTimePeriodDefault
        } else if optInTimePeriod < 2 || optInTimePeriod > 100000 {
            return -1
        }
        if optInDeviationUp == -4E+37 {
            optInDeviationUp = self.optInDeviationUpDefault
        } else if optInDeviationUp < -3E+37 || optInDeviationUp > 3E+37 {
            return -1
        }
        if optInDeviationDown == -4E+37 {
            optInDeviationDown = self.optInDeviationDownDefault
        } else if optInDeviationDown < -3E+37 || optInDeviationDown > 3E+37 {
            return -1
        }
        
        return TA_MovingAverage.lookback(optInTimePeriod: optInTimePeriod,
                                         optInMovingAverageType: optInMovingAverageType)
    }
    
    public class func allocationSize(startIndex: Int,
                                     endIndex: Int,
                                     optInTimePeriod: Int,
                                     optInDeviationUp: Double,
                                     optInDeviationDown: Double,
                                     optInMovingAverageType: TA_MovingAverageType) -> Int
    {
        let lookback = self.lookback(optInTimePeriod: optInTimePeriod,
                                     optInDeviationUp: optInDeviationUp,
                                     optInDeviationDown: optInDeviationDown,
                                     optInMovingAverageType: optInMovingAverageType)
        let temp = max(lookback, startIndex)
        var allocationSize = 0
        if temp > endIndex {
        } else {
            allocationSize = endIndex - temp + 1
        }
        
        return allocationSize
    }
}




