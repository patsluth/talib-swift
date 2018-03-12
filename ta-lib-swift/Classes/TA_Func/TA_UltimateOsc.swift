//
//  TA_UltimateOsc.swift
//  ta-lib-swift
//
//  Created by Pat Sluth on 2017-09-18.
//  Copyright © 2017 patsluth. All rights reserved.
//

import Foundation





// ULTOSC - Ultimate Oscillator
public class TA_UltimateOsc
{
    public static let optInTimePeriod1Default = 7
    public static let optInTimePeriod2Default = 14
    public static let optInTimePeriod3Default = 28
    
    public class func calculate(startIndex: Int,
                                endIndex: Int,
                                inHigh: [Double],
                                inLow: [Double],
                                inClose: [Double],
                                optInTimePeriod1: Int,
                                optInTimePeriod2: Int,
                                optInTimePeriod3: Int,
                                outElementStartIndex: inout Int,
                                outElementCount: inout Int,
                                outDouble: inout [Double]) -> TA_ReturnCode
    {
        var startIndex = startIndex
        var optInTimePeriod1 = optInTimePeriod1
        var optInTimePeriod2 = optInTimePeriod2
        var optInTimePeriod3 = optInTimePeriod3
        
        outElementStartIndex = 0
        outElementCount = 0
        
        if startIndex < 0 {
            return TA_ReturnCode.OutOfRangeStartIndex
        }
        if endIndex < 0 || endIndex < startIndex {
            return TA_ReturnCode.OutOfRangeStartIndex
        }
        if optInTimePeriod1 == Int.min {
            optInTimePeriod1 = self.optInTimePeriod1Default
        } else if optInTimePeriod1 < 1 || optInTimePeriod1 > 100000 {
            return TA_ReturnCode.BadParam
        }
        if optInTimePeriod2 == Int.min {
            optInTimePeriod2 = self.optInTimePeriod2Default
        } else if optInTimePeriod2 < 1 || optInTimePeriod2 > 100000 {
            return TA_ReturnCode.BadParam
        }
        if optInTimePeriod3 == Int.min {
            optInTimePeriod3 = self.optInTimePeriod3Default
        } else if optInTimePeriod3 < 1 || optInTimePeriod3 > 100000 {
            return TA_ReturnCode.BadParam
        }
        
        let allocationSize = self.allocationSize(startIndex: startIndex,
                                                 endIndex: endIndex,
                                                 optInTimePeriod1: optInTimePeriod1,
                                                 optInTimePeriod2: optInTimePeriod2,
                                                 optInTimePeriod3: optInTimePeriod3)
        outDouble = [Double](repeating: Double.nan, count: allocationSize)
        
        var outIdx = 0
        var usedFlag = [Int](repeating: 0, count: 3)
        var periods = [optInTimePeriod1, optInTimePeriod2, optInTimePeriod3]
        var sortedPeriods = [Int](repeating: 0, count: 3)
        usedFlag[0] = 0
        usedFlag[1] = 0
        usedFlag[2] = 0
        var i = 0
        while true {
            if i >= 3 {
                var trueRange: Double
                var tempDouble: Double
                var tempCY: Double
                var tempLT: Double
                var tempHT: Double
                var closeMinusTrueLow: Double
                var trueLow: Double
                optInTimePeriod1 = sortedPeriods[2]
                optInTimePeriod2 = sortedPeriods[1]
                optInTimePeriod3 = sortedPeriods[0]
                let lookbackTotal = TA_UltimateOsc.lookback(optInTimePeriod1: optInTimePeriod1,
                                                       optInTimePeriod2: optInTimePeriod2,
                                                       optInTimePeriod3: optInTimePeriod3)
                if startIndex < lookbackTotal {
                    startIndex = lookbackTotal
                }
                if startIndex > endIndex {
                    return TA_ReturnCode.Success
                }
                var a1Total = 0.0
                var b1Total = 0.0
                i = (startIndex - optInTimePeriod1) + 1
                while i < startIndex {
                    var num7: Double
                    tempLT = inLow[i]
                    tempHT = inHigh[i]
                    tempCY = inClose[i - 1]
                    if tempLT < tempCY {
                        num7 = tempLT
                    } else {
                        num7 = tempCY
                    }
                    trueLow = num7
                    closeMinusTrueLow = inClose[i] - trueLow
                    trueRange = tempHT - tempLT
                    tempDouble = fabs(tempCY - tempHT)
                    if tempDouble > trueRange {
                        trueRange = tempDouble
                    }
                    tempDouble = fabs(tempCY - tempLT)
                    if tempDouble > trueRange {
                        trueRange = tempDouble
                    }
                    a1Total += closeMinusTrueLow
                    b1Total += trueRange
                    i += 1
                }
                var a2Total = 0.0
                var b2Total = 0.0
                i = (startIndex - optInTimePeriod2) + 1
                while i < startIndex {
                    var num6: Double
                    tempLT = inLow[i]
                    tempHT = inHigh[i]
                    tempCY = inClose[i - 1]
                    if tempLT < tempCY {
                        num6 = tempLT
                    } else {
                        num6 = tempCY
                    }
                    trueLow = num6
                    closeMinusTrueLow = inClose[i] - trueLow
                    trueRange = tempHT - tempLT
                    tempDouble = fabs(tempCY - tempHT)
                    if tempDouble > trueRange {
                        trueRange = tempDouble
                    }
                    tempDouble = fabs(tempCY - tempLT)
                    if tempDouble > trueRange {
                        trueRange = tempDouble
                    }
                    a2Total += closeMinusTrueLow
                    b2Total += trueRange
                    i += 1
                }
                var a3Total = 0.0
                var b3Total = 0.0
                i = (startIndex - optInTimePeriod3) + 1
                while i < startIndex {
                    var num5: Double
                    tempLT = inLow[i]
                    tempHT = inHigh[i]
                    tempCY = inClose[i - 1]
                    if tempLT < tempCY {
                        num5 = tempLT
                    } else {
                        num5 = tempCY
                    }
                    trueLow = num5
                    closeMinusTrueLow = inClose[i] - trueLow
                    trueRange = tempHT - tempLT
                    tempDouble = fabs(tempCY - tempHT)
                    if tempDouble > trueRange {
                        trueRange = tempDouble
                    }
                    tempDouble = fabs(tempCY - tempLT)
                    if tempDouble > trueRange {
                        trueRange = tempDouble
                    }
                    a3Total += closeMinusTrueLow
                    b3Total += trueRange
                    i += 1
                }
                var today = startIndex
                outIdx = 0
                var trailingIdx1 = (today - optInTimePeriod1) + 1
                var trailingIdx2 = (today - optInTimePeriod2) + 1
                var trailingIdx3 = (today - optInTimePeriod2) + 1
                while today <= endIndex {
                    var num: Double
                    var num2: Double
                    var num3: Double
                    var num4: Double
                    tempLT = inLow[today]
                    tempHT = inHigh[today]
                    tempCY = inClose[today - 1]
                    if tempLT < tempCY {
                        num4 = tempLT
                    } else {
                        num4 = tempCY
                    }
                    trueLow = num4
                    closeMinusTrueLow = inClose[today] - trueLow
                    trueRange = tempHT - tempLT
                    tempDouble = fabs(tempCY - tempHT)
                    if tempDouble > trueRange {
                        trueRange = tempDouble
                    }
                    tempDouble = fabs(tempCY - tempLT)
                    if tempDouble > trueRange {
                        trueRange = tempDouble
                    }
                    a1Total += closeMinusTrueLow
                    a2Total += closeMinusTrueLow
                    a3Total += closeMinusTrueLow
                    b1Total += trueRange
                    b2Total += trueRange
                    b3Total += trueRange
                    var output = 0.0
                    if -1E-08 >= b1Total || b1Total >= 1E-08 {
                        output += 4.0 * (a1Total / b1Total)
                    }
                    if -1E-08 >= b2Total || b2Total >= 1E-08 {
                        output += 2.0 * (a2Total / b2Total)
                    }
                    if -1E-08 >= b3Total || b3Total >= 1E-08 {
                        output += a3Total / b3Total
                    }
                    tempLT = inLow[trailingIdx1]
                    tempHT = inHigh[trailingIdx1]
                    tempCY = inClose[trailingIdx1 - 1]
                    if tempLT < tempCY {
                        num3 = tempLT
                    } else {
                        num3 = tempCY
                    }
                    trueLow = num3
                    closeMinusTrueLow = inClose[trailingIdx1] - trueLow
                    trueRange = tempHT - tempLT
                    tempDouble = fabs(tempCY - tempHT)
                    if tempDouble > trueRange {
                        trueRange = tempDouble
                    }
                    tempDouble = fabs(tempCY - tempLT)
                    if tempDouble > trueRange {
                        trueRange = tempDouble
                    }
                    a1Total -= closeMinusTrueLow
                    b1Total -= trueRange
                    tempLT = inLow[trailingIdx2]
                    tempHT = inHigh[trailingIdx2]
                    tempCY = inClose[trailingIdx2 - 1]
                    if tempLT < tempCY {
                        num2 = tempLT
                    } else {
                        num2 = tempCY
                    }
                    trueLow = num2
                    closeMinusTrueLow = inClose[trailingIdx2] - trueLow
                    trueRange = tempHT - tempLT
                    tempDouble = fabs(tempCY - tempHT)
                    if tempDouble > trueRange {
                        trueRange = tempDouble
                    }
                    tempDouble = fabs(tempCY - tempLT)
                    if tempDouble > trueRange {
                        trueRange = tempDouble
                    }
                    a2Total -= closeMinusTrueLow
                    b2Total -= trueRange
                    tempLT = inLow[trailingIdx3]
                    tempHT = inHigh[trailingIdx3]
                    tempCY = inClose[trailingIdx3 - 1]
                    if tempLT < tempCY {
                        num = tempLT
                    } else {
                        num = tempCY
                    }
                    trueLow = num
                    closeMinusTrueLow = inClose[trailingIdx3] - trueLow
                    trueRange = tempHT - tempLT
                    tempDouble = fabs(tempCY - tempHT)
                    if tempDouble > trueRange {
                        trueRange = tempDouble
                    }
                    tempDouble = fabs(tempCY - tempLT)
                    if tempDouble > trueRange {
                        trueRange = tempDouble
                    }
                    a3Total -= closeMinusTrueLow
                    b3Total -= trueRange
                    outDouble[outIdx] = 100.0 * (output / 7.0)
                    outIdx += 1
                    today += 1
                    trailingIdx1 += 1
                    trailingIdx2 += 1
                    trailingIdx3 += 1
                }
                break
            }
            var longestPeriod = 0
            var longestIndex = 0
            for j in stride(from: 0, to: 3, by: 1) {
                if usedFlag[j] == 0 && periods[j] > longestPeriod {
                    longestPeriod = periods[j]
                    longestIndex = j
                }
            }
            usedFlag[longestIndex] = 1
            sortedPeriods[i] = longestPeriod
            i += 1
        }
        
        outElementStartIndex = startIndex
        outElementCount = outIdx
        
        return TA_ReturnCode.Success
    }
    
    public class func calculate(startIndex: Int,
                                endIndex: Int,
                                inCandle: [TA_Candle],
                                optInTimePeriod1: Int,
                                optInTimePeriod2: Int,
                                optInTimePeriod3: Int,
                                outElementStartIndex: inout Int,
                                outElementCount: inout Int,
                                outDouble: inout [Double]) -> TA_ReturnCode
    {
        var startIndex = startIndex
        var optInTimePeriod1 = optInTimePeriod1
        var optInTimePeriod2 = optInTimePeriod2
        var optInTimePeriod3 = optInTimePeriod3
        
        outElementStartIndex = 0
        outElementCount = 0
        
        if startIndex < 0 {
            return TA_ReturnCode.OutOfRangeStartIndex
        }
        if endIndex < 0 || endIndex < startIndex {
            return TA_ReturnCode.OutOfRangeStartIndex
        }
        if optInTimePeriod1 == Int.min {
            optInTimePeriod1 = self.optInTimePeriod1Default
        } else if optInTimePeriod1 < 1 || optInTimePeriod1 > 100000 {
            return TA_ReturnCode.BadParam
        }
        if optInTimePeriod2 == Int.min {
            optInTimePeriod2 = self.optInTimePeriod2Default
        } else if optInTimePeriod2 < 1 || optInTimePeriod2 > 100000 {
            return TA_ReturnCode.BadParam
        }
        if optInTimePeriod3 == Int.min {
            optInTimePeriod3 = self.optInTimePeriod3Default
        } else if optInTimePeriod3 < 1 || optInTimePeriod3 > 100000 {
            return TA_ReturnCode.BadParam
        }
        
        let allocationSize = self.allocationSize(startIndex: startIndex,
                                                 endIndex: endIndex,
                                                 optInTimePeriod1: optInTimePeriod1,
                                                 optInTimePeriod2: optInTimePeriod2,
                                                 optInTimePeriod3: optInTimePeriod3)
        outDouble = [Double](repeating: Double.nan, count: allocationSize)
        
        var outIdx = 0
        var usedFlag = [Int](repeating: 0, count: 3)
        var periods = [optInTimePeriod1, optInTimePeriod2, optInTimePeriod3]
        var sortedPeriods = [Int](repeating: 0, count: 3)
        usedFlag[0] = 0
        usedFlag[1] = 0
        usedFlag[2] = 0
        var i = 0
        while true {
            if i >= 3 {
                var trueRange: Double
                var tempDouble: Double
                var tempCY: Double
                var tempLT: Double
                var tempHT: Double
                var closeMinusTrueLow: Double
                var trueLow: Double
                optInTimePeriod1 = sortedPeriods[2]
                optInTimePeriod2 = sortedPeriods[1]
                optInTimePeriod3 = sortedPeriods[0]
                let lookbackTotal = TA_UltimateOsc.lookback(optInTimePeriod1: optInTimePeriod1,
                                                       optInTimePeriod2: optInTimePeriod2,
                                                       optInTimePeriod3: optInTimePeriod3)
                if startIndex < lookbackTotal {
                    startIndex = lookbackTotal
                }
                if startIndex > endIndex {
                    return TA_ReturnCode.Success
                }
                var a1Total = 0.0
                var b1Total = 0.0
                i = (startIndex - optInTimePeriod1) + 1
                while i < startIndex {
                    var num7: Double
                    tempLT = inCandle[i][TA_CandleInputType.Low]
                    tempHT = inCandle[i][TA_CandleInputType.High]
                    tempCY = inCandle[i - 1][TA_CandleInputType.Close]
                    if tempLT < tempCY {
                        num7 = tempLT
                    } else {
                        num7 = tempCY
                    }
                    trueLow = num7
                    closeMinusTrueLow = inCandle[i][TA_CandleInputType.Close] - trueLow
                    trueRange = tempHT - tempLT
                    tempDouble = fabs(tempCY - tempHT)
                    if tempDouble > trueRange {
                        trueRange = tempDouble
                    }
                    tempDouble = fabs(tempCY - tempLT)
                    if tempDouble > trueRange {
                        trueRange = tempDouble
                    }
                    a1Total += closeMinusTrueLow
                    b1Total += trueRange
                    i += 1
                }
                var a2Total = 0.0
                var b2Total = 0.0
                i = (startIndex - optInTimePeriod2) + 1
                while i < startIndex {
                    var num6: Double
                    tempLT = inCandle[i][TA_CandleInputType.Low]
                    tempHT = inCandle[i][TA_CandleInputType.High]
                    tempCY = inCandle[i - 1][TA_CandleInputType.Close]
                    if tempLT < tempCY {
                        num6 = tempLT
                    } else {
                        num6 = tempCY
                    }
                    trueLow = num6
                    closeMinusTrueLow = inCandle[i][TA_CandleInputType.Close] - trueLow
                    trueRange = tempHT - tempLT
                    tempDouble = fabs(tempCY - tempHT)
                    if tempDouble > trueRange {
                        trueRange = tempDouble
                    }
                    tempDouble = fabs(tempCY - tempLT)
                    if tempDouble > trueRange {
                        trueRange = tempDouble
                    }
                    a2Total += closeMinusTrueLow
                    b2Total += trueRange
                    i += 1
                }
                var a3Total = 0.0
                var b3Total = 0.0
                i = (startIndex - optInTimePeriod3) + 1
                while i < startIndex {
                    var num5: Double
                    tempLT = inCandle[i][TA_CandleInputType.Low]
                    tempHT = inCandle[i][TA_CandleInputType.High]
                    tempCY = inCandle[i - 1][TA_CandleInputType.Close]
                    if tempLT < tempCY {
                        num5 = tempLT
                    } else {
                        num5 = tempCY
                    }
                    trueLow = num5
                    closeMinusTrueLow = inCandle[i][TA_CandleInputType.Close] - trueLow
                    trueRange = tempHT - tempLT
                    tempDouble = fabs(tempCY - tempHT)
                    if tempDouble > trueRange {
                        trueRange = tempDouble
                    }
                    tempDouble = fabs(tempCY - tempLT)
                    if tempDouble > trueRange {
                        trueRange = tempDouble
                    }
                    a3Total += closeMinusTrueLow
                    b3Total += trueRange
                    i += 1
                }
                var today = startIndex
                outIdx = 0
                var trailingIdx1 = (today - optInTimePeriod1) + 1
                var trailingIdx2 = (today - optInTimePeriod2) + 1
                var trailingIdx3 = (today - optInTimePeriod2) + 1
                while today <= endIndex {
                    var num: Double
                    var num2: Double
                    var num3: Double
                    var num4: Double
                    tempLT = inCandle[today][TA_CandleInputType.Low]
                    tempHT = inCandle[today][TA_CandleInputType.High]
                    tempCY = inCandle[today - 1][TA_CandleInputType.Close]
                    if tempLT < tempCY {
                        num4 = tempLT
                    } else {
                        num4 = tempCY
                    }
                    trueLow = num4
                    closeMinusTrueLow = inCandle[today][TA_CandleInputType.Close] - trueLow
                    trueRange = tempHT - tempLT
                    tempDouble = fabs(tempCY - tempHT)
                    if tempDouble > trueRange {
                        trueRange = tempDouble
                    }
                    tempDouble = fabs(tempCY - tempLT)
                    if tempDouble > trueRange {
                        trueRange = tempDouble
                    }
                    a1Total += closeMinusTrueLow
                    a2Total += closeMinusTrueLow
                    a3Total += closeMinusTrueLow
                    b1Total += trueRange
                    b2Total += trueRange
                    b3Total += trueRange
                    var output = 0.0
                    if -1E-08 >= b1Total || b1Total >= 1E-08 {
                        output += 4.0 * (a1Total / b1Total)
                    }
                    if -1E-08 >= b2Total || b2Total >= 1E-08 {
                        output += 2.0 * (a2Total / b2Total)
                    }
                    if -1E-08 >= b3Total || b3Total >= 1E-08 {
                        output += a3Total / b3Total
                    }
                    tempLT = inCandle[trailingIdx1][TA_CandleInputType.Low]
                    tempHT = inCandle[trailingIdx1][TA_CandleInputType.High]
                    tempCY = inCandle[trailingIdx1 - 1][TA_CandleInputType.Close]
                    if tempLT < tempCY {
                        num3 = tempLT
                    } else {
                        num3 = tempCY
                    }
                    trueLow = num3
                    closeMinusTrueLow = inCandle[trailingIdx1][TA_CandleInputType.Close] - trueLow
                    trueRange = tempHT - tempLT
                    tempDouble = fabs(tempCY - tempHT)
                    if tempDouble > trueRange {
                        trueRange = tempDouble
                    }
                    tempDouble = fabs(tempCY - tempLT)
                    if tempDouble > trueRange {
                        trueRange = tempDouble
                    }
                    a1Total -= closeMinusTrueLow
                    b1Total -= trueRange
                    tempLT = inCandle[trailingIdx2][TA_CandleInputType.Low]
                    tempHT = inCandle[trailingIdx2][TA_CandleInputType.High]
                    tempCY = inCandle[trailingIdx2 - 1][TA_CandleInputType.Close]
                    if tempLT < tempCY {
                        num2 = tempLT
                    } else {
                        num2 = tempCY
                    }
                    trueLow = num2
                    closeMinusTrueLow = inCandle[trailingIdx2][TA_CandleInputType.Close] - trueLow
                    trueRange = tempHT - tempLT
                    tempDouble = fabs(tempCY - tempHT)
                    if tempDouble > trueRange {
                        trueRange = tempDouble
                    }
                    tempDouble = fabs(tempCY - tempLT)
                    if tempDouble > trueRange {
                        trueRange = tempDouble
                    }
                    a2Total -= closeMinusTrueLow
                    b2Total -= trueRange
                    tempLT = inCandle[trailingIdx3][TA_CandleInputType.Low]
                    tempHT = inCandle[trailingIdx3][TA_CandleInputType.High]
                    tempCY = inCandle[trailingIdx3 - 1][TA_CandleInputType.Close]
                    if tempLT < tempCY {
                        num = tempLT
                    } else {
                        num = tempCY
                    }
                    trueLow = num
                    closeMinusTrueLow = inCandle[trailingIdx3][TA_CandleInputType.Close] - trueLow
                    trueRange = tempHT - tempLT
                    tempDouble = fabs(tempCY - tempHT)
                    if tempDouble > trueRange {
                        trueRange = tempDouble
                    }
                    tempDouble = fabs(tempCY - tempLT)
                    if tempDouble > trueRange {
                        trueRange = tempDouble
                    }
                    a3Total -= closeMinusTrueLow
                    b3Total -= trueRange
                    outDouble[outIdx] = 100.0 * (output / 7.0)
                    outIdx += 1
                    today += 1
                    trailingIdx1 += 1
                    trailingIdx2 += 1
                    trailingIdx3 += 1
                }
                break
            }
            var longestPeriod = 0
            var longestIndex = 0
            for j in stride(from: 0, to: 3, by: 1) {
                if usedFlag[j] == 0 && periods[j] > longestPeriod {
                    longestPeriod = periods[j]
                    longestIndex = j
                }
            }
            usedFlag[longestIndex] = 1
            sortedPeriods[i] = longestPeriod
            i += 1
        }
        
        outElementStartIndex = startIndex
        outElementCount = outIdx
        
        return TA_ReturnCode.Success
    }
    
    public class func lookback(optInTimePeriod1: Int,
                               optInTimePeriod2: Int,
                               optInTimePeriod3: Int) -> Int
    {
        var optInTimePeriod1 = optInTimePeriod1
        var optInTimePeriod2 = optInTimePeriod2
        var optInTimePeriod3 = optInTimePeriod3
        
        if optInTimePeriod1 == Int.min {
            optInTimePeriod1 = self.optInTimePeriod1Default
        } else if optInTimePeriod1 < 1 || optInTimePeriod1 > 100000 {
            return -1
        }
        if optInTimePeriod2 == Int.min {
            optInTimePeriod2 = self.optInTimePeriod2Default
        } else if optInTimePeriod2 < 1 || optInTimePeriod2 > 100000 {
            return -1
        }
        if optInTimePeriod3 == Int.min {
            optInTimePeriod3 = self.optInTimePeriod3Default
        } else if optInTimePeriod3 < 1 || optInTimePeriod3 > 100000 {
            return -1
        }
        
        var maxPeriod: Int
        if ((optInTimePeriod1 <= optInTimePeriod2) ? optInTimePeriod2: optInTimePeriod1) > optInTimePeriod3  {
            maxPeriod = (optInTimePeriod1 <= optInTimePeriod2) ? optInTimePeriod2: optInTimePeriod1
        } else {
            maxPeriod = optInTimePeriod3
        }
        
        return (TA_Sma.lookback(optInTimePeriod: maxPeriod) + 1)
    }
    
    public class func allocationSize(startIndex: Int,
                                     endIndex: Int,
                                     optInTimePeriod1: Int,
                                     optInTimePeriod2: Int,
                                     optInTimePeriod3: Int) -> Int
    {
        let lookback = self.lookback(optInTimePeriod1: optInTimePeriod2,
                                     optInTimePeriod2: optInTimePeriod2,
                                     optInTimePeriod3: optInTimePeriod3)
        let temp = max(lookback, startIndex)
        var allocationSize = 0
        if temp > endIndex {
        } else {
            allocationSize = endIndex - temp + 1
        }
        
        return allocationSize
    }
}




