//
//  TA_Adx.swift
//  ta-lib-swift
//
//  Created by Pat Sluth on 2017-09-18.
//  Copyright © 2017 patsluth. All rights reserved.
//

import Foundation





// ADX - Average Directional Movement Index
public class TA_Adx
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
        
        var tempReal: Double
        var tempReal2: Double
        var diffM: Double
        var diffP: Double
        var plusDI: Double
        var minusDI: Double
        var outIdx = 0
        var today = startIndex
        outElementStartIndex = today
        var prevMinusDM = 0.0
        var prevPlusDM = 0.0
        var prevTR = 0.0
        today = startIndex - lookbackTotal
        var prevHigh = inHigh[today]
        var prevLow = inLow[today]
        var prevClose = inClose[today]
        var i = optInTimePeriod - 1
        while i - 1 > 0 {
            i -= 1
            today += 1
            tempReal = inHigh[today]
            diffP = tempReal - prevHigh
            prevHigh = tempReal
            tempReal = inLow[today]
            diffM = prevLow - tempReal
            prevLow = tempReal
            if diffM > 0.0 && diffP < diffM {
                prevMinusDM += diffM
            } else if diffP > 0.0 && diffP > diffM {
                prevPlusDM += diffP
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
        var sumDX = 0.0
        i = optInTimePeriod
        while i - 1 > 0 {
            i -= 1
            today += 1
            tempReal = inHigh[today]
            diffP = tempReal - prevHigh
            prevHigh = tempReal
            tempReal = inLow[today]
            diffM = prevLow - tempReal
            prevLow = tempReal
            prevMinusDM -= prevMinusDM / Double(optInTimePeriod)
            prevPlusDM -= prevPlusDM / Double(optInTimePeriod)
            if diffM > 0.0 && diffP < diffM {
                prevMinusDM += diffM
            } else if diffP > 0.0 && diffP > diffM {
                prevPlusDM += diffP
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
            prevTR = (prevTR - (prevTR / Double(optInTimePeriod))) + tempReal
            prevClose = inClose[today]
            if -1E-08 >= prevTR || prevTR >= 1E-08 {
                minusDI = 100.0 * (prevMinusDM / prevTR)
                plusDI = 100.0 * (prevPlusDM / prevTR)
                tempReal = minusDI + plusDI
                if -1E-08 >= tempReal || tempReal >= 1E-08 {
                    sumDX += 100.0 * (fabs(Double(minusDI - plusDI)) / tempReal)
                }
            }
        }
        var prevADX = sumDX / Double(optInTimePeriod)
        i = TA_Core.sharedInstance.globals.unstablePeriod[TA_FunctionUnstableId.Adx.rawValue]
        while i - 1 > 0 {
            i -= 1
            today += 1
            tempReal = inHigh[today]
            diffP = tempReal - prevHigh
            prevHigh = tempReal
            tempReal = inLow[today]
            diffM = prevLow - tempReal
            prevLow = tempReal
            prevMinusDM -= prevMinusDM / Double(optInTimePeriod)
            prevPlusDM -= prevPlusDM / Double(optInTimePeriod)
            if diffM > 0.0 && diffP < diffM {
                prevMinusDM += diffM
            } else if diffP > 0.0 && diffP > diffM {
                prevPlusDM += diffP
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
            prevTR = (prevTR - (prevTR / Double(optInTimePeriod))) + tempReal
            prevClose = inClose[today]
            if -1E-08 >= prevTR || prevTR >= 1E-08
            {
                minusDI = 100.0 * (prevMinusDM / prevTR)
                plusDI = 100.0 * (prevPlusDM / prevTR)
                tempReal = minusDI + plusDI
                if -1E-08 >= tempReal || tempReal >= 1E-08 {
                    tempReal = 100.0 * fabs(Double(minusDI - plusDI) / tempReal)
                    prevADX = ((prevADX * Double(optInTimePeriod - 1)) + tempReal) / Double(optInTimePeriod)
                }
            }
        }
        outDouble[0] = prevADX
        outIdx = 1
        while today < endIndex && outIdx < outDouble.count {
            today += 1
            tempReal = inHigh[today]
            diffP = tempReal - prevHigh
            prevHigh = tempReal
            tempReal = inLow[today]
            diffM = prevLow - tempReal
            prevLow = tempReal
            prevMinusDM -= prevMinusDM / Double(optInTimePeriod)
            prevPlusDM -= prevPlusDM / Double(optInTimePeriod)
            if diffM > 0.0 && diffP < diffM {
                prevMinusDM += diffM
            }
            else if diffP > 0.0 && diffP > diffM {
                prevPlusDM += diffP
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
            prevTR = (prevTR - (prevTR / Double(optInTimePeriod))) + tempReal
            prevClose = inClose[today]
            if -1E-08 >= prevTR || prevTR >= 1E-08 {
                minusDI = 100.0 * (prevMinusDM / prevTR)
                plusDI = 100.0 * (prevPlusDM / prevTR)
                tempReal = minusDI + plusDI
                if -1E-08 >= tempReal || tempReal >= 1E-08 {
                    tempReal = 100.0 * fabs(Double(minusDI - plusDI) / tempReal)
                    prevADX = ((prevADX * Double(optInTimePeriod - 1)) + tempReal) / Double(optInTimePeriod)
                }
            }
            outDouble[outIdx] = prevADX
            outIdx += 1
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
        
        var tempReal: Double
        var tempReal2: Double
        var diffM: Double
        var diffP: Double
        var plusDI: Double
        var minusDI: Double
        var outIdx = 0
        var today = startIndex
        outElementStartIndex = today
        var prevMinusDM = 0.0
        var prevPlusDM = 0.0
        var prevTR = 0.0
        today = startIndex - lookbackTotal
        var prevHigh = inCandle[today][TA_CandleInputType.High]
        var prevLow = inCandle[today][TA_CandleInputType.Low]
        var prevClose = inCandle[today][TA_CandleInputType.Close]
        var i = optInTimePeriod - 1
        while i - 1 > 0 {
            i -= 1
            today += 1
            tempReal = inCandle[today][TA_CandleInputType.High]
            diffP = tempReal - prevHigh
            prevHigh = tempReal
            tempReal = inCandle[today][TA_CandleInputType.Low]
            diffM = prevLow - tempReal
            prevLow = tempReal
            if diffM > 0.0 && diffP < diffM {
                prevMinusDM += diffM
            } else if diffP > 0.0 && diffP > diffM {
                prevPlusDM += diffP
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
        var sumDX = 0.0
        i = optInTimePeriod
        while i - 1 > 0 {
            i -= 1
            today += 1
            tempReal = inCandle[today][TA_CandleInputType.High]
            diffP = tempReal - prevHigh
            prevHigh = tempReal
            tempReal = inCandle[today][TA_CandleInputType.Low]
            diffM = prevLow - tempReal
            prevLow = tempReal
            prevMinusDM -= prevMinusDM / Double(optInTimePeriod)
            prevPlusDM -= prevPlusDM / Double(optInTimePeriod)
            if diffM > 0.0 && diffP < diffM {
                prevMinusDM += diffM
            } else if diffP > 0.0 && diffP > diffM {
                prevPlusDM += diffP
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
            prevTR = (prevTR - (prevTR / Double(optInTimePeriod))) + tempReal
            prevClose = inCandle[today][TA_CandleInputType.Close]
            if -1E-08 >= prevTR || prevTR >= 1E-08 {
                minusDI = 100.0 * (prevMinusDM / prevTR)
                plusDI = 100.0 * (prevPlusDM / prevTR)
                tempReal = minusDI + plusDI
                if -1E-08 >= tempReal || tempReal >= 1E-08 {
                    sumDX += 100.0 * (fabs(Double(minusDI - plusDI)) / tempReal)
                }
            }
        }
        var prevADX = sumDX / Double(optInTimePeriod)
        i = TA_Core.sharedInstance.globals.unstablePeriod[TA_FunctionUnstableId.Adx.rawValue]
        while i - 1 > 0 {
            i -= 1
            today += 1
            tempReal = inCandle[today][TA_CandleInputType.High]
            diffP = tempReal - prevHigh
            prevHigh = tempReal
            tempReal = inCandle[today][TA_CandleInputType.Low]
            diffM = prevLow - tempReal
            prevLow = tempReal
            prevMinusDM -= prevMinusDM / Double(optInTimePeriod)
            prevPlusDM -= prevPlusDM / Double(optInTimePeriod)
            if diffM > 0.0 && diffP < diffM {
                prevMinusDM += diffM
            } else if diffP > 0.0 && diffP > diffM {
                prevPlusDM += diffP
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
            prevTR = (prevTR - (prevTR / Double(optInTimePeriod))) + tempReal
            prevClose = inCandle[today][TA_CandleInputType.Close]
            if -1E-08 >= prevTR || prevTR >= 1E-08
            {
                minusDI = 100.0 * (prevMinusDM / prevTR)
                plusDI = 100.0 * (prevPlusDM / prevTR)
                tempReal = minusDI + plusDI
                if -1E-08 >= tempReal || tempReal >= 1E-08 {
                    tempReal = 100.0 * fabs(Double(minusDI - plusDI) / tempReal)
                    prevADX = ((prevADX * Double(optInTimePeriod - 1)) + tempReal) / Double(optInTimePeriod)
                }
            }
        }
        outDouble[0] = prevADX
        outIdx = 1
        while today < endIndex && outIdx < outDouble.count {
            today += 1
            tempReal = inCandle[today][TA_CandleInputType.High]
            diffP = tempReal - prevHigh
            prevHigh = tempReal
            tempReal = inCandle[today][TA_CandleInputType.Low]
            diffM = prevLow - tempReal
            prevLow = tempReal
            prevMinusDM -= prevMinusDM / Double(optInTimePeriod)
            prevPlusDM -= prevPlusDM / Double(optInTimePeriod)
            if diffM > 0.0 && diffP < diffM {
                prevMinusDM += diffM
            }
            else if diffP > 0.0 && diffP > diffM {
                prevPlusDM += diffP
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
            prevTR = (prevTR - (prevTR / Double(optInTimePeriod))) + tempReal
            prevClose = inCandle[today][TA_CandleInputType.Close]
            if -1E-08 >= prevTR || prevTR >= 1E-08 {
                minusDI = 100.0 * (prevMinusDM / prevTR)
                plusDI = 100.0 * (prevPlusDM / prevTR)
                tempReal = minusDI + plusDI
                if -1E-08 >= tempReal || tempReal >= 1E-08 {
                    tempReal = 100.0 * fabs(Double(minusDI - plusDI) / tempReal)
                    prevADX = ((prevADX * Double(optInTimePeriod - 1)) + tempReal) / Double(optInTimePeriod)
                }
            }
            outDouble[outIdx] = prevADX
            outIdx += 1
        }
        
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
        
        return (optInTimePeriod * 2) + TA_Core.sharedInstance.globals.unstablePeriod[TA_FunctionUnstableId.Adx.rawValue] - 1
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




