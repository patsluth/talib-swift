//
//  TA_Variance.swift
//  ta-lib-swift
//
//  Created by Pat Sluth on 2017-09-18.
//  Copyright © 2017 patsluth. All rights reserved.
//

import Foundation





// VAR - Variance
public class TA_Variance
{
    public static let optInTimePeriodDefault = 5
    public static let optInDeviationDefault = 1.0
    
    public class func calculate(startIndex: Int,
                                endIndex: Int,
                                inDouble: [Double],
                                optInTimePeriod: Int,
                                optInDeviation: Double,
                                outElementStartIndex: inout Int,
                                outElementCount: inout Int,
                                outDouble: inout [Double]) -> TA_ReturnCode
    {
        var optInTimePeriod = optInTimePeriod
        var optInDeviation = optInDeviation
        
        outElementStartIndex = 0
        outElementCount = 0
        outDouble.removeAll()
        
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
        if optInDeviation == -4E+37 {
            optInDeviation = self.optInDeviationDefault
        } else if optInDeviation < -3E+37 || optInDeviation > 3E+37 {
            return TA_ReturnCode.BadParam
        }
        
        return TA_Core.sharedInstance.TA_INT_VAR(startIndex: startIndex,
                                                 endIndex: endIndex,
                                                 inDouble: inDouble,
                                                 optInTimePeriod: optInTimePeriod,
                                                 outElementStartIndex: &outElementStartIndex,
                                                 outElementCount: &outElementCount,
                                                 outDouble: &outDouble)
    }
    
    public class func calculate(startIndex: Int,
                                endIndex: Int,
                                inCandle: [TA_Candle],
                                inCandleInputType: TA_CandleInputType,
                                optInTimePeriod: Int,
                                optInDeviation: Double,
                                outElementStartIndex: inout Int,
                                outElementCount: inout Int,
                                outDouble: inout [Double]) -> TA_ReturnCode
    {
        var startIndex = startIndex
        var optInTimePeriod = optInTimePeriod
        var optInDeviation = optInDeviation
        
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
        if optInDeviation == -4E+37 {
            optInDeviation = self.optInDeviationDefault
        } else if optInDeviation < -3E+37 || optInDeviation > 3E+37 {
            return TA_ReturnCode.BadParam
        }
        
        let allocationSize = self.allocationSize(startIndex: startIndex,
                                                 endIndex: endIndex,
                                                 optInTimePeriod: optInTimePeriod,
                                                 optInDeviation: optInDeviation)
        outDouble = [Double](repeating: Double.nan, count: allocationSize)
        
        return TA_Core.sharedInstance.TA_INT_VAR(startIndex: startIndex,
                                                 endIndex: endIndex,
                                                 inCandle: inCandle,
                                                 inCandleInputType: inCandleInputType,
                                                 optInTimePeriod: optInTimePeriod,
                                                 outElementStartIndex: &outElementStartIndex,
                                                 outElementCount: &outElementCount,
                                                 outDouble: &outDouble)
    }
    
    public class func lookback(optInTimePeriod: Int,
                               optInDeviation: Double) -> Int
    {
        var optInTimePeriod = optInTimePeriod
        var optInDeviation = optInDeviation
        
        if optInTimePeriod == Int.min {
            optInTimePeriod = self.optInTimePeriodDefault
        } else if optInTimePeriod < 2 || optInTimePeriod > 100000 {
            return -1
        }
        if optInDeviation == -4E+37 {
            optInDeviation = self.optInDeviationDefault
        } else if optInDeviation < -3E+37 || optInDeviation > 3E+37 {
            return -1
        }
        
        return (optInTimePeriod - 1)
    }
    
    public class func allocationSize(startIndex: Int,
                                     endIndex: Int,
                                     optInTimePeriod: Int,
                                     optInDeviation: Double) -> Int
    {
        let lookback = self.lookback(optInTimePeriod: optInTimePeriod,
                                     optInDeviation: optInDeviation)
        let temp = max(lookback, startIndex)
        var allocationSize = 0
        if temp > endIndex {
        } else {
            allocationSize = endIndex - temp + 1
        }
        
        return allocationSize
    }
}




