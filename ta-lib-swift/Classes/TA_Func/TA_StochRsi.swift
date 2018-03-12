//
//  TA_StochRsi.swift
//  ta-lib-swift
//
//  Created by Pat Sluth on 2017-09-18.
//  Copyright © 2017 patsluth. All rights reserved.
//

import Foundation





// STOCHRSI - Stochastic Relative Strength Index
public class TA_StochRsi
{
    public static let optInTimePeriodDefault = 14
    public static let optInFastKPeriodDefault = 5
    public static let optInFastDPeriodDefault = 3
    public static let optInFastDPeriodMovingAverageTypeDefault = TA_MovingAverageType.Sma
    
    public class func calculate(startIndex: Int,
                                endIndex: Int,
                                inDouble: [Double],
                                optInTimePeriod: Int,
                                optInFastKPeriod: Int,
                                optInFastDPeriod: Int,
                                optInFastDPeriodMovingAverageType: TA_MovingAverageType,
                                outElementStartIndex: inout Int,
                                outElementCount: inout Int,
                                outFastK: inout [Double],
                                outFastD: inout [Double]) -> TA_ReturnCode
    {
        var startIndex = startIndex
        var optInTimePeriod = optInTimePeriod
        var optInFastKPeriod = optInFastKPeriod
        var optInFastDPeriod = optInFastDPeriod
        
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
        if optInFastKPeriod == Int.min {
            optInFastKPeriod = self.optInFastKPeriodDefault
        } else if optInFastKPeriod < 1 || optInFastKPeriod > 100000 {
            return TA_ReturnCode.BadParam
        }
        if optInFastDPeriod == Int.min {
            optInFastDPeriod = self.optInFastDPeriodDefault
        } else if optInFastDPeriod < 1 || optInFastDPeriod > 100000 {
            return TA_ReturnCode.BadParam
        }
        let lookbackSTOCHF = TA_StochF.lookback(optInFastKPeriod: optInFastKPeriod,
                                                optInFastDPeriod: optInFastDPeriod,
                                                optInFastDPeriodMovingAverageType: optInFastDPeriodMovingAverageType)
        let lookbackTotal = TA_Rsi.lookback(optInTimePeriod: optInTimePeriod) + lookbackSTOCHF
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
                                                 optInTimePeriod: optInTimePeriod,
                                                 optInFastKPeriod: optInFastKPeriod,
                                                 optInFastDPeriod: optInFastDPeriod,
                                                 optInFastDPeriodMovingAverageType: optInFastDPeriodMovingAverageType)
        outFastK = [Double](repeating: Double.nan, count: allocationSize)
        outFastD = [Double](repeating: Double.nan, count: allocationSize)
        
        var outElementCount1 = 0
        var outElementStartIndex1 = 0
        var outElementStartIndex2 = 0
        outElementStartIndex = startIndex
        let tempArraySize = ((endIndex - startIndex) + 1) + lookbackSTOCHF
        var tempRSIBuffer = [Double](repeating: Double.nan, count: tempArraySize)
        var returnCode = TA_Rsi.calculate(startIndex: startIndex - lookbackSTOCHF,
                                          endIndex: endIndex,
                                          inDouble: inDouble,
                                          optInTimePeriod: optInTimePeriod,
                                          outElementStartIndex: &outElementStartIndex1,
                                          outElementCount: &outElementCount1,
                                          outDouble: &tempRSIBuffer)
        if returnCode != TA_ReturnCode.Success || outElementCount1 == 0 {
            outElementStartIndex = 0
            outElementCount = 0
            return returnCode
        }
        returnCode = TA_StochF.calculate(startIndex: 0,
                                         endIndex: tempArraySize - 1,
                                         inHigh: tempRSIBuffer,
                                         inLow: tempRSIBuffer,
                                         inClose: tempRSIBuffer,
                                         optInFastKPeriod: optInFastKPeriod,
                                         optInFastDPeriod: optInFastDPeriod,
                                         optInFastDPeriodMovingAverageType: optInFastDPeriodMovingAverageType,
                                         outElementStartIndex: &outElementStartIndex2,
                                         outElementCount: &outElementCount,
                                         outFastK: &outFastK,
                                         outFastD: &outFastD)
        if returnCode != TA_ReturnCode.Success || outElementCount == 0 {
            outElementStartIndex = 0
            outElementCount = 0
            return returnCode
        }
        
        outElementStartIndex = startIndex
        
        return TA_ReturnCode.Success
    }
    
    public class func calculate(startIndex: Int,
                                endIndex: Int,
                                inCandle: [TA_Candle],
                                inCandleInputType: TA_CandleInputType,
                                optInTimePeriod: Int,
                                optInFastKPeriod: Int,
                                optInFastDPeriod: Int,
                                optInFastDPeriodMovingAverageType: TA_MovingAverageType,
                                outElementStartIndex: inout Int,
                                outElementCount: inout Int,
                                outFastK: inout [Double],
                                outFastD: inout [Double]) -> TA_ReturnCode
    {
        var startIndex = startIndex
        var optInTimePeriod = optInTimePeriod
        var optInFastKPeriod = optInFastKPeriod
        var optInFastDPeriod = optInFastDPeriod
        
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
        if optInFastKPeriod == Int.min {
            optInFastKPeriod = self.optInFastKPeriodDefault
        } else if optInFastKPeriod < 1 || optInFastKPeriod > 100000 {
            return TA_ReturnCode.BadParam
        }
        if optInFastDPeriod == Int.min {
            optInFastDPeriod = self.optInFastDPeriodDefault
        } else if optInFastDPeriod < 1 || optInFastDPeriod > 100000 {
            return TA_ReturnCode.BadParam
        }
        let lookbackSTOCHF = TA_StochF.lookback(optInFastKPeriod: optInFastKPeriod,
                                                optInFastDPeriod: optInFastDPeriod,
                                                optInFastDPeriodMovingAverageType: optInFastDPeriodMovingAverageType)
        let lookbackTotal = TA_Rsi.lookback(optInTimePeriod: optInTimePeriod) + lookbackSTOCHF
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
                                                 optInTimePeriod: optInTimePeriod,
                                                 optInFastKPeriod: optInFastKPeriod,
                                                 optInFastDPeriod: optInFastDPeriod,
                                                 optInFastDPeriodMovingAverageType: optInFastDPeriodMovingAverageType)
        outFastK = [Double](repeating: Double.nan, count: allocationSize)
        outFastD = [Double](repeating: Double.nan, count: allocationSize)
        
        var outElementCount1 = 0
        var outElementStartIndex1 = 0
        var outElementStartIndex2 = 0
        outElementStartIndex = startIndex
        let tempArraySize = ((endIndex - startIndex) + 1) + lookbackSTOCHF
        var tempRSIBuffer = [Double](repeating: Double.nan, count: tempArraySize)
        var returnCode = TA_Rsi.calculate(startIndex: startIndex - lookbackSTOCHF,
                                          endIndex: endIndex,
                                          inCandle: inCandle,
                                          inCandleInputType: inCandleInputType,
                                          optInTimePeriod: optInTimePeriod,
                                          outElementStartIndex: &outElementStartIndex1,
                                          outElementCount: &outElementCount1,
                                          outDouble: &tempRSIBuffer)
        if returnCode != TA_ReturnCode.Success || outElementCount1 == 0 {
            outElementStartIndex = 0
            outElementCount = 0
            return returnCode
        }
        returnCode = TA_StochF.calculate(startIndex: 0,
                                         endIndex: tempArraySize - 1,
                                         inHigh: tempRSIBuffer,
                                         inLow: tempRSIBuffer,
                                         inClose: tempRSIBuffer,
                                         optInFastKPeriod: optInFastKPeriod,
                                         optInFastDPeriod: optInFastDPeriod,
                                         optInFastDPeriodMovingAverageType: optInFastDPeriodMovingAverageType,
                                         outElementStartIndex: &outElementStartIndex2,
                                         outElementCount: &outElementCount,
                                         outFastK: &outFastK,
                                         outFastD: &outFastD)
        if returnCode != TA_ReturnCode.Success || outElementCount == 0 {
            outElementStartIndex = 0
            outElementCount = 0
            return returnCode
        }
        
        outElementStartIndex = startIndex
        
        return TA_ReturnCode.Success
    }
    
    public class func lookback(optInTimePeriod: Int,
                               optInFastKPeriod: Int,
                               optInFastDPeriod: Int,
                               optInFastDPeriodMovingAverageType: TA_MovingAverageType) -> Int
    {
        var optInTimePeriod = optInTimePeriod
        var optInFastKPeriod = optInFastKPeriod
        var optInFastDPeriod = optInFastDPeriod
        
        if optInTimePeriod == Int.min {
            optInTimePeriod = self.optInTimePeriodDefault
        } else if optInTimePeriod < 2 || optInTimePeriod > 100000 {
            return -1
        }
        if optInFastKPeriod == Int.min {
            optInFastKPeriod = self.optInFastKPeriodDefault
        } else if optInFastKPeriod < 1 || optInFastKPeriod > 100000 {
            return -1
        }
        if optInFastDPeriod == Int.min {
            optInFastDPeriod = self.optInFastDPeriodDefault
        } else if optInFastDPeriod < 1 || optInFastDPeriod > 100000 {
            return -1
        }
        
        let returnValue = TA_Rsi.lookback(optInTimePeriod: optInTimePeriod)
        return (returnValue + TA_StochF.lookback(optInFastKPeriod: optInFastKPeriod,
                                                 optInFastDPeriod: optInFastDPeriod,
                                                 optInFastDPeriodMovingAverageType: optInFastDPeriodMovingAverageType))
    }
    
    public class func allocationSize(startIndex: Int,
                                     endIndex: Int,
                                     optInTimePeriod: Int,
                                     optInFastKPeriod: Int,
                                     optInFastDPeriod: Int,
                                     optInFastDPeriodMovingAverageType: TA_MovingAverageType) -> Int
    {
        let lookback = self.lookback(optInTimePeriod: optInTimePeriod,
                                     optInFastKPeriod: optInFastKPeriod,
                                     optInFastDPeriod: optInFastDPeriod,
                                     optInFastDPeriodMovingAverageType: optInFastDPeriodMovingAverageType)
        let temp = max(lookback, startIndex)
        var allocationSize = 0
        if temp > endIndex {
        } else {
            allocationSize = endIndex - temp + 1
        }
        
        return allocationSize
    }
}




