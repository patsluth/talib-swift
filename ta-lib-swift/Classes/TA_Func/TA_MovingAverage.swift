//
//  TA_MovingAverage.swift
//  ta-lib-swift
//
//  Created by Pat Sluth on 2017-09-18.
//  Copyright © 2017 patsluth. All rights reserved.
//

import Foundation





public class TA_MovingAverage
{
    public static let optInTimePeriodDefault = 30
    
    public class func calculate(startIndex: Int,
                                endIndex: Int,
                                inDouble: [Double],
                                optInTimePeriod: Int,
                                optInMovingAverageType: TA_MovingAverageType,
                                outElementStartIndex: inout Int,
                                outElementCount: inout Int,
                                outDouble: inout [Double]) -> TA_ReturnCode
    {
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
        } else if optInTimePeriod < 1 || optInTimePeriod > 100000 {
            return TA_ReturnCode.BadParam
        }
        
        let allocationSize = self.allocationSize(startIndex: startIndex,
                                                 endIndex: endIndex,
                                                 optInTimePeriod: optInTimePeriod,
                                                 optInMovingAverageType: optInMovingAverageType)
        outDouble = [Double](repeating: Double.nan, count: allocationSize)
        
        if optInTimePeriod != 1 {
            switch optInMovingAverageType {
            case TA_MovingAverageType.Sma:
                return TA_Sma.calculate(startIndex: startIndex,
                                        endIndex: endIndex,
                                        inDouble: inDouble,
                                        optInTimePeriod: optInTimePeriod,
                                        outElementStartIndex: &outElementStartIndex,
                                        outElementCount: &outElementCount,
                                        outDouble: &outDouble)
            case TA_MovingAverageType.Ema:
                return TA_Ema.calculate(startIndex: startIndex,
                                        endIndex: endIndex,
                                        inDouble: inDouble,
                                        optInTimePeriod: optInTimePeriod,
                                        outElementStartIndex: &outElementStartIndex,
                                        outElementCount: &outElementCount,
                                        outDouble: &outDouble)
            case TA_MovingAverageType.Wma:
                return TA_Wma.calculate(startIndex: startIndex,
                                        endIndex: endIndex,
                                        inDouble: inDouble,
                                        optInTimePeriod: optInTimePeriod,
                                        outElementStartIndex: &outElementStartIndex,
                                        outElementCount: &outElementCount,
                                        outDouble: &outDouble)
            case TA_MovingAverageType.Dema:
                return TA_Dema.calculate(startIndex: startIndex,
                                         endIndex: endIndex,
                                         inDouble: inDouble,
                                         optInTimePeriod: optInTimePeriod,
                                         outElementStartIndex: &outElementStartIndex,
                                         outElementCount: &outElementCount,
                                         outDouble: &outDouble)
            case TA_MovingAverageType.Tema:
                return TA_Tema.calculate(startIndex: startIndex,
                                         endIndex: endIndex,
                                         inDouble: inDouble,
                                         optInTimePeriod: optInTimePeriod,
                                         outElementStartIndex: &outElementStartIndex,
                                         outElementCount: &outElementCount,
                                         outDouble: &outDouble)
            case TA_MovingAverageType.Trima:
                return TA_Trima.calculate(startIndex: startIndex,
                                          endIndex: endIndex,
                                          inDouble: inDouble,
                                          optInTimePeriod: optInTimePeriod,
                                          outElementStartIndex: &outElementStartIndex,
                                          outElementCount: &outElementCount,
                                          outDouble: &outDouble)
            case TA_MovingAverageType.Kama:
                return TA_Kama.calculate(startIndex: startIndex,
                                         endIndex: endIndex,
                                         inDouble: inDouble,
                                         optInTimePeriod: optInTimePeriod,
                                         outElementStartIndex: &outElementStartIndex,
                                         outElementCount: &outElementCount,
                                         outDouble: &outDouble)
            case TA_MovingAverageType.Mama:
                var dummyBuffer = [Double]()
                return TA_Mama.calculate(startIndex: startIndex,
                                         endIndex: endIndex,
                                         inDouble: inDouble,
                                         optInFastLimit: TA_Mama.optInFastLimitDefault,
                                         optInSlowLimit: TA_Mama.optInSlowLimitDefault,
                                         outElementStartIndex: &outElementStartIndex,
                                         outElementCount: &outElementCount,
                                         outMAMA: &outDouble,
                                         outFAMA: &dummyBuffer)
            case TA_MovingAverageType.T3:
                return TA_T3.calculate(startIndex: startIndex,
                                       endIndex: endIndex,
                                       inDouble: inDouble,
                                       optInTimePeriod: optInTimePeriod,
                                       optInVFactor: TA_T3.optInVFactorDefault,
                                       outElementStartIndex: &outElementStartIndex,
                                       outElementCount: &outElementCount,
                                       outDouble: &outDouble)
            }
        }
        
        return TA_ReturnCode.Success
    }
    
    public class func calculate(startIndex: Int,
                                endIndex: Int,
                                inCandle: [TA_Candle],
                                inCandleInputType: TA_CandleInputType,
                                optInTimePeriod: Int,
                                optInMovingAverageType: TA_MovingAverageType,
                                outElementStartIndex: inout Int,
                                outElementCount: inout Int,
                                outDouble: inout [Double]) -> TA_ReturnCode
    {
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
        } else if optInTimePeriod < 1 || optInTimePeriod > 100000 {
            return TA_ReturnCode.BadParam
        }
        
        let allocationSize = self.allocationSize(startIndex: startIndex,
                                                 endIndex: endIndex,
                                                 optInTimePeriod: optInTimePeriod,
                                                 optInMovingAverageType: optInMovingAverageType)
        outDouble = [Double](repeating: Double.nan, count: allocationSize)
        
        if optInTimePeriod != 1 {
            switch optInMovingAverageType {
            case TA_MovingAverageType.Sma:
                return TA_Sma.calculate(startIndex: startIndex,
                                        endIndex: endIndex,
                                        inCandle: inCandle,
                                        inCandleInputType: inCandleInputType,
                                        optInTimePeriod: optInTimePeriod,
                                        outElementStartIndex: &outElementStartIndex,
                                        outElementCount: &outElementCount,
                                        outDouble: &outDouble)
            case TA_MovingAverageType.Ema:
                return TA_Ema.calculate(startIndex: startIndex,
                                        endIndex: endIndex,
                                        inCandle: inCandle,
                                        inCandleInputType: inCandleInputType,
                                        optInTimePeriod: optInTimePeriod,
                                        outElementStartIndex: &outElementStartIndex,
                                        outElementCount: &outElementCount,
                                        outDouble: &outDouble)
            case TA_MovingAverageType.Wma:
                return TA_Wma.calculate(startIndex: startIndex,
                                        endIndex: endIndex,
                                        inCandle: inCandle,
                                        inCandleInputType: inCandleInputType,
                                        optInTimePeriod: optInTimePeriod,
                                        outElementStartIndex: &outElementStartIndex,
                                        outElementCount: &outElementCount,
                                        outDouble: &outDouble)
            case TA_MovingAverageType.Dema:
                return TA_Dema.calculate(startIndex: startIndex,
                                         endIndex: endIndex,
                                         inCandle: inCandle,
                                         inCandleInputType: inCandleInputType,
                                         optInTimePeriod: optInTimePeriod,
                                         outElementStartIndex: &outElementStartIndex,
                                         outElementCount: &outElementCount,
                                         outDouble: &outDouble)
            case TA_MovingAverageType.Tema:
                return TA_Tema.calculate(startIndex: startIndex,
                                         endIndex: endIndex,
                                         inCandle: inCandle,
                                         inCandleInputType: inCandleInputType,
                                         optInTimePeriod: optInTimePeriod,
                                         outElementStartIndex: &outElementStartIndex,
                                         outElementCount: &outElementCount,
                                         outDouble: &outDouble)
            case TA_MovingAverageType.Trima:
                return TA_Trima.calculate(startIndex: startIndex,
                                          endIndex: endIndex,
                                          inCandle: inCandle,
                                          inCandleInputType: inCandleInputType,
                                          optInTimePeriod: optInTimePeriod,
                                          outElementStartIndex: &outElementStartIndex,
                                          outElementCount: &outElementCount,
                                          outDouble: &outDouble)
            case TA_MovingAverageType.Kama:
                return TA_Kama.calculate(startIndex: startIndex,
                                         endIndex: endIndex,
                                         inCandle: inCandle,
                                         inCandleInputType: inCandleInputType,
                                         optInTimePeriod: optInTimePeriod,
                                         outElementStartIndex: &outElementStartIndex,
                                         outElementCount: &outElementCount,
                                         outDouble: &outDouble)
            case TA_MovingAverageType.Mama:
                var dummyBuffer = [Double]()
                return TA_Mama.calculate(startIndex: startIndex,
                                         endIndex: endIndex,
                                         inCandle: inCandle,
                                         inCandleInputType: inCandleInputType,
                                         optInFastLimit: TA_Mama.optInFastLimitDefault,
                                         optInSlowLimit: TA_Mama.optInSlowLimitDefault,
                                         outElementStartIndex: &outElementStartIndex,
                                         outElementCount: &outElementCount,
                                         outMAMA: &outDouble,
                                         outFAMA: &dummyBuffer)
            case TA_MovingAverageType.T3:
                return TA_T3.calculate(startIndex: startIndex,
                                       endIndex: endIndex,
                                       inCandle: inCandle,
                                       inCandleInputType: inCandleInputType,
                                       optInTimePeriod: optInTimePeriod,
                                       optInVFactor: TA_T3.optInVFactorDefault,
                                       outElementStartIndex: &outElementStartIndex,
                                       outElementCount: &outElementCount,
                                       outDouble: &outDouble)
            }
        }
        
        return TA_ReturnCode.Success
    }
    
    public class func lookback(optInTimePeriod: Int,
                               optInMovingAverageType: TA_MovingAverageType) -> Int
    {
        var optInTimePeriod = optInTimePeriod
        
        if optInTimePeriod == Int.min {
            optInTimePeriod = self.optInTimePeriodDefault
        } else if optInTimePeriod < 1 || optInTimePeriod > 100000 {
            return -1
        }
        
        if optInTimePeriod > 1 {
            switch optInMovingAverageType {
            case TA_MovingAverageType.Sma:
                return TA_Sma.lookback(optInTimePeriod: optInTimePeriod)
            case TA_MovingAverageType.Ema:
                return TA_Ema.lookback(optInTimePeriod: optInTimePeriod)
            case TA_MovingAverageType.Wma:
                return TA_Wma.lookback(optInTimePeriod: optInTimePeriod)
            case TA_MovingAverageType.Dema:
                return TA_Dema.lookback(optInTimePeriod: optInTimePeriod)
            case TA_MovingAverageType.Tema:
                return TA_Tema.lookback(optInTimePeriod: optInTimePeriod)
            case TA_MovingAverageType.Trima:
                return TA_Trima.lookback(optInTimePeriod: optInTimePeriod)
            case TA_MovingAverageType.Kama:
                return TA_Kama.lookback(optInTimePeriod: optInTimePeriod)
            case TA_MovingAverageType.Mama:
                return TA_Mama.lookback(optInFastLimit: TA_Mama.optInFastLimitDefault,
                                        optInSlowLimit: TA_Mama.optInSlowLimitDefault)
            case TA_MovingAverageType.T3:
                return TA_T3.lookback(optInTimePeriod: optInTimePeriod,
                                      optInVFactor: TA_T3.optInVFactorDefault)
            }
        }
        
        return 0
    }
    
    public class func allocationSize(startIndex: Int,
                                     endIndex: Int,
                                     optInTimePeriod: Int,
                                     optInMovingAverageType: TA_MovingAverageType) -> Int
    {
        switch optInMovingAverageType {
        case TA_MovingAverageType.Sma:
            return TA_Sma.allocationSize(startIndex: startIndex,
                                         endIndex: endIndex,
                                         optInTimePeriod: optInTimePeriod)
        case TA_MovingAverageType.Ema:
            return TA_Ema.allocationSize(startIndex: startIndex,
                                         endIndex: endIndex,
                                         optInTimePeriod: optInTimePeriod)
        case TA_MovingAverageType.Wma:
            return TA_Wma.allocationSize(startIndex: startIndex,
                                         endIndex: endIndex,
                                         optInTimePeriod: optInTimePeriod)
        case TA_MovingAverageType.Dema:
            return TA_Dema.allocationSize(startIndex: startIndex,
                                          endIndex: endIndex,
                                          optInTimePeriod: optInTimePeriod)
        case TA_MovingAverageType.Tema:
            return TA_Tema.allocationSize(startIndex: startIndex,
                                          endIndex: endIndex,
                                          optInTimePeriod: optInTimePeriod)
        case TA_MovingAverageType.Trima:
            return TA_Trima.allocationSize(startIndex: startIndex,
                                           endIndex: endIndex,
                                           optInTimePeriod: optInTimePeriod)
        case TA_MovingAverageType.Kama:
            return TA_Kama.allocationSize(startIndex: startIndex,
                                          endIndex: endIndex,
                                          optInTimePeriod: optInTimePeriod)
        case TA_MovingAverageType.Mama:
            return TA_Mama.allocationSize(startIndex: startIndex,
                                          endIndex: endIndex,
                                          optInFastLimit: TA_Mama.optInFastLimitDefault,
                                          optInSlowLimit: TA_Mama.optInSlowLimitDefault)
        case TA_MovingAverageType.T3:
            return TA_T3.allocationSize(startIndex: startIndex,
                                        endIndex: endIndex,
                                        optInTimePeriod: optInTimePeriod,
                                        optInVFactor: TA_T3.optInVFactorDefault)
        }
    }
}




