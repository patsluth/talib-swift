//
//  TA_Macd.swift
//  ta-lib-swift
//
//  Created by Pat Sluth on 2017-09-18.
//  Copyright © 2017 patsluth. All rights reserved.
//

import Foundation





// MACD - Moving Average Convergence/Divergences
public class TA_Macd
{
    public static let optInFastPeriodDefault = 12
    public static let optInSlowPeriodDefault = 26
    public static let optInSignalPeriodDefault = 9
    
    public class func calculate(startIndex: Int,
                                endIndex: Int,
                                inDouble: [Double],
                                optInFastPeriod: Int,
                                optInSlowPeriod: Int,
                                optInSignalPeriod: Int,
                                outElementStartIndex: inout Int,
                                outElementCount: inout Int,
                                outMACD: inout [Double],
                                outMACDSignal: inout [Double],
                                outMACDHist: inout [Double]) -> TA_ReturnCode
    {
        var optInFastPeriod = optInFastPeriod
        var optInSlowPeriod = optInSlowPeriod
        var optInSignalPeriod = optInSignalPeriod
        
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
        if optInSignalPeriod == Int.min {
            optInSignalPeriod = self.optInSignalPeriodDefault
        } else if optInSignalPeriod < 1 || optInSignalPeriod > 100000 {
            return TA_ReturnCode.BadParam
        }
        
        let allocationSize = self.allocationSize(startIndex: startIndex,
                                                 endIndex: endIndex,
                                                 optInFastPeriod: optInFastPeriod,
                                                 optInSlowPeriod: optInSlowPeriod,
                                                 optInSignalPeriod: optInSignalPeriod)
        outMACD = [Double](repeating: Double.nan, count: allocationSize)
        outMACDSignal = [Double](repeating: Double.nan, count: allocationSize)
        outMACDHist = [Double](repeating: Double.nan, count: allocationSize)
        
        return TA_Core.sharedInstance.TA_INT_MACD(startIndex: startIndex,
                                                  endIndex: endIndex,
                                                  inDouble: inDouble,
                                                  optInFastPeriod: optInFastPeriod,
                                                  optInSlowPeriod: optInSlowPeriod,
                                                  optInSignalPeriod: optInSignalPeriod,
                                                  outElementStartIndex: &outElementStartIndex,
                                                  outElementCount: &outElementCount,
                                                  outMACD: &outMACD,
                                                  outMACDSignal: &outMACDSignal,
                                                  outMACDHist: &outMACDHist)
    }
    
    public class func calculate(startIndex: Int,
                                endIndex: Int,
                                inCandle: [TA_Candle],
                                inCandleInputType: TA_CandleInputType,
                                optInFastPeriod: Int,
                                optInSlowPeriod: Int,
                                optInSignalPeriod: Int,
                                outElementStartIndex: inout Int,
                                outElementCount: inout Int,
                                outMACD: inout [Double],
                                outMACDSignal: inout [Double],
                                outMACDHist: inout [Double]) -> TA_ReturnCode
    {
        var optInFastPeriod = optInFastPeriod
        var optInSlowPeriod = optInSlowPeriod
        var optInSignalPeriod = optInSignalPeriod
        
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
        if optInSignalPeriod == Int.min {
            optInSignalPeriod = self.optInSignalPeriodDefault
        } else if optInSignalPeriod < 1 || optInSignalPeriod > 100000 {
            return TA_ReturnCode.BadParam
        }
        
        let allocationSize = self.allocationSize(startIndex: startIndex,
                                                 endIndex: endIndex,
                                                 optInFastPeriod: optInFastPeriod,
                                                 optInSlowPeriod: optInSlowPeriod,
                                                 optInSignalPeriod: optInSignalPeriod)
        outMACD = [Double](repeating: Double.nan, count: allocationSize)
        outMACDSignal = [Double](repeating: Double.nan, count: allocationSize)
        outMACDHist = [Double](repeating: Double.nan, count: allocationSize)
        
        return TA_Core.sharedInstance.TA_INT_MACD(startIndex: startIndex,
                                                  endIndex: endIndex,
                                                  inCandle: inCandle,
                                                  inCandleInputType: inCandleInputType,
                                                  optInFastPeriod: optInFastPeriod,
                                                  optInSlowPeriod: optInSlowPeriod,
                                                  optInSignalPeriod: optInSignalPeriod,
                                                  outElementStartIndex: &outElementStartIndex,
                                                  outElementCount: &outElementCount,
                                                  outMACD: &outMACD,
                                                  outMACDSignal: &outMACDSignal,
                                                  outMACDHist: &outMACDHist)
    }
    
    public class func lookback(optInFastPeriod: Int,
                               optInSlowPeriod: Int,
                               optInSignalPeriod: Int) -> Int
    {
        var optInFastPeriod = optInFastPeriod
        var optInSlowPeriod = optInSlowPeriod
        var optInSignalPeriod = optInSignalPeriod
        
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
        if optInSignalPeriod == Int.min {
            optInSignalPeriod = self.optInSignalPeriodDefault
        } else if optInSignalPeriod < 1 || optInSignalPeriod > 100000 {
            return -1
        }
        if optInSlowPeriod < optInFastPeriod {
            let temp = optInSlowPeriod
            optInSlowPeriod = optInFastPeriod
            optInFastPeriod = temp
        }
        
        return TA_Ema.lookback(optInTimePeriod: optInSlowPeriod) + TA_Ema.lookback(optInTimePeriod: optInSignalPeriod)
    }
    
    public class func allocationSize(startIndex: Int,
                                     endIndex: Int,
                                     optInFastPeriod: Int,
                                     optInSlowPeriod: Int,
                                     optInSignalPeriod: Int) -> Int
    {
        let lookback = self.lookback(optInFastPeriod: optInFastPeriod,
                                     optInSlowPeriod: optInSlowPeriod,
                                     optInSignalPeriod: optInSignalPeriod)
        let temp = max(lookback, startIndex)
        var allocationSize = 0
        if temp > endIndex {
        } else {
            allocationSize = endIndex - temp + 1
        }
        
        return allocationSize
    }
}




