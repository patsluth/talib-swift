//
//  TA_MinusDI.swift
//  ta-lib-swift
//
//  Created by Pat Sluth on 2017-09-18.
//  Copyright © 2017 patsluth. All rights reserved.
//

import Foundation





// MINUS_DI - Minus Directional Indicator
public class TA_MinusDI
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
        } else if optInTimePeriod < 1 || optInTimePeriod > 100000 {
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
        
        var outIdx = 0
        var today: Int
        var tempReal: Double
        var tempReal2: Double
        var prevLow: Double
        var prevHigh: Double
        var diffM: Double
        var prevClose: Double
        var diffP: Double
        if optInTimePeriod > 1 {
            today = startIndex
            outElementStartIndex = today
            var prevMinusDM = 0.0
            var prevTR = 0.0
            today = startIndex - lookbackTotal
            prevHigh = inHigh[today]
            prevLow = inLow[today]
            prevClose = inClose[today]
            var i = optInTimePeriod - 1
            while true {
                i -= 1
                if i <= 0 {
                    i = TA_Core.sharedInstance.globals.unstablePeriod[TA_FunctionUnstableId.MinusDI.rawValue] + 1
                    while true {
                        i -= 1
                        if i == 0 {
                            break
                        }
                        today += 1
                        tempReal = inHigh[today]
                        diffP = tempReal - prevHigh
                        prevHigh = tempReal
                        tempReal = inLow[today]
                        diffM = prevLow - tempReal
                        prevLow = tempReal
                        if diffM > 0.0 && diffP < diffM {
                            prevMinusDM = (prevMinusDM - (prevMinusDM / Double(optInTimePeriod))) + diffM
                        } else {
                            prevMinusDM -= prevMinusDM / Double(optInTimePeriod)
                        }
                        tempReal = prevHigh - prevLow
                        tempReal2 = fabs(prevHigh - prevClose)
                        if tempReal2 > tempReal {
                            tempReal = tempReal2
                        }
                        tempReal2 = fabs(prevLow - prevClose)
                        prevTR = (prevTR - (prevTR / Double(optInTimePeriod))) + tempReal
                        prevClose = inClose[today]
                    }
                    if -1E-08 >= prevTR || prevTR >= 1E-08 {
                        outDouble[0] = 100.0 * (prevMinusDM / prevTR)
                    } else {
                        outDouble[0] = 0.0
                    }
                    outIdx = 1
                    while today < endIndex && outIdx < outDouble.count {
                        today += 1
                        tempReal = inHigh[today]
                        diffP = tempReal - prevHigh
                        prevHigh = tempReal
                        tempReal = inLow[today]
                        diffM = prevLow - tempReal
                        prevLow = tempReal
                        if diffM > 0.0 && diffP < diffM {
                            prevMinusDM = (prevMinusDM - (prevMinusDM / Double(optInTimePeriod))) + diffM
                        } else {
                            prevMinusDM -= prevMinusDM / Double(optInTimePeriod)
                        }
                        tempReal = prevHigh - prevLow
                        tempReal2 = fabs(prevHigh - prevClose)
                        if tempReal2 > tempReal {
                            tempReal = tempReal2
                        }
                        prevTR = (prevTR - (prevTR / Double(optInTimePeriod))) + tempReal
                        prevClose = inClose[today]
                        if -1E-08 >= prevTR || prevTR >= 1E-08 {
                            outDouble[outIdx] = 100.0 * (prevMinusDM / prevTR)
                        } else {
                            outDouble[outIdx] = 0.0
                        }
                        outIdx += 1
                    }
                    outElementCount = outIdx
                    return TA_ReturnCode.Success
                }
                today += 1
                tempReal = inHigh[today]
                diffP = tempReal - prevHigh
                prevHigh = tempReal
                tempReal = inLow[today]
                diffM = prevLow - tempReal
                prevLow = tempReal
                if diffM > 0.0 && diffP < diffM {
                    prevMinusDM += diffM
                }
                tempReal = prevHigh - prevLow
                tempReal2 = fabs(prevHigh - prevClose)
                if tempReal2 > tempReal {
                    tempReal = tempReal2
                }
                tempReal2 = fabs(prevLow - prevClose)
                if tempReal2 > tempReal {
                    tempReal = tempReal2
                }
                prevTR += tempReal
                prevClose = inClose[today]
            }
        }
        outElementStartIndex = startIndex
        today = startIndex - 1
        prevHigh = inHigh[today]
        prevLow = inLow[today]
        prevClose = inClose[today]
        while today < endIndex && outIdx < outDouble.count {
            today += 1
            tempReal = inHigh[today]
            diffP = tempReal - prevHigh
            prevHigh = tempReal
            tempReal = inLow[today]
            diffM = prevLow - tempReal
            prevLow = tempReal
            if diffM > 0.0 || diffP < diffM {
                tempReal = prevHigh - prevLow
                tempReal2 = fabs(prevHigh - prevClose)
                if tempReal2 > tempReal {
                    tempReal = tempReal2
                }
                if -1E-08 < tempReal && tempReal < 1E-08 {
                    outDouble[outIdx] = 0.0
                } else {
                    outDouble[outIdx] = diffM / tempReal
                }
                outIdx += 1
            } else {
                outDouble[outIdx] = 0.0
                outIdx += 1
            }
            prevClose = inClose[today]
        }
        
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
        } else if optInTimePeriod < 1 || optInTimePeriod > 100000 {
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
        
        var outIdx = 0
        var today: Int
        var tempReal: Double
        var tempReal2: Double
        var prevLow: Double
        var prevHigh: Double
        var diffM: Double
        var prevClose: Double
        var diffP: Double
        if optInTimePeriod > 1 {
            today = startIndex
            outElementStartIndex = today
            var prevMinusDM = 0.0
            var prevTR = 0.0
            today = startIndex - lookbackTotal
            prevHigh = inCandle[today][TA_CandleInputType.High]
            prevLow = inCandle[today][TA_CandleInputType.Low]
            prevClose = inCandle[today][TA_CandleInputType.Close]
            var i = optInTimePeriod - 1
            while true {
                i -= 1
                if i <= 0 {
                    i = TA_Core.sharedInstance.globals.unstablePeriod[TA_FunctionUnstableId.MinusDI.rawValue] + 1
                    while true {
                        i -= 1
                        if i == 0 {
                            break
                        }
                        today += 1
                        tempReal = inCandle[today][TA_CandleInputType.High]
                        diffP = tempReal - prevHigh
                        prevHigh = tempReal
                        tempReal = inCandle[today][TA_CandleInputType.Low]
                        diffM = prevLow - tempReal
                        prevLow = tempReal
                        if diffM > 0.0 && diffP < diffM {
                            prevMinusDM = (prevMinusDM - (prevMinusDM / Double(optInTimePeriod))) + diffM
                        } else {
                            prevMinusDM -= prevMinusDM / Double(optInTimePeriod)
                        }
                        tempReal = prevHigh - prevLow
                        tempReal2 = fabs(prevHigh - prevClose)
                        if tempReal2 > tempReal {
                            tempReal = tempReal2
                        }
                        tempReal2 = fabs(prevLow - prevClose)
                        prevTR = (prevTR - (prevTR / Double(optInTimePeriod))) + tempReal
                        prevClose = inCandle[today][TA_CandleInputType.Close]
                    }
                    if -1E-08 >= prevTR || prevTR >= 1E-08 {
                        outDouble[0] = 100.0 * (prevMinusDM / prevTR)
                    } else {
                        outDouble[0] = 0.0
                    }
                    outIdx = 1
                    while today < endIndex && outIdx < outDouble.count {
                        today += 1
                        tempReal = inCandle[today][TA_CandleInputType.High]
                        diffP = tempReal - prevHigh
                        prevHigh = tempReal
                        tempReal = inCandle[today][TA_CandleInputType.Low]
                        diffM = prevLow - tempReal
                        prevLow = tempReal
                        if diffM > 0.0 && diffP < diffM {
                            prevMinusDM = (prevMinusDM - (prevMinusDM / Double(optInTimePeriod))) + diffM
                        } else {
                            prevMinusDM -= prevMinusDM / Double(optInTimePeriod)
                        }
                        tempReal = prevHigh - prevLow
                        tempReal2 = fabs(prevHigh - prevClose)
                        if tempReal2 > tempReal {
                            tempReal = tempReal2
                        }
                        prevTR = (prevTR - (prevTR / Double(optInTimePeriod))) + tempReal
                        prevClose = inCandle[today][TA_CandleInputType.Close]
                        if -1E-08 >= prevTR || prevTR >= 1E-08 {
                            outDouble[outIdx] = 100.0 * (prevMinusDM / prevTR)
                        } else {
                            outDouble[outIdx] = 0.0
                        }
                        outIdx += 1
                    }
                    outElementCount = outIdx
                    return TA_ReturnCode.Success
                }
                today += 1
                tempReal = inCandle[today][TA_CandleInputType.High]
                diffP = tempReal - prevHigh
                prevHigh = tempReal
                tempReal = inCandle[today][TA_CandleInputType.Low]
                diffM = prevLow - tempReal
                prevLow = tempReal
                if diffM > 0.0 && diffP < diffM {
                    prevMinusDM += diffM
                }
                tempReal = prevHigh - prevLow
                tempReal2 = fabs(prevHigh - prevClose)
                if tempReal2 > tempReal {
                    tempReal = tempReal2
                }
                tempReal2 = fabs(prevLow - prevClose)
                if tempReal2 > tempReal {
                    tempReal = tempReal2
                }
                prevTR += tempReal
                prevClose = inCandle[today][TA_CandleInputType.Close]
            }
        }
        outElementStartIndex = startIndex
        today = startIndex - 1
        prevHigh = inCandle[today][TA_CandleInputType.High]
        prevLow = inCandle[today][TA_CandleInputType.Low]
        prevClose = inCandle[today][TA_CandleInputType.Close]
        while today < endIndex && outIdx < outDouble.count {
            today += 1
            tempReal = inCandle[today][TA_CandleInputType.High]
            diffP = tempReal - prevHigh
            prevHigh = tempReal
            tempReal = inCandle[today][TA_CandleInputType.Low]
            diffM = prevLow - tempReal
            prevLow = tempReal
            if diffM > 0.0 || diffP < diffM {
                tempReal = prevHigh - prevLow
                tempReal2 = fabs(prevHigh - prevClose)
                if tempReal2 > tempReal {
                    tempReal = tempReal2
                }
                if -1E-08 < tempReal && tempReal < 1E-08 {
                    outDouble[outIdx] = 0.0
                } else {
                    outDouble[outIdx] = diffM / tempReal
                }
                outIdx += 1
            } else {
                outDouble[outIdx] = 0.0
                outIdx += 1
            }
            prevClose = inCandle[today][TA_CandleInputType.Close]
        }
        
        outElementCount = outIdx
        
        return TA_ReturnCode.Success
    }
    
    public class func lookback(optInTimePeriod: Int) -> Int
    {
        var optInTimePeriod = optInTimePeriod
        
        if optInTimePeriod == Int.min {
            optInTimePeriod = self.optInTimePeriodDefault
        } else if optInTimePeriod < 1 || optInTimePeriod > 100000 {
            return -1
        }
        if optInTimePeriod > 1 {
            return (optInTimePeriod + TA_Core.sharedInstance.globals.unstablePeriod[TA_FunctionUnstableId.MinusDI.rawValue])
        }
        return 1
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




