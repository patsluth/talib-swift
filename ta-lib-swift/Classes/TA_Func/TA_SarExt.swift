//
//  TA_SarExt.swift
//  ta-lib-swift
//
//  Created by Pat Sluth on 2017-09-18.
//  Copyright © 2017 patsluth. All rights reserved.
//

import Foundation





// SAREXT - Parabolic SAR - Extended
public class TA_SarExt
{
    public static let optInStartValueDefault = 0.0
    public static let optInOffsetOnReverseDefault = 0.0
    public static let optInAccelerationInitLongDefault = 0.02
    public static let optInAccelerationLongDefault = 0.02
    public static let optInAccelerationMaxLongDefault = 0.2
    public static let optInAccelerationInitShortDefault = 0.02
    public static let optInAccelerationShortDefault = 0.02
    public static let optInAccelerationMaxShortDefault = 0.2
    
    public class func calculate(startIndex: Int,
                                endIndex: Int,
                                inHigh: [Double],
                                inLow: [Double],
                                optInStartValue: Double,
                                optInOffsetOnReverse: Double,
                                optInAccelerationInitLong: Double,
                                optInAccelerationLong: Double,
                                optInAccelerationMaxLong: Double,
                                optInAccelerationInitShort: Double,
                                optInAccelerationShort: Double,
                                optInAccelerationMaxShort: Double,
                                outElementStartIndex: inout Int,
                                outElementCount: inout Int,
                                outDouble: inout [Double]) -> TA_ReturnCode
    {
        var startIndex = startIndex
        var optInStartValue = optInStartValue
        var optInOffsetOnReverse = optInOffsetOnReverse
        var optInAccelerationInitLong = optInAccelerationInitLong
        var optInAccelerationLong = optInAccelerationLong
        var optInAccelerationMaxLong = optInAccelerationMaxLong
        var optInAccelerationInitShort = optInAccelerationInitShort
        var optInAccelerationShort = optInAccelerationShort
        var optInAccelerationMaxShort = optInAccelerationMaxShort
        
        outElementStartIndex = 0
        outElementCount = 0
        
        if startIndex < 0 {
            return TA_ReturnCode.OutOfRangeStartIndex
        }
        if endIndex < 0 || endIndex < startIndex {
            return TA_ReturnCode.OutOfRangeStartIndex
        }
        if optInStartValue == -4E+37 {
            optInStartValue = self.optInStartValueDefault
        } else if optInStartValue < -3E+37 || optInStartValue > 3E+37 {
            return TA_ReturnCode.BadParam
        }
        if optInOffsetOnReverse == -4E+37 {
            optInOffsetOnReverse = self.optInOffsetOnReverseDefault
        } else if optInOffsetOnReverse < 0.0 || optInOffsetOnReverse > 3E+37 {
            return TA_ReturnCode.BadParam
        }
        if optInAccelerationInitLong == -4E+37 {
            optInAccelerationInitLong = self.optInAccelerationInitLongDefault
        } else if optInAccelerationInitLong < 0.0 || optInAccelerationInitLong > 3E+37 {
            return TA_ReturnCode.BadParam
        }
        if optInAccelerationLong == -4E+37 {
            optInAccelerationLong = self.optInAccelerationLongDefault
        } else if optInAccelerationLong < 0.0 || optInAccelerationLong > 3E+37 {
            return TA_ReturnCode.BadParam
        }
        if optInAccelerationMaxLong == -4E+37 {
            optInAccelerationMaxLong = self.optInAccelerationMaxLongDefault
        } else if optInAccelerationMaxLong < 0.0 || optInAccelerationMaxLong > 3E+37 {
            return TA_ReturnCode.BadParam
        }
        if optInAccelerationInitShort == -4E+37 {
            optInAccelerationInitShort = self.optInAccelerationInitShortDefault
        } else if optInAccelerationInitShort < 0.0 || optInAccelerationInitShort > 3E+37 {
            return TA_ReturnCode.BadParam
        }
        if optInAccelerationShort == -4E+37 {
            optInAccelerationShort = self.optInAccelerationShortDefault
        } else if optInAccelerationShort < 0.0 || optInAccelerationShort > 3E+37 {
            return TA_ReturnCode.BadParam
        }
        if optInAccelerationMaxShort == -4E+37 {
            optInAccelerationMaxShort = self.optInAccelerationMaxShortDefault
        } else if optInAccelerationMaxShort < 0.0 || optInAccelerationMaxShort > 3E+37 {
            return TA_ReturnCode.BadParam
        }
        let lookbackTotal = self.lookback(optInStartValue: optInStartValue,
                                          optInOffsetOnReverse: optInOffsetOnReverse,
                                          optInAccelerationInitLong: optInAccelerationInitLong,
                                          optInAccelerationLong: optInAccelerationLong,
                                          optInAccelerationMaxLong: optInAccelerationMaxLong,
                                          optInAccelerationInitShort: optInAccelerationInitShort,
                                          optInAccelerationShort: optInAccelerationShort,
                                          optInAccelerationMaxShort: optInAccelerationMaxShort)
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
                                                 optInStartValue: optInStartValue,
                                                 optInOffsetOnReverse: optInOffsetOnReverse,
                                                 optInAccelerationInitLong: optInAccelerationInitLong,
                                                 optInAccelerationLong: optInAccelerationLong,
                                                 optInAccelerationMaxLong: optInAccelerationMaxLong,
                                                 optInAccelerationInitShort: optInAccelerationInitShort,
                                                 optInAccelerationShort: optInAccelerationShort,
                                                 optInAccelerationMaxShort: optInAccelerationMaxShort)
        outDouble = [Double](repeating: Double.nan, count: allocationSize)
        
        var sar: Double
        var ep: Double
        var isLong: Int
        var ep_temp = [Double]()
        var afLong = optInAccelerationInitLong
        var afShort = optInAccelerationInitShort
        if afLong > optInAccelerationMaxLong {
            optInAccelerationInitLong = optInAccelerationMaxLong
            afLong = optInAccelerationInitLong
        }
        if optInAccelerationLong > optInAccelerationMaxLong {
            optInAccelerationLong = optInAccelerationMaxLong
        }
        if afShort > optInAccelerationMaxShort {
            optInAccelerationInitShort = optInAccelerationMaxShort
            afShort = optInAccelerationInitShort
        }
        if optInAccelerationShort > optInAccelerationMaxShort {
            optInAccelerationShort = optInAccelerationMaxShort
        }
        if optInStartValue == 0.0 {
            var tempStartIndex = 0
            var tempCount = 0
            let returnCode = TA_MinusDM.calculate(startIndex: startIndex,
                                                  endIndex: startIndex,
                                                  inHigh: inHigh,
                                                  inLow: inLow,
                                                  optInTimePeriod: 1,
                                                  outElementStartIndex: &tempStartIndex,
                                                  outElementCount: &tempCount,
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
        } else if optInStartValue > 0.0 {
            isLong = 1
        } else {
            isLong = 0
        }
        outElementStartIndex = startIndex
        var outIdx = 0
        var todayIdx = startIndex
        var newHigh = inHigh[todayIdx - 1]
        var newLow = inLow[todayIdx - 1]
        if optInStartValue == 0.0 {
            if isLong == 1 {
                ep = inHigh[todayIdx]
                sar = newLow
            } else {
                ep = inLow[todayIdx]
                sar = newHigh
            }
        } else if optInStartValue > 0.0 {
            ep = inHigh[todayIdx]
            sar = optInStartValue
        } else {
            ep = inLow[todayIdx]
            sar = fabs(optInStartValue)
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
                    if optInOffsetOnReverse != 0.0 {
                        sar += sar * optInOffsetOnReverse
                    }
                    outDouble[outIdx] = -sar
                    outIdx += 1
                    afShort = optInAccelerationInitShort
                    ep = newLow
                    sar += afShort * (ep - sar)
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
                        afLong += optInAccelerationLong
                        if afLong > optInAccelerationMaxLong {
                            afLong = optInAccelerationMaxLong
                        }
                    }
                    sar += afLong * (ep - sar)
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
                if optInOffsetOnReverse != 0.0 {
                    sar -= sar * optInOffsetOnReverse
                }
                outDouble[outIdx] = sar
                outIdx += 1
                afLong = optInAccelerationInitLong
                ep = newHigh
                sar += afLong * (ep - sar)
                if sar > prevLow {
                    sar = prevLow
                }
                if sar > newLow {
                    sar = newLow
                }
            } else {
                outDouble[outIdx] = -sar
                outIdx += 1
                if newLow < ep {
                    ep = newLow
                    afShort += optInAccelerationShort
                    if afShort > optInAccelerationMaxShort {
                        afShort = optInAccelerationMaxShort
                    }
                }
                sar += afShort * (ep - sar)
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
                                optInStartValue: Double,
                                optInOffsetOnReverse: Double,
                                optInAccelerationInitLong: Double,
                                optInAccelerationLong: Double,
                                optInAccelerationMaxLong: Double,
                                optInAccelerationInitShort: Double,
                                optInAccelerationShort: Double,
                                optInAccelerationMaxShort: Double,
                                outElementStartIndex: inout Int,
                                outElementCount: inout Int,
                                outDouble: inout [Double]) -> TA_ReturnCode
    {
        var startIndex = startIndex
        var optInStartValue = optInStartValue
        var optInOffsetOnReverse = optInOffsetOnReverse
        var optInAccelerationInitLong = optInAccelerationInitLong
        var optInAccelerationLong = optInAccelerationLong
        var optInAccelerationMaxLong = optInAccelerationMaxLong
        var optInAccelerationInitShort = optInAccelerationInitShort
        var optInAccelerationShort = optInAccelerationShort
        var optInAccelerationMaxShort = optInAccelerationMaxShort
        
        outElementStartIndex = 0
        outElementCount = 0
        
        if startIndex < 0 {
            return TA_ReturnCode.OutOfRangeStartIndex
        }
        if endIndex < 0 || endIndex < startIndex {
            return TA_ReturnCode.OutOfRangeStartIndex
        }
        if optInStartValue == -4E+37 {
            optInStartValue = self.optInStartValueDefault
        } else if optInStartValue < -3E+37 || optInStartValue > 3E+37 {
            return TA_ReturnCode.BadParam
        }
        if optInOffsetOnReverse == -4E+37 {
            optInOffsetOnReverse = self.optInOffsetOnReverseDefault
        } else if optInOffsetOnReverse < 0.0 || optInOffsetOnReverse > 3E+37 {
            return TA_ReturnCode.BadParam
        }
        if optInAccelerationInitLong == -4E+37 {
            optInAccelerationInitLong = self.optInAccelerationInitLongDefault
        } else if optInAccelerationInitLong < 0.0 || optInAccelerationInitLong > 3E+37 {
            return TA_ReturnCode.BadParam
        }
        if optInAccelerationLong == -4E+37 {
            optInAccelerationLong = self.optInAccelerationLongDefault
        } else if optInAccelerationLong < 0.0 || optInAccelerationLong > 3E+37 {
            return TA_ReturnCode.BadParam
        }
        if optInAccelerationMaxLong == -4E+37 {
            optInAccelerationMaxLong = self.optInAccelerationMaxLongDefault
        } else if optInAccelerationMaxLong < 0.0 || optInAccelerationMaxLong > 3E+37 {
            return TA_ReturnCode.BadParam
        }
        if optInAccelerationInitShort == -4E+37 {
            optInAccelerationInitShort = self.optInAccelerationInitShortDefault
        } else if optInAccelerationInitShort < 0.0 || optInAccelerationInitShort > 3E+37 {
            return TA_ReturnCode.BadParam
        }
        if optInAccelerationShort == -4E+37 {
            optInAccelerationShort = self.optInAccelerationShortDefault
        } else if optInAccelerationShort < 0.0 || optInAccelerationShort > 3E+37 {
            return TA_ReturnCode.BadParam
        }
        if optInAccelerationMaxShort == -4E+37 {
            optInAccelerationMaxShort = self.optInAccelerationMaxShortDefault
        } else if optInAccelerationMaxShort < 0.0 || optInAccelerationMaxShort > 3E+37 {
            return TA_ReturnCode.BadParam
        }
        let lookbackTotal = self.lookback(optInStartValue: optInStartValue,
                                          optInOffsetOnReverse: optInOffsetOnReverse,
                                          optInAccelerationInitLong: optInAccelerationInitLong,
                                          optInAccelerationLong: optInAccelerationLong,
                                          optInAccelerationMaxLong: optInAccelerationMaxLong,
                                          optInAccelerationInitShort: optInAccelerationInitShort,
                                          optInAccelerationShort: optInAccelerationShort,
                                          optInAccelerationMaxShort: optInAccelerationMaxShort)
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
                                                 optInStartValue: optInStartValue,
                                                 optInOffsetOnReverse: optInOffsetOnReverse,
                                                 optInAccelerationInitLong: optInAccelerationInitLong,
                                                 optInAccelerationLong: optInAccelerationLong,
                                                 optInAccelerationMaxLong: optInAccelerationMaxLong,
                                                 optInAccelerationInitShort: optInAccelerationInitShort,
                                                 optInAccelerationShort: optInAccelerationShort,
                                                 optInAccelerationMaxShort: optInAccelerationMaxShort)
        outDouble = [Double](repeating: Double.nan, count: allocationSize)
        
        var sar: Double
        var ep: Double
        var isLong: Int
        var ep_temp = [Double]()
        var afLong = optInAccelerationInitLong
        var afShort = optInAccelerationInitShort
        if afLong > optInAccelerationMaxLong {
            optInAccelerationInitLong = optInAccelerationMaxLong
            afLong = optInAccelerationInitLong
        }
        if optInAccelerationLong > optInAccelerationMaxLong {
            optInAccelerationLong = optInAccelerationMaxLong
        }
        if afShort > optInAccelerationMaxShort {
            optInAccelerationInitShort = optInAccelerationMaxShort
            afShort = optInAccelerationInitShort
        }
        if optInAccelerationShort > optInAccelerationMaxShort {
            optInAccelerationShort = optInAccelerationMaxShort
        }
        if optInStartValue == 0.0 {
            var tempStartIndex = 0
            var tempCount = 0
            let returnCode = TA_MinusDM.calculate(startIndex: startIndex,
                                                  endIndex: startIndex,
                                                  inCandle: inCandle,
                                                  optInTimePeriod: 1,
                                                  outElementStartIndex: &tempStartIndex,
                                                  outElementCount: &tempCount,
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
        } else if optInStartValue > 0.0 {
            isLong = 1
        } else {
            isLong = 0
        }
        outElementStartIndex = startIndex
        var outIdx = 0
        var todayIdx = startIndex
        var newHigh = inCandle[todayIdx - 1][TA_CandleInputType.High]
        var newLow = inCandle[todayIdx - 1][TA_CandleInputType.Low]
        if optInStartValue == 0.0 {
            if isLong == 1 {
                ep = inCandle[todayIdx][TA_CandleInputType.High]
                sar = newLow
            } else {
                ep = inCandle[todayIdx][TA_CandleInputType.Low]
                sar = newHigh
            }
        } else if optInStartValue > 0.0 {
            ep = inCandle[todayIdx][TA_CandleInputType.High]
            sar = optInStartValue
        } else {
            ep = inCandle[todayIdx][TA_CandleInputType.Low]
            sar = fabs(optInStartValue)
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
                    if optInOffsetOnReverse != 0.0 {
                        sar += sar * optInOffsetOnReverse
                    }
                    outDouble[outIdx] = -sar
                    outIdx += 1
                    afShort = optInAccelerationInitShort
                    ep = newLow
                    sar += afShort * (ep - sar)
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
                        afLong += optInAccelerationLong
                        if afLong > optInAccelerationMaxLong {
                            afLong = optInAccelerationMaxLong
                        }
                    }
                    sar += afLong * (ep - sar)
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
                if optInOffsetOnReverse != 0.0 {
                    sar -= sar * optInOffsetOnReverse
                }
                outDouble[outIdx] = sar
                outIdx += 1
                afLong = optInAccelerationInitLong
                ep = newHigh
                sar += afLong * (ep - sar)
                if sar > prevLow {
                    sar = prevLow
                }
                if sar > newLow {
                    sar = newLow
                }
            } else {
                outDouble[outIdx] = -sar
                outIdx += 1
                if newLow < ep {
                    ep = newLow
                    afShort += optInAccelerationShort
                    if afShort > optInAccelerationMaxShort {
                        afShort = optInAccelerationMaxShort
                    }
                }
                sar += afShort * (ep - sar)
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
    
    public class func lookback(optInStartValue: Double,
                               optInOffsetOnReverse: Double,
                               optInAccelerationInitLong: Double,
                               optInAccelerationLong: Double,
                               optInAccelerationMaxLong: Double,
                               optInAccelerationInitShort: Double,
                               optInAccelerationShort: Double,
                               optInAccelerationMaxShort: Double) -> Int
    {
        var optInStartValue = optInStartValue
        var optInOffsetOnReverse = optInOffsetOnReverse
        var optInAccelerationInitLong = optInAccelerationInitLong
        var optInAccelerationLong = optInAccelerationLong
        var optInAccelerationMaxLong = optInAccelerationMaxLong
        var optInAccelerationInitShort = optInAccelerationInitShort
        var optInAccelerationShort = optInAccelerationShort
        var optInAccelerationMaxShort = optInAccelerationMaxShort
        
        if optInStartValue == -4E+37 {
            optInStartValue = self.optInStartValueDefault
        } else if optInStartValue < -3E+37 || optInStartValue > 3E+37 {
            return -1
        }
        if optInOffsetOnReverse == -4E+37 {
            optInOffsetOnReverse = self.optInOffsetOnReverseDefault
        } else if optInOffsetOnReverse < 0.0 || optInOffsetOnReverse > 3E+37 {
            return -1
        }
        if optInAccelerationInitLong == -4E+37 {
            optInAccelerationInitLong = self.optInAccelerationInitLongDefault
        } else if optInAccelerationInitLong < 0.0 || optInAccelerationInitLong > 3E+37 {
            return -1
        }
        if optInAccelerationLong == -4E+37 {
            optInAccelerationLong = self.optInAccelerationLongDefault
        } else if optInAccelerationLong < 0.0 || optInAccelerationLong > 3E+37 {
            return -1
        }
        if optInAccelerationMaxLong == -4E+37 {
            optInAccelerationMaxLong = self.optInAccelerationMaxLongDefault
        } else if optInAccelerationMaxLong < 0.0 || optInAccelerationMaxLong > 3E+37 {
            return -1
        }
        if optInAccelerationInitShort == -4E+37 {
            optInAccelerationInitShort = self.optInAccelerationInitShortDefault
        } else if optInAccelerationInitShort < 0.0 || optInAccelerationInitShort > 3E+37 {
            return -1
        }
        if optInAccelerationShort == -4E+37 {
            optInAccelerationShort = self.optInAccelerationShortDefault
        } else if optInAccelerationShort < 0.0 || optInAccelerationShort > 3E+37 {
            return -1
        }
        if optInAccelerationMaxShort == -4E+37 {
            optInAccelerationMaxShort = self.optInAccelerationMaxShortDefault
        } else if optInAccelerationMaxShort < 0.0 || optInAccelerationMaxShort > 3E+37 {
            return -1
        }
        
        return 1
    }
    
    public class func allocationSize(startIndex: Int,
                                     endIndex: Int,
                                     optInStartValue: Double,
                                     optInOffsetOnReverse: Double,
                                     optInAccelerationInitLong: Double,
                                     optInAccelerationLong: Double,
                                     optInAccelerationMaxLong: Double,
                                     optInAccelerationInitShort: Double,
                                     optInAccelerationShort: Double,
                                     optInAccelerationMaxShort: Double) -> Int
    {
        let lookback = self.lookback(optInStartValue: optInStartValue,
                                     optInOffsetOnReverse: optInOffsetOnReverse,
                                     optInAccelerationInitLong: optInAccelerationInitLong,
                                     optInAccelerationLong: optInAccelerationLong,
                                     optInAccelerationMaxLong: optInAccelerationMaxLong,
                                     optInAccelerationInitShort: optInAccelerationInitShort,
                                     optInAccelerationShort: optInAccelerationShort,
                                     optInAccelerationMaxShort: optInAccelerationMaxShort)
        let temp = max(lookback, startIndex)
        var allocationSize = 0
        if temp > endIndex {
        } else {
            allocationSize = endIndex - temp + 1
        }
        
        return allocationSize
    }
}




