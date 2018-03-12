//
//  TA_Sar.swift
//  ta-lib-swift
//
//  Created by Pat Sluth on 2017-09-18.
//  Copyright © 2017 patsluth. All rights reserved.
//

import Foundation





// SAR - Parabolic SAR
public class TA_Sar
{
    public static let optInAccelerationDefault = 0.02
    public static let optInMaximumDefault = 0.2
    
    public class func calculate(startIndex: Int,
                                endIndex: Int,
                                inHigh: [Double],
                                inLow: [Double],
                                optInAcceleration: Double,
                                optInMaximum: Double,
                                outElementStartIndex: inout Int,
                                outElementCount: inout Int,
                                outDouble: inout [Double]) -> TA_ReturnCode
    {
        var startIndex = startIndex
        var optInAcceleration = optInAcceleration
        var optInMaximum = optInMaximum
        
        outElementStartIndex = 0
        outElementCount = 0
        
        if startIndex < 0 {
            return TA_ReturnCode.OutOfRangeStartIndex
        }
        if endIndex < 0 || endIndex < startIndex {
            return TA_ReturnCode.OutOfRangeStartIndex
        }
        if optInAcceleration == -4E+37 {
            optInAcceleration = self.optInAccelerationDefault
        } else if optInAcceleration < 0.0 || optInAcceleration > 3E+37 {
            return TA_ReturnCode.BadParam
        }
        if optInMaximum == -4E+37 {
            optInMaximum = self.optInMaximumDefault
        } else if optInMaximum < 0.0 || optInMaximum > 3E+37 {
            return TA_ReturnCode.BadParam
        }
        if startIndex < 1 {
            startIndex = 1
        }
        if startIndex > endIndex {
            outElementStartIndex = 0
            outElementCount = 0
            return TA_ReturnCode.Success
        }
        
        let allocationSize = self.allocationSize(startIndex: startIndex,
                                                 endIndex: endIndex,
                                                 optInAcceleration: optInAcceleration,
                                                 optInMaximum: optInMaximum)
        outDouble = [Double](repeating: Double.nan, count: allocationSize)
        
        var sar: Double
        var ep: Double
        var isLong: Int
        var tempInt1 = 0
        var tempInt2 = 0
        var ep_temp = [Double](repeating: Double.nan, count: 1)
        var af = optInAcceleration
        if af > optInMaximum {
            optInAcceleration = optInMaximum
            af = optInAcceleration
        }
        let returnCode = TA_MinusDM.calculate(startIndex: startIndex,
                                              endIndex: endIndex,
                                              inHigh: inHigh,
                                              inLow: inLow,
                                              optInTimePeriod: 1,
                                              outElementStartIndex: &tempInt1,
                                              outElementCount: &tempInt2,
                                              outDouble: &ep_temp)
        if ep_temp[0] > 0.0 {
            isLong = 0
        } else {
            isLong = 1
        }
        if returnCode != TA_ReturnCode.Success {
            outElementStartIndex = 0
            outElementCount = 0
            return returnCode
        }
        outElementStartIndex = startIndex
        var outIdx = 0
        var todayIdx = startIndex
        var newHigh = inHigh[todayIdx - 1]
        var newLow = inLow[todayIdx - 1]
        if isLong == 1 {
            ep = inHigh[todayIdx]
            sar = newLow
        } else {
            ep = inLow[todayIdx]
            sar = newHigh
        }
        newLow = inLow[todayIdx]
        newHigh = inHigh[todayIdx]
        while todayIdx <= endIndex {
            let prevLow = newLow
            let prevHigh = newHigh
            newLow = inLow[todayIdx]
            newHigh = inHigh[todayIdx]
            todayIdx += 1
            if isLong == 1 {
                if newLow <= sar {
                    isLong = 0
                    sar = ep
                    if sar < prevHigh {
                        sar = prevHigh
                    }
                    if sar < newHigh {
                        sar = newHigh
                    }
                    outDouble[outIdx] = sar
                    outIdx += 1
                    af = optInAcceleration
                    ep = newLow
                    sar += af * (ep - sar)
                    if sar < prevHigh {
                        sar = prevHigh
                    }
                    if sar < newHigh {
                        sar = newHigh
                    }
                } else {
                    outDouble[outIdx] = sar
                    outIdx += 1
                    if newHigh > ep {
                        ep = newHigh
                        af += optInAcceleration
                        if af > optInMaximum {
                            af = optInMaximum
                        }
                    }
                    sar += af * (ep - sar)
                    if sar > prevLow {
                        sar = prevLow
                    }
                    if sar > newLow {
                        sar = newLow
                    }
                }
            } else if newHigh >= sar {
                isLong = 1
                sar = ep
                if sar > prevLow {
                    sar = prevLow
                }
                if sar > newLow {
                    sar = newLow
                }
                outDouble[outIdx] = sar
                outIdx += 1
                af = optInAcceleration
                ep = newHigh
                sar += af * (ep - sar)
                if sar > prevLow {
                    sar = prevLow
                }
                if sar > newLow {
                    sar = newLow
                }
            } else {
                outDouble[outIdx] = sar
                outIdx += 1
                if newLow < ep {
                    ep = newLow
                    af += optInAcceleration
                    if af > optInMaximum {
                        af = optInMaximum
                    }
                }
                sar += af * (ep - sar)
                if sar < prevHigh {
                    sar = prevHigh
                }
                if sar < newHigh {
                    sar = newHigh
                }
            }
        }
        
        outElementCount = outIdx
        
        return TA_ReturnCode.Success
    }
    
    public class func calculate(startIndex: Int,
                                endIndex: Int,
                                inCandle: [TA_Candle],
                                optInAcceleration: Double,
                                optInMaximum: Double,
                                outElementStartIndex: inout Int,
                                outElementCount: inout Int,
                                outDouble: inout [Double]) -> TA_ReturnCode
    {
        var startIndex = startIndex
        var optInAcceleration = optInAcceleration
        var optInMaximum = optInMaximum
        
        outElementStartIndex = 0
        outElementCount = 0
        
        if startIndex < 0 {
            return TA_ReturnCode.OutOfRangeStartIndex
        }
        if endIndex < 0 || endIndex < startIndex {
            return TA_ReturnCode.OutOfRangeStartIndex
        }
        if optInAcceleration == -4E+37 {
            optInAcceleration = self.optInAccelerationDefault
        } else if optInAcceleration < 0.0 || optInAcceleration > 3E+37 {
            return TA_ReturnCode.BadParam
        }
        if optInMaximum == -4E+37 {
            optInMaximum = self.optInMaximumDefault
        } else if optInMaximum < 0.0 || optInMaximum > 3E+37 {
            return TA_ReturnCode.BadParam
        }
        if startIndex < 1 {
            startIndex = 1
        }
        if startIndex > endIndex {
            outElementStartIndex = 0
            outElementCount = 0
            return TA_ReturnCode.Success
        }
        
        let allocationSize = self.allocationSize(startIndex: startIndex,
                                                 endIndex: endIndex,
                                                 optInAcceleration: optInAcceleration,
                                                 optInMaximum: optInMaximum)
        outDouble = [Double](repeating: Double.nan, count: allocationSize)
        
        var sar: Double
        var ep: Double
        var isLong: Int
        var tempInt1 = 0
        var tempInt2 = 0
        var ep_temp = [Double](repeating: Double.nan, count: 1)
        var af = optInAcceleration
        if af > optInMaximum {
            optInAcceleration = optInMaximum
            af = optInAcceleration
        }
        let returnCode = TA_MinusDM.calculate(startIndex: startIndex,
                                              endIndex: endIndex,
                                              inCandle: inCandle,
                                              optInTimePeriod: 1,
                                              outElementStartIndex: &tempInt1,
                                              outElementCount: &tempInt2,
                                              outDouble: &ep_temp)
        if ep_temp[0] > 0.0 {
            isLong = 0
        } else {
            isLong = 1
        }
        if returnCode != TA_ReturnCode.Success {
            outElementStartIndex = 0
            outElementCount = 0
            return returnCode
        }
        outElementStartIndex = startIndex
        var outIdx = 0
        var todayIdx = startIndex
        var newHigh = inCandle[todayIdx - 1][TA_CandleInputType.High]
        var newLow = inCandle[todayIdx - 1][TA_CandleInputType.Low]
        if isLong == 1 {
            ep = inCandle[todayIdx][TA_CandleInputType.High]
            sar = newLow
        } else {
            ep = inCandle[todayIdx][TA_CandleInputType.Low]
            sar = newHigh
        }
        newLow = inCandle[todayIdx][TA_CandleInputType.Low]
        newHigh = inCandle[todayIdx][TA_CandleInputType.High]
        while todayIdx <= endIndex {
            let prevLow = newLow
            let prevHigh = newHigh
            newLow = inCandle[todayIdx][TA_CandleInputType.Low]
            newHigh = inCandle[todayIdx][TA_CandleInputType.High]
            todayIdx += 1
            if isLong == 1 {
                if newLow <= sar {
                    isLong = 0
                    sar = ep
                    if sar < prevHigh {
                        sar = prevHigh
                    }
                    if sar < newHigh {
                        sar = newHigh
                    }
                    outDouble[outIdx] = sar
                    outIdx += 1
                    af = optInAcceleration
                    ep = newLow
                    sar += af * (ep - sar)
                    if sar < prevHigh {
                        sar = prevHigh
                    }
                    if sar < newHigh {
                        sar = newHigh
                    }
                } else {
                    outDouble[outIdx] = sar
                    outIdx += 1
                    if newHigh > ep {
                        ep = newHigh
                        af += optInAcceleration
                        if af > optInMaximum {
                            af = optInMaximum
                        }
                    }
                    sar += af * (ep - sar)
                    if sar > prevLow {
                        sar = prevLow
                    }
                    if sar > newLow {
                        sar = newLow
                    }
                }
            } else if newHigh >= sar {
                isLong = 1
                sar = ep
                if sar > prevLow {
                    sar = prevLow
                }
                if sar > newLow {
                    sar = newLow
                }
                outDouble[outIdx] = sar
                outIdx += 1
                af = optInAcceleration
                ep = newHigh
                sar += af * (ep - sar)
                if sar > prevLow {
                    sar = prevLow
                }
                if sar > newLow {
                    sar = newLow
                }
            } else {
                outDouble[outIdx] = sar
                outIdx += 1
                if newLow < ep {
                    ep = newLow
                    af += optInAcceleration
                    if af > optInMaximum {
                        af = optInMaximum
                    }
                }
                sar += af * (ep - sar)
                if sar < prevHigh {
                    sar = prevHigh
                }
                if sar < newHigh {
                    sar = newHigh
                }
            }
        }
        
        outElementCount = outIdx
        
        return TA_ReturnCode.Success
    }
    
    public class func lookback(optInAcceleration: Double,
                               optInMaximum: Double) -> Int
    {
        var optInAcceleration = optInAcceleration
        var optInMaximum = optInMaximum
        
        if optInAcceleration == -4E+37 {
            optInAcceleration = self.optInAccelerationDefault
        } else if optInAcceleration < 0.0 || optInAcceleration > 3E+37 {
            return -1
        }
        if optInMaximum == -4E+37 {
            optInMaximum = self.optInMaximumDefault
        } else if optInMaximum < 0.0 || optInMaximum > 3E+37 {
            return -1
        }
        
        return 1
    }
    
    public class func allocationSize(startIndex: Int,
                                     endIndex: Int,
                                     optInAcceleration: Double,
                                     optInMaximum: Double) -> Int
    {
        let lookback = self.lookback(optInAcceleration: optInAcceleration,
                                     optInMaximum: optInMaximum)
        let temp = max(lookback, startIndex)
        var allocationSize = 0
        if temp > endIndex {
        } else {
            allocationSize = endIndex - temp + 1
        }
        
        return allocationSize
    }
}




