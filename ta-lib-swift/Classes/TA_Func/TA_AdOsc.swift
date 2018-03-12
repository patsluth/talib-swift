//
//  TA_AdOsc.swift
//  ta-lib-swift
//
//  Created by Pat Sluth on 2017-09-18.
//  Copyright © 2017 patsluth. All rights reserved.
//

import Foundation





// ADOSC - Chaikin A/D Oscillator
public class TA_AdOsc
{
	public static let optInFastPeriodDefault = 3
	public static let optInSlowPeriodDefault = 10
    
    public class func calculate(startIndex: Int,
                                endIndex: Int,
                                inHigh: [Double],
                                inLow: [Double],
                                inClose: [Double],
                                inVolume: [Double],
                                optInFastPeriod: Int,
                                optInSlowPeriod: Int,
                                outElementStartIndex: inout Int,
                                outElementCount: inout Int,
                                outDouble: inout [Double]) -> TA_ReturnCode
    {
        var startIndex = startIndex
        var optInFastPeriod = optInFastPeriod
        var optInSlowPeriod = optInSlowPeriod
        
        outElementStartIndex = 0
        outElementCount = 0
        
        if startIndex < 0 {
            return TA_ReturnCode.OutOfRangeStartIndex
        }
        if endIndex < 0 || endIndex < startIndex {
            return TA_ReturnCode.OutOfRangeStartIndex
        }
        if optInFastPeriod == Int.min {
            optInFastPeriod = self.optInFastPeriodDefault
        } else if optInFastPeriod < 2 || optInFastPeriod > 100000 {
            return TA_ReturnCode.BadParam
        }
        if optInSlowPeriod == Int.min {
            optInSlowPeriod = self.optInSlowPeriodDefault
        } else if optInSlowPeriod < 2 || optInSlowPeriod > 100000 {
            return TA_ReturnCode.BadParam
        }
        let lookbackTotal = self.lookback(optInFastPeriod: optInFastPeriod,
                                          optInSlowPeriod: optInSlowPeriod)
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
                                                 optInFastPeriod: optInFastPeriod,
                                                 optInSlowPeriod: optInSlowPeriod)
        outDouble = [Double](repeating: Double.nan, count: allocationSize)
        
        outElementStartIndex = startIndex
        var today = startIndex - lookbackTotal
        var ad = 0.0
        let fastk = 2.0 / (Double(optInFastPeriod + 1))
        let one_minus_fastk = 1.0 - fastk
        let slowk = 2.0 / ((Double)(optInSlowPeriod + 1))
        let one_minus_slowk = 1.0 - slowk
        var high = inHigh[today]
        var low = inLow[today]
        var tmp = high - low
        var close = inClose[today]
        if tmp > 0.0 {
            ad += (((close - low) - (high - close)) / tmp) * inVolume[today]
        }
        today += 1
        var fastEMA = ad
        var slowEMA = ad
        while true {
            if today >= startIndex {
                break
            }
            high = inHigh[today]
            low = inLow[today]
            tmp = high - low
            close = inClose[today]
            if tmp > 0.0 {
                ad += (((close - low) - (high - close)) / tmp) * inVolume[today]
            }
            today += 1
            fastEMA = (fastk * ad) + (one_minus_fastk * fastEMA)
            slowEMA = (slowk * ad) + (one_minus_slowk * slowEMA)
        }
        var outIdx = 0
        while true {
            if today > endIndex {
                break
            }
            high = inHigh[today]
            low = inLow[today]
            tmp = high - low
            close = inClose[today]
            if tmp > 0.0 {
                ad += (((close - low) - (high - close)) / tmp) * inVolume[today]
            }
            today += 1
            fastEMA = (fastk * ad) + (one_minus_fastk * fastEMA)
            slowEMA = (slowk * ad) + (one_minus_slowk * slowEMA)
            outDouble[outIdx] = fastEMA - slowEMA
            outIdx += 1
        }
        
        outElementCount = outIdx
        
        return TA_ReturnCode.Success
    }
    
    public class func calculate(startIndex: Int,
                                endIndex: Int,
                                inCandle: [TA_Candle],
                                optInFastPeriod: Int,
                                optInSlowPeriod: Int,
                                outElementStartIndex: inout Int,
                                outElementCount: inout Int,
                                outDouble: inout [Double]) -> TA_ReturnCode
    {
        var startIndex = startIndex
        var optInFastPeriod = optInFastPeriod
        var optInSlowPeriod = optInSlowPeriod
        
        outElementStartIndex = 0
        outElementCount = 0
        
        if startIndex < 0 {
            return TA_ReturnCode.OutOfRangeStartIndex
        }
        if endIndex < 0 || endIndex < startIndex {
            return TA_ReturnCode.OutOfRangeStartIndex
        }
        if optInFastPeriod == Int.min {
            optInFastPeriod = self.optInFastPeriodDefault
        } else if optInFastPeriod < 2 || optInFastPeriod > 100000 {
            return TA_ReturnCode.BadParam
        }
        if optInSlowPeriod == Int.min {
            optInSlowPeriod = self.optInSlowPeriodDefault
        } else if optInSlowPeriod < 2 || optInSlowPeriod > 100000 {
            return TA_ReturnCode.BadParam
        }
        let lookbackTotal = self.lookback(optInFastPeriod: optInFastPeriod,
                                          optInSlowPeriod: optInSlowPeriod)
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
                                                 optInFastPeriod: optInFastPeriod,
                                                 optInSlowPeriod: optInSlowPeriod)
        outDouble = [Double](repeating: Double.nan, count: allocationSize)
        
        outElementStartIndex = startIndex
        var today = startIndex - lookbackTotal
        var ad = 0.0
        let fastk = 2.0 / (Double(optInFastPeriod + 1))
        let one_minus_fastk = 1.0 - fastk
        let slowk = 2.0 / ((Double)(optInSlowPeriod + 1))
        let one_minus_slowk = 1.0 - slowk
        var high = inCandle[today][TA_CandleInputType.High]
        var low = inCandle[today][TA_CandleInputType.Low]
        var tmp = high - low
        var close = inCandle[today][TA_CandleInputType.Close]
        if tmp > 0.0 {
            ad += (((close - low) - (high - close)) / tmp) * inCandle[today][TA_CandleInputType.Volume]
        }
        today += 1
        var fastEMA = ad
        var slowEMA = ad
        while true {
            if today >= startIndex {
                break
            }
            high = inCandle[today][TA_CandleInputType.High]
            low = inCandle[today][TA_CandleInputType.Low]
            tmp = high - low
            close = inCandle[today][TA_CandleInputType.Close]
            if tmp > 0.0 {
                ad += (((close - low) - (high - close)) / tmp) * inCandle[today][TA_CandleInputType.Volume]
            }
            today += 1
            fastEMA = (fastk * ad) + (one_minus_fastk * fastEMA)
            slowEMA = (slowk * ad) + (one_minus_slowk * slowEMA)
        }
        var outIdx = 0
        while true {
            if today > endIndex {
                break
            }
            high = inCandle[today][TA_CandleInputType.High]
            low = inCandle[today][TA_CandleInputType.Low]
            tmp = high - low
            close = inCandle[today][TA_CandleInputType.Close]
            if tmp > 0.0 {
                ad += (((close - low) - (high - close)) / tmp) * inCandle[today][TA_CandleInputType.Volume]
            }
            today += 1
            fastEMA = (fastk * ad) + (one_minus_fastk * fastEMA)
            slowEMA = (slowk * ad) + (one_minus_slowk * slowEMA)
            outDouble[outIdx] = fastEMA - slowEMA
            outIdx += 1
        }
        
        outElementCount = outIdx
        
        return TA_ReturnCode.Success
    }
    
    public class func lookback(optInFastPeriod: Int,
                               optInSlowPeriod: Int) -> Int
    {
        var optInFastPeriod = optInFastPeriod
        var optInSlowPeriod = optInSlowPeriod
        
        if optInFastPeriod == Int.min {
            optInFastPeriod = self.optInFastPeriodDefault
        } else if optInFastPeriod < 2 || optInFastPeriod > 100000 {
            return -1
        }
        if optInSlowPeriod == Int.min {
            optInSlowPeriod = self.optInSlowPeriodDefault
        } else if optInSlowPeriod < 2 || optInSlowPeriod > 100000 {
            return -1
        }
        
        if optInFastPeriod < optInSlowPeriod {
            return TA_Ema.lookback(optInTimePeriod: optInSlowPeriod)
        } else {
            return TA_Ema.lookback(optInTimePeriod: optInFastPeriod)
        }
    }
    
    public class func allocationSize(startIndex: Int,
                                     endIndex: Int,
                                     optInFastPeriod: Int,
                                     optInSlowPeriod: Int) -> Int
    {
        let lookback = self.lookback(optInFastPeriod: optInFastPeriod,
                                     optInSlowPeriod: optInSlowPeriod)
        let temp = max(lookback, startIndex)
        var allocationSize = 0
        if temp > endIndex {
        } else {
            allocationSize = endIndex - temp + 1
        }
        
        return allocationSize
    }
}




