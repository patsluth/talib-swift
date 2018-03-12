//
//  TA_Ppo.swift
//  ta-lib-swift
//
//  Created by Pat Sluth on 2017-09-18.
//  Copyright © 2017 patsluth. All rights reserved.
//

import Foundation





// PPO - Percentage Price Oscillator
public class TA_Ppo
{
    public static let optInFastPeriodDefault = 12
    public static let optInSlowPeriodDefault = 26
    
    public class func calculate(startIndex: Int,
                                endIndex: Int,
                                inDouble: [Double],
                                optInFastPeriod: Int,
                                optInSlowPeriod: Int,
                                optInMovingAverageType: TA_MovingAverageType,
                                outElementStartIndex: inout Int,
                                outElementCount: inout Int,
                                outDouble: inout [Double]) -> TA_ReturnCode
    {
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
        
        let allocationSize = self.allocationSize(startIndex: startIndex,
                                                 endIndex: endIndex,
                                                 optInFastPeriod: optInFastPeriod,
                                                 optInSlowPeriod: optInSlowPeriod,
                                                 optInMovingAverageType: optInMovingAverageType)
        outDouble = [Double](repeating: Double.nan, count: allocationSize)
        
        return TA_Core.sharedInstance.TA_INT_PO(startIndex: startIndex,
                                                endIndex: endIndex,
                                                inDouble: inDouble,
                                                optInFastPeriod: optInFastPeriod,
                                                optInSlowPeriod: optInSlowPeriod,
                                                optinInMovingAverageType: optInMovingAverageType,
                                                doPercentageOutput: true,
                                                outElementStartIndex: &outElementStartIndex,
                                                outElementCount: &outElementCount,
                                                outDouble: &outDouble)
    }
    
    public class func calculate(startIndex: Int,
                                endIndex: Int,
                                inCandle: [TA_Candle],
                                inCandleInputType: TA_CandleInputType,
                                optInFastPeriod: Int,
                                optInSlowPeriod: Int,
                                optInMovingAverageType: TA_MovingAverageType,
                                outElementStartIndex: inout Int,
                                outElementCount: inout Int,
                                outDouble: inout [Double]) -> TA_ReturnCode
    {
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
        
        let allocationSize = self.allocationSize(startIndex: startIndex,
                                                 endIndex: endIndex,
                                                 optInFastPeriod: optInFastPeriod,
                                                 optInSlowPeriod: optInSlowPeriod,
                                                 optInMovingAverageType: optInMovingAverageType)
        outDouble = [Double](repeating: Double.nan, count: allocationSize)
        
        return TA_Core.sharedInstance.TA_INT_PO(startIndex: startIndex,
                                                endIndex: endIndex,
                                                inCandle: inCandle,
                                                inCandleInputType: inCandleInputType,
                                                optInFastPeriod: optInFastPeriod,
                                                optInSlowPeriod: optInSlowPeriod,
                                                optinInMovingAverageType: optInMovingAverageType,
                                                doPercentageOutput: true,
                                                outElementStartIndex: &outElementStartIndex,
                                                outElementCount: &outElementCount,
                                                outDouble: &outDouble)
    }
    
    public class func lookback(optInFastPeriod: Int,
                               optInSlowPeriod: Int,
                               optInMovingAverageType: TA_MovingAverageType) -> Int
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
        
        return TA_MovingAverage.lookback(optInTimePeriod: (optInSlowPeriod <= optInFastPeriod) ? optInFastPeriod: optInSlowPeriod,
                                         optInMovingAverageType: optInMovingAverageType)
    }
    
    public class func allocationSize(startIndex: Int,
                                     endIndex: Int,
                                     optInFastPeriod: Int,
                                     optInSlowPeriod: Int,
                                     optInMovingAverageType: TA_MovingAverageType) -> Int
    {
        let lookback = self.lookback(optInFastPeriod: optInFastPeriod,
                                     optInSlowPeriod: optInSlowPeriod,
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




