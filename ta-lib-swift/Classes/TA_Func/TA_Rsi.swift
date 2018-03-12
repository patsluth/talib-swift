//
//  TA_Rsi.swift
//  ta-lib-swift
//
//  Created by Pat Sluth on 2017-09-18.
//  Copyright © 2017 patsluth. All rights reserved.
//

import Foundation





public class TA_Rsi
{
    public static let optInTimePeriodDefault = 14
    
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
            var prevGain: Double
            var prevLoss: Double
            var tempValue2: Double
            var outIdx = 0
            if optInTimePeriod == 1 {
                outElementStartIndex = startIndex
                let i = (endIndex - startIndex) + 1
                outElementCount = i
//                TA_ArrayUtils.Copy(sourceArray: inDouble,
//                                   sourceIndex: startIndex,
//                                   destinationArray: &outDouble,
//                                   destinationIndex: 0,
//                                   length: i)
                return TA_ReturnCode.Success
            }
            var today = startIndex - lookbackTotal
            var prevValue = inDouble[today]
            if TA_Core.sharedInstance.globals.unstablePeriod[TA_FunctionUnstableId.Rsi.rawValue] == 0 &&
                TA_Core.sharedInstance.globals.compatibility == TA_Compatibility.Metastock {
                let savePrevValue = prevValue
                prevGain = 0.0
                prevLoss = 0.0
                for _ in stride(from: optInTimePeriod, to: 0, by: -1) {
                    tempValue1 = inDouble[today]
                    today += 1
                    tempValue2 = tempValue1 - prevValue
                    prevValue = tempValue1
                    if tempValue2 < 0.0 {
                        prevLoss -= tempValue2
                    } else {
                        prevGain += tempValue2
                    }
                }
                tempValue1 = prevLoss / Double(optInTimePeriod)
                tempValue2 = prevGain / Double(optInTimePeriod)
                tempValue1 = tempValue2 + tempValue1
                if -1E-08 >= tempValue1 || tempValue1 >= 1E-08 {
                    outDouble[outIdx] = 100.0 * (tempValue2 / tempValue1)
                } else {
                    outDouble[outIdx] = 0.0
                }
                outIdx += 1
                if today > endIndex {
                    outElementStartIndex = startIndex
                    outElementCount = outIdx
                    return TA_ReturnCode.Success
                }
                today -= optInTimePeriod
                prevValue = savePrevValue
            }
            prevGain = 0.0
            prevLoss = 0.0
            today += 1
            for _ in stride(from: optInTimePeriod, to: 0, by: -1) {
                tempValue1 = inDouble[today]
                today += 1
                tempValue2 = tempValue1 - prevValue
                prevValue = tempValue1
                if tempValue2 < 0.0 {
                    prevLoss -= tempValue2
                } else {
                    prevGain += tempValue2
                }
            }
            prevLoss /= Double(optInTimePeriod)
            prevGain /= Double(optInTimePeriod)
            if today > startIndex {
                tempValue1 = prevGain + prevLoss
                if -1E-08 >= tempValue1 || tempValue1 >= 1E-08 {
                    outDouble[outIdx] = 100.0 * (prevGain / tempValue1)
                } else {
                    outDouble[outIdx] = 0.0
                }
                outIdx += 1
            } else {
                while today < startIndex {
                    tempValue1 = inDouble[today]
                    tempValue2 = tempValue1 - prevValue
                    prevValue = tempValue1
                    prevLoss *= Double(optInTimePeriod - 1)
                    prevGain *= Double(optInTimePeriod - 1)
                    if tempValue2 < 0.0 {
                        prevLoss -= tempValue2
                    } else {
                        prevGain += tempValue2
                    }
                    prevLoss /= Double(optInTimePeriod)
                    prevGain /= Double(optInTimePeriod)
                    today += 1
                }
            }
            while today <= endIndex {
                tempValue1 = inDouble[today]
                today += 1
                tempValue2 = tempValue1 - prevValue
                prevValue = tempValue1
                prevLoss *= Double(optInTimePeriod - 1)
                prevGain *= Double(optInTimePeriod - 1)
                if tempValue2 < 0.0 {
                    prevLoss -= tempValue2
                } else {
                    prevGain += tempValue2
                }
                prevLoss /= Double(optInTimePeriod)
                prevGain /= Double(optInTimePeriod)
                tempValue1 = prevGain + prevLoss
                if -1E-08 >= tempValue1 || tempValue1 >= 1E-08 {
                    outDouble[outIdx] = 100.0 * (prevGain / tempValue1)
                } else {
                    outDouble[outIdx] = 0.0
                }
                outIdx += 1
            }
            outElementStartIndex = startIndex
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
        let lookbackTotal = self.lookback(optInTimePeriod: optInTimePeriod)
        if startIndex < lookbackTotal {
            startIndex = lookbackTotal
        }
        
        let allocationSize = self.allocationSize(startIndex: startIndex,
                                                 endIndex: endIndex,
                                                 optInTimePeriod: optInTimePeriod)
        outDouble = [Double](repeating: Double.nan, count: allocationSize)
        
        if startIndex <= endIndex {
            var tempValue1 = Double.nan
            var prevGain = Double.nan
            var prevLoss = Double.nan
            var tempValue2 = Double.nan
            var outIdx = 0
            if optInTimePeriod == 1 {
                outElementStartIndex = startIndex
                let i = (endIndex - startIndex) + 1
                outElementCount = i
                TA_ArrayUtils.CopyCandleValues(sourceArray: inCandle,
                                               sourceIndex: startIndex,
                                               sourceCandleInputType: inCandleInputType,
                                               destinationArray: &outDouble,
                                               destinationIndex: 0,
                                               length: i)
                return TA_ReturnCode.Success
            }
            var today = startIndex - lookbackTotal
            var prevValue = inCandle[today][inCandleInputType]
            if TA_Core.sharedInstance.globals.unstablePeriod[TA_FunctionUnstableId.Rsi.rawValue] == 0 &&
                TA_Core.sharedInstance.globals.compatibility == TA_Compatibility.Metastock {
                let savePrevValue = prevValue
                prevGain = 0.0
                prevLoss = 0.0
                for _ in stride(from: optInTimePeriod, to: 0, by: -1) {
                    tempValue1 = inCandle[today][inCandleInputType]
                    today += 1
                    tempValue2 = tempValue1 - prevValue
                    prevValue = tempValue1
                    if tempValue2 < 0.0 {
                        prevLoss -= tempValue2
                    } else {
                        prevGain += tempValue2
                    }
                }
                tempValue1 = prevLoss / Double(optInTimePeriod)
                tempValue2 = prevGain / Double(optInTimePeriod)
                tempValue1 = tempValue2 + tempValue1
                if -1E-08 >= tempValue1 || tempValue1 >= 1E-08 {
                    outDouble[outIdx] = 100.0 * (tempValue2 / tempValue1)
                } else {
                    outDouble[outIdx] = 0.0
                }
                outIdx += 1
                if today > endIndex {
                    outElementStartIndex = startIndex
                    outElementCount = outIdx
                    return TA_ReturnCode.Success
                }
                today -= optInTimePeriod
                prevValue = savePrevValue
            }
            prevGain = 0.0
            prevLoss = 0.0
            today += 1
            for _ in stride(from: optInTimePeriod, to: 0, by: -1) {
                tempValue1 = inCandle[today][inCandleInputType]
                today += 1
                tempValue2 = tempValue1 - prevValue
                prevValue = tempValue1
                if tempValue2 < 0.0 {
                    prevLoss -= tempValue2
                } else {
                    prevGain += tempValue2
                }
            }
            prevLoss /= Double(optInTimePeriod)
            prevGain /= Double(optInTimePeriod)
            if today > startIndex {
                tempValue1 = prevGain + prevLoss
                if -1E-08 >= tempValue1 || tempValue1 >= 1E-08 {
                    outDouble[outIdx] = 100.0 * (prevGain / tempValue1)
                } else {
                    outDouble[outIdx] = 0.0
                }
                outIdx += 1
            } else {
                while today < startIndex {
                    tempValue1 = inCandle[today][inCandleInputType]
                    tempValue2 = tempValue1 - prevValue
                    prevValue = tempValue1
                    prevLoss *= Double(optInTimePeriod - 1)
                    prevGain *= Double(optInTimePeriod - 1)
                    if tempValue2 < 0.0 {
                        prevLoss -= tempValue2
                    } else {
                        prevGain += tempValue2
                    }
                    prevLoss /= Double(optInTimePeriod)
                    prevGain /= Double(optInTimePeriod)
                    today += 1
                }
            }
            while today <= endIndex {
                tempValue1 = inCandle[today][inCandleInputType]
                today += 1
                tempValue2 = tempValue1 - prevValue
                prevValue = tempValue1
                prevLoss *= Double(optInTimePeriod - 1)
                prevGain *= Double(optInTimePeriod - 1)
                if tempValue2 < 0.0 {
                    prevLoss -= tempValue2
                } else {
                    prevGain += tempValue2
                }
                prevLoss /= Double(optInTimePeriod)
                prevGain /= Double(optInTimePeriod)
                tempValue1 = prevGain + prevLoss
                if -1E-08 >= tempValue1 || tempValue1 >= 1E-08 {
                    outDouble[outIdx] = 100.0 * (prevGain / tempValue1)
                } else {
                    outDouble[outIdx] = 0.0
                }
                outIdx += 1
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
        var returnValue = optInTimePeriod + TA_Core.sharedInstance.globals.unstablePeriod[TA_FunctionUnstableId.Rsi.rawValue]
        if TA_Core.sharedInstance.globals.compatibility == TA_Compatibility.Metastock {
            returnValue -= 1
        }
        
        return returnValue
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




