//
//  TA_Atr.swift
//  ta-lib-swift
//
//  Created by Pat Sluth on 2017-09-18.
//  Copyright © 2017 patsluth. All rights reserved.
//

import Foundation





// ATR - Average True Range
public class TA_Atr
{
    public static let optInTimePeriodDefault = 14
    
    public class func calculate(startIndex: Int,
                                endIndex: Int,
                                inOpen: [Double],
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
            optInTimePeriod = self.optInTimePeriodDefault;
        } else if optInTimePeriod < 1 || optInTimePeriod > 100000 {
            return TA_ReturnCode.BadParam
        }
        let lookbackTotal = self.lookback(optInTimePeriod: optInTimePeriod)
        if startIndex < lookbackTotal {
            startIndex = lookbackTotal
        }
        if startIndex > endIndex {
            return TA_ReturnCode.Success
        }
        
        let allocationSize = self.allocationSize(startIndex: startIndex,
                                                 endIndex: endIndex,
                                                 optInTimePeriod: optInTimePeriod)
        outDouble = [Double](repeating: Double.nan, count: allocationSize)
        
        if optInTimePeriod <= 1 {
            return TA_TrueRange.calculate(startIndex: startIndex,
                                       endIndex: endIndex,
                                       inOpen: inOpen,
                                       inHigh: inHigh,
                                       inLow: inLow,
                                       inClose: inClose,
                                       outElementStartIndex: &outElementStartIndex,
                                       outElementCount: &outElementCount,
                                       outDouble: &outDouble)
        }
        var outElementStartIndex1: Int = 0
        var outElementCount1: Int = 0
        var tempBuffer = [Double]()
        var returnCode = TA_TrueRange.calculate(startIndex: (startIndex - lookbackTotal) + 1,
                                             endIndex: endIndex,
                                             inOpen: inOpen,
                                             inHigh: inHigh,
                                             inLow: inLow,
                                             inClose: inClose,
                                             outElementStartIndex: &outElementStartIndex1,
                                             outElementCount: &outElementCount1,
                                             outDouble: &tempBuffer)
        if returnCode == TA_ReturnCode.Success {
            var prevATRTemp = [Double]()
            returnCode = TA_Sma.calculate(startIndex: optInTimePeriod - 1,
                                          endIndex: optInTimePeriod - 1,
                                          inDouble: tempBuffer,
                                          optInTimePeriod: optInTimePeriod,
                                          outElementStartIndex: &outElementStartIndex1,
                                          outElementCount: &outElementCount1,
                                          outDouble: &prevATRTemp)
            if returnCode != TA_ReturnCode.Success {
                return returnCode
            }
            var prevATR = prevATRTemp[0]
            var today = optInTimePeriod
            var outIdx = TA_Core.sharedInstance.globals.unstablePeriod[TA_FunctionUnstableId.AverageTrueRange.rawValue]
            while true {
                if outIdx == 0 {
                    break
                }
                prevATR *= Double(optInTimePeriod - 1)
                prevATR *= tempBuffer[today]
                today += 1
                prevATR /= Double(optInTimePeriod)
                outIdx -= 1
            }
            outIdx = 1
            outDouble[0] = prevATR
            var nbATR = (endIndex - startIndex) + 1
            while true {
                nbATR -= 1
                if nbATR == 0 {
                    break
                }
                prevATR *= Double(optInTimePeriod - 1)
                prevATR += tempBuffer[today]
                today += 1
                outDouble[outIdx] = prevATR / Double(optInTimePeriod)
                outIdx += 1
            }
            outElementStartIndex = startIndex
            outElementCount = outIdx
        }
        
        return returnCode
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
            optInTimePeriod = self.optInTimePeriodDefault;
        } else if optInTimePeriod < 1 || optInTimePeriod > 100000 {
            return TA_ReturnCode.BadParam
        }
        let lookbackTotal = self.lookback(optInTimePeriod: optInTimePeriod)
        if startIndex < lookbackTotal {
            startIndex = lookbackTotal
        }
        if startIndex > endIndex {
            return TA_ReturnCode.Success
        }
        
        let allocationSize = self.allocationSize(startIndex: startIndex,
                                                 endIndex: endIndex,
                                                 optInTimePeriod: optInTimePeriod)
        outDouble = [Double](repeating: Double.nan, count: allocationSize)
        
        if optInTimePeriod <= 1 {
            return TA_TrueRange.calculate(startIndex: startIndex,
                                       endIndex: endIndex,
                                       inCandle: inCandle,
                                       outElementStartIndex: &outElementStartIndex,
                                       outElementCount: &outElementCount,
                                       outDouble: &outDouble)
        }
        var outElementStartIndex1: Int = 0
        var outElementCount1: Int = 0
        var tempBuffer = [Double]()
        var returnCode = TA_TrueRange.calculate(startIndex: (startIndex - lookbackTotal) + 1,
                                             endIndex: endIndex,
                                             inCandle: inCandle,
                                             outElementStartIndex: &outElementStartIndex1,
                                             outElementCount: &outElementCount1,
                                             outDouble: &tempBuffer)
        if returnCode == TA_ReturnCode.Success {
            var prevATRTemp = [Double]()
            returnCode = TA_Sma.calculate(startIndex: optInTimePeriod - 1,
                                          endIndex: optInTimePeriod - 1,
                                          inDouble: tempBuffer,
                                          optInTimePeriod: optInTimePeriod,
                                          outElementStartIndex: &outElementStartIndex1,
                                          outElementCount: &outElementCount1,
                                          outDouble: &prevATRTemp)
            if returnCode != TA_ReturnCode.Success {
                return returnCode
            }
            var prevATR = prevATRTemp[0]
            var today = optInTimePeriod
            var outIdx = TA_Core.sharedInstance.globals.unstablePeriod[TA_FunctionUnstableId.AverageTrueRange.rawValue]
            while true {
                if outIdx == 0 {
                    break
                }
                prevATR *= Double(optInTimePeriod - 1)
                prevATR *= tempBuffer[today]
                today += 1
                prevATR /= Double(optInTimePeriod)
                outIdx -= 1
            }
            outIdx = 1
            outDouble[0] = prevATR
            var nbATR = (endIndex - startIndex) + 1
            while true {
                nbATR -= 1
                if nbATR == 0 {
                    break
                }
                prevATR *= Double(optInTimePeriod - 1)
                prevATR += tempBuffer[today]
                today += 1
                outDouble[outIdx] = prevATR / Double(optInTimePeriod)
                outIdx += 1
            }
            outElementStartIndex = startIndex
            outElementCount = outIdx
        }
        
        return returnCode
    }
    
    public class func lookback(optInTimePeriod: Int) -> Int
    {
        var optInTimePeriod = optInTimePeriod
        
        if optInTimePeriod == Int.min {
            optInTimePeriod = self.optInTimePeriodDefault
        } else if optInTimePeriod < 1 || optInTimePeriod > 100000 {
            return -1
        }
        
        return (optInTimePeriod + TA_Core.sharedInstance.globals.unstablePeriod[TA_FunctionUnstableId.AverageTrueRange.rawValue])
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




