//
//  TA_MovingAverageVariablePeriod.swift
//  ta-lib-swift
//
//  Created by Pat Sluth on 2017-09-18.
//  Copyright © 2017 patsluth. All rights reserved.
//

import Foundation





public class TA_MovingAverageVariablePeriod
{
    public static let optInMinPeriodDefault = 30
    public static let optInMaxPeriodDefault = 30
    
    public class func calculate(startIndex: Int,
                                endIndex: Int,
                                inDouble: [Double],
                                inPeriods: [Double],
                                optInMinPeriod: Int,
                                optInMaxPeriod: Int,
                                optInMovingAverageType: TA_MovingAverageType,
                                outElementStartIndex: inout Int,
                                outElementCount: inout Int,
                                outDouble: inout [Double]) -> TA_ReturnCode
    {
        var startIndex = startIndex
        var optInMinPeriod = optInMinPeriod
        var optInMaxPeriod = optInMaxPeriod
        
        outElementStartIndex = 0
        outElementCount = 0
        
        if startIndex < 0 {
            return TA_ReturnCode.OutOfRangeStartIndex
        }
        if endIndex < 0 || endIndex < startIndex {
            return TA_ReturnCode.OutOfRangeStartIndex
        }
        if optInMinPeriod == Int.min {
            optInMinPeriod = self.optInMinPeriodDefault
        } else if optInMinPeriod < 2 || optInMinPeriod > 100000 {
            return TA_ReturnCode.BadParam
        }
        if optInMaxPeriod == Int.min {
            optInMaxPeriod = self.optInMaxPeriodDefault
        } else if optInMaxPeriod < 2 || optInMaxPeriod > 100000 {
            return TA_ReturnCode.BadParam
        }
        let lookbackTotal = self.lookback(optInMinPeriod: optInMinPeriod,
                                          optInMaxPeriod: optInMaxPeriod,
                                          optInMovingAverageType: optInMovingAverageType)
        if startIndex < lookbackTotal {
            startIndex = lookbackTotal
        }
        if startIndex > endIndex {
            outElementStartIndex = 0
            outElementCount = 0
            return TA_ReturnCode.Success
        }
        var tempInt: Int
        if lookbackTotal > startIndex {
            tempInt = lookbackTotal
        } else {
            tempInt = startIndex
        }
        if tempInt > endIndex {
            outElementStartIndex = 0
            outElementCount = 0
            return TA_ReturnCode.Success
        }
        let outputSize = (endIndex - tempInt) + 1
        var localOutputArray = [Double](repeating: 0.0, count: outputSize)
        var localPeriodArray = [Int](repeating: 0, count: outputSize)
        for i in stride(from: 0, to: outputSize, by: 1) {
            tempInt = Int(inPeriods[startIndex + i])
            if tempInt < optInMinPeriod {
                tempInt = optInMinPeriod
            } else if tempInt > optInMaxPeriod {
                tempInt = optInMaxPeriod
            }
            localPeriodArray[i] = tempInt
        }
        
        let allocationSize = self.allocationSize(startIndex: startIndex,
                                                 endIndex: endIndex,
                                                 optInMinPeriod: optInMinPeriod,
                                                 optInMaxPeriod: optInMaxPeriod,
                                                 optInMovingAverageType: optInMovingAverageType)
        outDouble = [Double](repeating: Double.nan, count: allocationSize)
        
        var i = 0
        while true {
            if i >= outputSize {
                outElementStartIndex = startIndex
                outElementCount = outputSize
                return TA_ReturnCode.Success
            }
            let curPeriod = localPeriodArray[i]
            if curPeriod != 0 {
                var localElementStartIndex = 0
                var localElementCount = 0
                let returnCode = TA_MovingAverage.calculate(startIndex: startIndex,
                                                            endIndex: endIndex,
                                                            inDouble: inDouble,
                                                            optInTimePeriod: curPeriod,
                                                            optInMovingAverageType: optInMovingAverageType,
                                                            outElementStartIndex: &localElementStartIndex,
                                                            outElementCount: &localElementCount,
                                                            outDouble: &localOutputArray)
                if returnCode != TA_ReturnCode.Success {
                    outElementStartIndex = 0
                    outElementCount = 0
                    return returnCode
                }
                outDouble[i] = localOutputArray[i]
                for j in stride(from: i + 1, to: outputSize, by: 1) {
                    if localPeriodArray[j] == curPeriod {
                        localPeriodArray[j] = 0
                        outDouble[j] = localOutputArray[j]
                    }
                }
            }
            i += 1
        }
    }
    
    public class func calculate(startIndex: Int,
                                endIndex: Int,
                                inCandle: [TA_Candle],
                                inPeriods: [Double],
                                inCandleInputType: TA_CandleInputType,
                                optInMinPeriod: Int,
                                optInMaxPeriod: Int,
                                optInMovingAverageType: TA_MovingAverageType,
                                outElementStartIndex: inout Int,
                                outElementCount: inout Int,
                                outDouble: inout [Double]) -> TA_ReturnCode
    {
        var startIndex = startIndex
        var optInMinPeriod = optInMinPeriod
        var optInMaxPeriod = optInMaxPeriod
        
        outElementStartIndex = 0
        outElementCount = 0
        
        if startIndex < 0 {
            return TA_ReturnCode.OutOfRangeStartIndex
        }
        if endIndex < 0 || endIndex < startIndex {
            return TA_ReturnCode.OutOfRangeStartIndex
        }
        if optInMinPeriod == Int.min {
            optInMinPeriod = self.optInMinPeriodDefault
        } else if optInMinPeriod < 2 || optInMinPeriod > 100000 {
            return TA_ReturnCode.BadParam
        }
        if optInMaxPeriod == Int.min {
            optInMaxPeriod = self.optInMaxPeriodDefault
        } else if optInMaxPeriod < 2 || optInMaxPeriod > 100000 {
            return TA_ReturnCode.BadParam
        }
        let lookbackTotal = self.lookback(optInMinPeriod: optInMinPeriod,
                                          optInMaxPeriod: optInMaxPeriod,
                                          optInMovingAverageType: optInMovingAverageType)
        if startIndex < lookbackTotal {
            startIndex = lookbackTotal
        }
        if startIndex > endIndex {
            outElementStartIndex = 0
            outElementCount = 0
            return TA_ReturnCode.Success
        }
        var tempInt: Int
        if lookbackTotal > startIndex {
            tempInt = lookbackTotal
        } else {
            tempInt = startIndex
        }
        if tempInt > endIndex {
            outElementStartIndex = 0
            outElementCount = 0
            return TA_ReturnCode.Success
        }
        let outputSize = (endIndex - tempInt) + 1
        var localOutputArray = [Double](repeating: 0.0, count: outputSize)
        var localPeriodArray = [Int](repeating: 0, count: outputSize)
        for i in stride(from: 0, to: outputSize, by: 1) {
            tempInt = Int(inPeriods[startIndex + i])
            if tempInt < optInMinPeriod {
                tempInt = optInMinPeriod
            } else if tempInt > optInMaxPeriod {
                tempInt = optInMaxPeriod
            }
            localPeriodArray[i] = tempInt
        }
        
        let allocationSize = self.allocationSize(startIndex: startIndex,
                                                 endIndex: endIndex,
                                                 optInMinPeriod: optInMinPeriod,
                                                 optInMaxPeriod: optInMaxPeriod,
                                                 optInMovingAverageType: optInMovingAverageType)
        outDouble = [Double](repeating: Double.nan, count: allocationSize)
        
        var i = 0
        while true {
            if i >= outputSize {
                outElementStartIndex = startIndex
                outElementCount = outputSize
                return TA_ReturnCode.Success
            }
            let curPeriod = localPeriodArray[i]
            if curPeriod != 0 {
                var localElementStartIndex = 0
                var localElementCount = 0
                let returnCode = TA_MovingAverage.calculate(startIndex: startIndex,
                                                            endIndex: endIndex,
                                                            inCandle: inCandle,
                                                            inCandleInputType: inCandleInputType,
                                                            optInTimePeriod: curPeriod,
                                                            optInMovingAverageType: optInMovingAverageType,
                                                            outElementStartIndex: &localElementStartIndex,
                                                            outElementCount: &localElementCount,
                                                            outDouble: &localOutputArray)
                if returnCode != TA_ReturnCode.Success {
                    outElementStartIndex = 0
                    outElementCount = 0
                    return returnCode
                }
                outDouble[i] = localOutputArray[i]
                for j in stride(from: i + 1, to: outputSize, by: 1) {
                    if localPeriodArray[j] == curPeriod {
                        localPeriodArray[j] = 0
                        outDouble[j] = localOutputArray[j]
                    }
                }
            }
            i += 1
        }
    }
    
    public class func lookback(optInMinPeriod: Int,
                               optInMaxPeriod: Int,
                               optInMovingAverageType: TA_MovingAverageType) -> Int
    {
        var optInMinPeriod = optInMinPeriod
        var optInMaxPeriod = optInMaxPeriod
        
        if optInMinPeriod == Int.min {
            optInMinPeriod = self.optInMinPeriodDefault
        } else if optInMinPeriod < 2 || optInMinPeriod > 100000 {
            return -1
        }
        if optInMaxPeriod == Int.min {
            optInMaxPeriod = self.optInMaxPeriodDefault
        } else if optInMaxPeriod < 2 || optInMaxPeriod > 100000 {
            return -1
        }
        
        return TA_MovingAverage.lookback(optInTimePeriod: optInMaxPeriod,
                                         optInMovingAverageType: optInMovingAverageType)
    }
    
    public class func allocationSize(startIndex: Int,
                                     endIndex: Int,
                                     optInMinPeriod: Int,
                                     optInMaxPeriod: Int,
                                     optInMovingAverageType: TA_MovingAverageType) -> Int
    {
        let lookback = self.lookback(optInMinPeriod: optInMinPeriod,
                                     optInMaxPeriod: optInMaxPeriod,
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




