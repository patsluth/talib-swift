//
//  TA_MacdFix.swift
//  ta-lib-swift
//
//  Created by Pat Sluth on 2017-09-18.
//  Copyright © 2017 patsluth. All rights reserved.
//

import Foundation





// MACDFIX - Moving Average Convergence/Divergence Fix 12/26
public class TA_MacdFix
{
    public class func calculate(startIndex: Int,
                                endIndex: Int,
                                inDouble: [Double],
                                optInSignalPeriod: Int,
                                outElementStartIndex: inout Int,
                                outElementCount: inout Int,
                                outMACD: inout [Double],
                                outMACDSignal: inout [Double],
                                outMACDHist: inout [Double]) -> TA_ReturnCode
    {
        var optInSignalPeriod = optInSignalPeriod
        
        outElementStartIndex = 0
        outElementCount = 0
        
        if startIndex < 0 {
            return TA_ReturnCode.OutOfRangeStartIndex
        }
        if endIndex < 0 || endIndex < startIndex {
            return TA_ReturnCode.OutOfRangeStartIndex
        }
         if optInSignalPeriod == Int.min {
            optInSignalPeriod = TA_Macd.optInSignalPeriodDefault
        } else if optInSignalPeriod < 1 || optInSignalPeriod > 100000 {
            return TA_ReturnCode.BadParam
        }
        
        let allocationSize = self.allocationSize(startIndex: startIndex,
                                                 endIndex: endIndex,
                                                 optInSignalPeriod: optInSignalPeriod)
        outMACD = [Double](repeating: Double.nan, count: allocationSize)
        outMACDSignal = [Double](repeating: Double.nan, count: allocationSize)
        outMACDHist = [Double](repeating: Double.nan, count: allocationSize)
        
        return TA_Core.sharedInstance.TA_INT_MACD(startIndex: startIndex,
                                                  endIndex: endIndex,
                                                  inDouble: inDouble,
                                                  optInFastPeriod: 0,
                                                  optInSlowPeriod: 0,
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
                                optInSignalPeriod: Int,
                                outElementStartIndex: inout Int,
                                outElementCount: inout Int,
                                outMACD: inout [Double],
                                outMACDSignal: inout [Double],
                                outMACDHist: inout [Double]) -> TA_ReturnCode
    {
        var optInSignalPeriod = optInSignalPeriod
        
        outElementStartIndex = 0
        outElementCount = 0
        
        if startIndex < 0 {
            return TA_ReturnCode.OutOfRangeStartIndex
        }
        if endIndex < 0 || endIndex < startIndex {
            return TA_ReturnCode.OutOfRangeStartIndex
        }
        if optInSignalPeriod == Int.min {
            optInSignalPeriod = TA_Macd.optInSignalPeriodDefault
        } else if optInSignalPeriod < 1 || optInSignalPeriod > 100000 {
            return TA_ReturnCode.BadParam
        }
        
        let allocationSize = self.allocationSize(startIndex: startIndex,
                                                 endIndex: endIndex,
                                                 optInSignalPeriod: optInSignalPeriod)
        outMACD = [Double](repeating: Double.nan, count: allocationSize)
        outMACDSignal = [Double](repeating: Double.nan, count: allocationSize)
        outMACDHist = [Double](repeating: Double.nan, count: allocationSize)
        
        return TA_Core.sharedInstance.TA_INT_MACD(startIndex: startIndex,
                                                  endIndex: endIndex,
                                                  inCandle: inCandle,
                                                  inCandleInputType: inCandleInputType,
                                                  optInFastPeriod: 0,
                                                  optInSlowPeriod: 0,
                                                  optInSignalPeriod: optInSignalPeriod,
                                                  outElementStartIndex: &outElementStartIndex,
                                                  outElementCount: &outElementCount,
                                                  outMACD: &outMACD,
                                                  outMACDSignal: &outMACDSignal,
                                                  outMACDHist: &outMACDHist)
    }
    
    public class func lookback(optInSignalPeriod: Int) -> Int
    {
        var optInSignalPeriod = optInSignalPeriod
        
        if optInSignalPeriod == Int.min {
            optInSignalPeriod = TA_Macd.optInSignalPeriodDefault
        } else if optInSignalPeriod < 1 || optInSignalPeriod > 100000 {
            return -1
        }
        
        return TA_Ema.lookback(optInTimePeriod: TA_Macd.optInSlowPeriodDefault) + TA_Ema.lookback(optInTimePeriod: optInSignalPeriod)
    }
    
    public class func allocationSize(startIndex: Int,
                                     endIndex: Int,
                                     optInSignalPeriod: Int) -> Int
    {
        let lookback = self.lookback(optInSignalPeriod: optInSignalPeriod)
        let temp = max(lookback, startIndex)
        var allocationSize = 0
        if temp > endIndex {
        } else {
            allocationSize = endIndex - temp + 1
        }
        
        return allocationSize
    }
}




