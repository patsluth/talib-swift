//
//  TA_Mama.swift
//  ta-lib-swift
//
//  Created by Pat Sluth on 2017-09-18.
//  Copyright © 2017 patsluth. All rights reserved.
//

import Foundation





// MAMA - MESA Adaptive Moving Average
public class TA_Mama
{
    public static let optInFastLimitDefault = 0.5
    public static let optInSlowLimitDefault = 0.05
    
    public class func calculate(startIndex: Int,
                                endIndex: Int,
                                inDouble: [Double],
                                optInFastLimit: Double,
                                optInSlowLimit: Double,
                                outElementStartIndex: inout Int,
                                outElementCount: inout Int,
                                outMAMA: inout [Double],
                                outFAMA: inout [Double]) -> TA_ReturnCode
    {
        var startIndex = startIndex
        var optInFastLimit = optInFastLimit
        var optInSlowLimit = optInSlowLimit
        
        outElementStartIndex = 0
        outElementCount = 0
        
        if startIndex < 0 {
            return TA_ReturnCode.OutOfRangeStartIndex
        }
        if endIndex < 0 || endIndex < startIndex {
            return TA_ReturnCode.OutOfRangeStartIndex
        }
        if optInFastLimit == -4E+37 {
            optInFastLimit = self.optInFastLimitDefault
        } else if optInFastLimit < 0.01 || optInFastLimit > 0.99 {
            return TA_ReturnCode.BadParam
        }
        if optInSlowLimit == -4E+37 {
            optInSlowLimit = self.optInSlowLimitDefault
        } else if optInSlowLimit < 0.01 || optInSlowLimit > 0.99 {
            return TA_ReturnCode.BadParam
        }
        let rad2Deg = 180.0 / (4.0 * atan(1.0))
        let lookbackTotal = self.lookback(optInFastLimit: optInFastLimit, optInSlowLimit: optInSlowLimit)
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
                                                 optInFastLimit: optInFastLimit,
                                                 optInSlowLimit: optInSlowLimit)
        outMAMA = [Double](repeating: Double.nan, count: allocationSize)
        outFAMA = [Double](repeating: Double.nan, count: allocationSize)
        
        var smoothedValue: Double
        let a = 0.0962
        let b = 0.5769
        var detrender_Odd = [Double](repeating: 0.0, count: 3)
        var detrender_Even = [Double](repeating: 0.0, count: 3)
        var Q1_Odd = [Double](repeating: 0.0, count: 3)
        var Q1_Even = [Double](repeating: 0.0, count: 3)
        var jI_Odd = [Double](repeating: 0.0, count: 3)
        var jI_Even = [Double](repeating: 0.0, count: 3)
        var jQ_Odd = [Double](repeating: 0.0, count: 3)
        var jQ_Even = [Double](repeating: 0.0, count: 3)
        outElementStartIndex = startIndex
        var trailingWMAIdx = startIndex - lookbackTotal
        var today = trailingWMAIdx
        var tempReal = inDouble[today]
        today += 1
        var periodWMASub = tempReal
        var periodWMASum = tempReal
        tempReal = inDouble[today]
        periodWMASub += tempReal
        periodWMASum += (tempReal * 2.0)
        tempReal = inDouble[today]
        today += 1
        periodWMASub += tempReal
        periodWMASum += (tempReal * 3.0)
        var trailingWMAValue = 0.0
        var i = 9
        repeat {
            tempReal = inDouble[today]
            today += 1
            periodWMASub += tempReal
            periodWMASub -= trailingWMAValue
            periodWMASum += (tempReal * 4.0)
            trailingWMAValue = inDouble[trailingWMAIdx]
            trailingWMAIdx += 1
            smoothedValue = periodWMASum * 0.1
            periodWMASum -= periodWMASub
            i -= 1
        } while i != 0
        var hilbertIdx = 0
        detrender_Odd[0] = 0.0
        detrender_Odd[1] = 0.0
        detrender_Odd[2] = 0.0
        detrender_Even[0] = 0.0
        detrender_Even[1] = 0.0
        detrender_Even[2] = 0.0
        var detrender = 0.0
        var prev_detrender_Odd = 0.0
        var prev_detrender_Even = 0.0
        var prev_detrender_input_Odd = 0.0
        var prev_detrender_input_Even = 0.0
        Q1_Odd[0] = 0.0
        Q1_Odd[1] = 0.0
        Q1_Odd[2] = 0.0
        Q1_Even[0] = 0.0
        Q1_Even[1] = 0.0
        Q1_Even[2] = 0.0
        var Q1 = 0.0
        var prev_Q1_Odd = 0.0
        var prev_Q1_Even = 0.0
        var prev_Q1_input_Odd = 0.0
        var prev_Q1_input_Even = 0.0
        jI_Odd[0] = 0.0
        jI_Odd[1] = 0.0
        jI_Odd[2] = 0.0
        jI_Even[0] = 0.0
        jI_Even[1] = 0.0
        jI_Even[2] = 0.0
        var jI = 0.0
        var prev_jI_Odd = 0.0
        var prev_jI_Even = 0.0
        var prev_jI_input_Odd = 0.0
        var prev_jI_input_Even = 0.0
        jQ_Odd[0] = 0.0
        jQ_Odd[1] = 0.0
        jQ_Odd[2] = 0.0
        jQ_Even[0] = 0.0
        jQ_Even[1] = 0.0
        jQ_Even[2] = 0.0
        var jQ = 0.0
        var prev_jQ_Odd = 0.0
        var prev_jQ_Even = 0.0
        var prev_jQ_input_Odd = 0.0
        var prev_jQ_input_Even = 0.0
        var period = 0.0
        var outIdx = 0
        
        var prevQ2 = 0.0
        var prevI2 = prevQ2
        var Im = 0.0
        var Re = Im
        var fama = 0.0
        var mama = fama
        var I1ForEvenPrev3 = 0.0
        var I1ForOddPrev3 = I1ForEvenPrev3
        var I1ForEvenPrev2 = 0.0
        var I1ForOddPrev2 = I1ForEvenPrev2
        var prevPhase = 0.0
        while true {
            var hilbertTempReal: Double
            var tempReal2: Double
            var I2: Double
            var Q2: Double
            if today > endIndex {
                break
            }
            let adjustedPrevPeriod = (0.075 * period) + 0.54
            let todayValue = inDouble[today]
            periodWMASub += todayValue
            periodWMASub -= trailingWMAValue
            periodWMASum += todayValue * 4.0
            trailingWMAValue = inDouble[trailingWMAIdx]
            trailingWMAIdx += 1
            smoothedValue = periodWMASum * 0.1
            periodWMASum -= periodWMASub
            if (today % 2) == 0 {
                hilbertTempReal = a * smoothedValue
                detrender = -detrender_Even[hilbertIdx]
                detrender_Even[hilbertIdx] = hilbertTempReal
                detrender += hilbertTempReal
                detrender -= prev_detrender_Even
                prev_detrender_Even = b * prev_detrender_input_Even
                detrender += prev_detrender_Even
                prev_detrender_input_Even = smoothedValue
                detrender *= adjustedPrevPeriod
                hilbertTempReal = a * detrender
                Q1 = -Q1_Even[hilbertIdx]
                Q1_Even[hilbertIdx] = hilbertTempReal
                Q1 += hilbertTempReal
                Q1 -= prev_Q1_Even
                prev_Q1_Even = b * prev_Q1_input_Even
                Q1 += prev_Q1_Even
                prev_Q1_input_Even = detrender
                Q1 *= adjustedPrevPeriod
                hilbertTempReal = a * I1ForEvenPrev3
                jI = -jI_Even[hilbertIdx]
                jI_Even[hilbertIdx] = hilbertTempReal
                jI += hilbertTempReal
                jI -= prev_jI_Even
                prev_jI_Even = b * prev_jI_input_Even
                jI += prev_jI_Even
                prev_jI_input_Even = I1ForEvenPrev3
                jI *= adjustedPrevPeriod
                hilbertTempReal = a * Q1
                jQ = -jQ_Even[hilbertIdx]
                jQ_Even[hilbertIdx] = hilbertTempReal
                jQ += hilbertTempReal
                jQ -= prev_jQ_Even
                prev_jQ_Even = b * prev_jQ_input_Even
                jQ += prev_jQ_Even
                prev_jQ_input_Even = Q1
                jQ *= adjustedPrevPeriod
                hilbertIdx += 1
                if hilbertIdx == 3 {
                    hilbertIdx = 0
                }
                Q2 = (0.2 * (Q1 + jI)) + (0.8 * prevQ2)
                I2 = (0.2 * (I1ForEvenPrev3 - jQ)) + (0.8 * prevI2)
                I1ForOddPrev3 = I1ForOddPrev2
                I1ForOddPrev2 = detrender
                if I1ForEvenPrev3 != 0.0 {
                    tempReal2 = atan(Q1 / I1ForEvenPrev3) * rad2Deg
                } else  {
                    tempReal2 = 0.0
                }
            } else {
                hilbertTempReal = a * smoothedValue
                detrender = -detrender_Odd[hilbertIdx]
                detrender_Odd[hilbertIdx] = hilbertTempReal
                detrender += hilbertTempReal
                detrender -= prev_detrender_Odd
                prev_detrender_Odd = b * prev_detrender_input_Odd
                detrender += prev_detrender_Odd
                prev_detrender_input_Odd = smoothedValue
                detrender *= adjustedPrevPeriod
                hilbertTempReal = a * detrender
                Q1 = -Q1_Odd[hilbertIdx]
                Q1_Odd[hilbertIdx] = hilbertTempReal
                Q1 += hilbertTempReal
                Q1 -= prev_Q1_Odd
                prev_Q1_Odd = b * prev_Q1_input_Odd
                Q1 += prev_Q1_Odd
                prev_Q1_input_Odd = detrender
                Q1 *= adjustedPrevPeriod
                hilbertTempReal = a * I1ForOddPrev3
                jI = -jI_Odd[hilbertIdx]
                jI_Odd[hilbertIdx] = hilbertTempReal
                jI += hilbertTempReal
                jI -= prev_jI_Odd
                prev_jI_Odd = b * prev_jI_input_Odd
                jI += prev_jI_Odd
                prev_jI_input_Odd = I1ForOddPrev3
                jI *= adjustedPrevPeriod
                hilbertTempReal = a * Q1
                jQ = -jQ_Odd[hilbertIdx]
                jQ_Odd[hilbertIdx] = hilbertTempReal
                jQ += hilbertTempReal
                jQ -= prev_jQ_Odd
                prev_jQ_Odd = b * prev_jQ_input_Odd
                jQ += prev_jQ_Odd
                prev_jQ_input_Odd = Q1
                jQ *= adjustedPrevPeriod
                Q2 = (0.2 * (Q1 + jI)) + (0.8 * prevQ2)
                I2 = (0.2 * (I1ForOddPrev3 - jQ)) + (0.8 * prevI2)
                I1ForEvenPrev3 = I1ForEvenPrev2
                I1ForEvenPrev2 = detrender
                if (I1ForOddPrev3 != 0.0) {
                    tempReal2 = atan(Q1 / I1ForOddPrev3) * rad2Deg
                } else {
                    tempReal2 = 0.0
                }
            }
            tempReal = prevPhase - tempReal2
            prevPhase = tempReal2
            if tempReal < 1.0 {
                tempReal = 1.0
            }
            if tempReal > 1.0 {
                tempReal = optInFastLimit / tempReal
                if tempReal < optInSlowLimit {
                    tempReal = optInSlowLimit
                }
            } else {
                tempReal = optInFastLimit
            }
            mama = (tempReal * todayValue) + ((1.0 - tempReal) * mama)
            tempReal *= 0.5
            fama = (tempReal * mama) + ((1.0 - tempReal) * fama)
            if today >= startIndex {
                outMAMA[outIdx] = mama
                outFAMA[outIdx] = fama
                outIdx += 1
            }
            Re = (0.2 * ((I2 * prevI2) + (Q2 * prevQ2))) + (0.8 * Re)
            Im = (0.2 * ((I2 * prevQ2) - (Q2 * prevI2))) + (0.8 * Im)
            prevQ2 = Q2
            prevI2 = I2
            tempReal = period
            if Im != 0.0 && Re != 0.0 {
                period = 360.0 / (atan(Im / Re) * rad2Deg)
            }
            tempReal2 = 1.5 * tempReal
            if period > tempReal2 {
                period = tempReal2
            }
            tempReal2 = 0.67 * tempReal
            if period < tempReal2 {
                period = tempReal2
            }
            if period < 6.0 {
                period = 6.0
            } else if period > 50.0 {
                period = 50.0
            }
            period = (0.2 * period) + (0.8 * tempReal)
            today += 1
        }
        
        outElementCount = outIdx
        
        return TA_ReturnCode.Success
    }
    
    public class func calculate(startIndex: Int,
                                endIndex: Int,
                                inCandle: [TA_Candle],
                                inCandleInputType: TA_CandleInputType,
                                optInFastLimit: Double,
                                optInSlowLimit: Double,
                                outElementStartIndex: inout Int,
                                outElementCount: inout Int,
                                outMAMA: inout [Double],
                                outFAMA: inout [Double]) -> TA_ReturnCode
    {
        var startIndex = startIndex
        var optInFastLimit = optInFastLimit
        var optInSlowLimit = optInSlowLimit
        
        outElementStartIndex = 0
        outElementCount = 0
        
        if startIndex < 0 {
            return TA_ReturnCode.OutOfRangeStartIndex
        }
        if endIndex < 0 || endIndex < startIndex {
            return TA_ReturnCode.OutOfRangeStartIndex
        }
        if optInFastLimit == -4E+37 {
            optInFastLimit = self.optInFastLimitDefault
        } else if optInFastLimit < 0.01 || optInFastLimit > 0.99 {
            return TA_ReturnCode.BadParam
        }
        if optInSlowLimit == -4E+37 {
            optInSlowLimit = self.optInSlowLimitDefault
        } else if optInSlowLimit < 0.01 || optInSlowLimit > 0.99 {
            return TA_ReturnCode.BadParam
        }
        let rad2Deg = 180.0 / (4.0 * atan(1.0))
        let lookbackTotal = self.lookback(optInFastLimit: optInFastLimit, optInSlowLimit: optInSlowLimit)
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
                                                 optInFastLimit: optInFastLimit,
                                                 optInSlowLimit: optInSlowLimit)
        outMAMA = [Double](repeating: Double.nan, count: allocationSize)
        outFAMA = [Double](repeating: Double.nan, count: allocationSize)
        
        var smoothedValue: Double
        let a = 0.0962
        let b = 0.5769
        var detrender_Odd = [Double](repeating: 0.0, count: 3)
        var detrender_Even = [Double](repeating: 0.0, count: 3)
        var Q1_Odd = [Double](repeating: 0.0, count: 3)
        var Q1_Even = [Double](repeating: 0.0, count: 3)
        var jI_Odd = [Double](repeating: 0.0, count: 3)
        var jI_Even = [Double](repeating: 0.0, count: 3)
        var jQ_Odd = [Double](repeating: 0.0, count: 3)
        var jQ_Even = [Double](repeating: 0.0, count: 3)
        outElementStartIndex = startIndex
        var trailingWMAIdx = startIndex - lookbackTotal
        var today = trailingWMAIdx
        var tempReal = inCandle[today][inCandleInputType]
        today += 1
        var periodWMASub = tempReal
        var periodWMASum = tempReal
        tempReal = inCandle[today][inCandleInputType]
        periodWMASub += tempReal
        periodWMASum += (tempReal * 2.0)
        tempReal = inCandle[today][inCandleInputType]
        today += 1
        periodWMASub += tempReal
        periodWMASum += (tempReal * 3.0)
        var trailingWMAValue = 0.0
        var i = 9
        repeat {
            tempReal = inCandle[today][inCandleInputType]
            today += 1
            periodWMASub += tempReal
            periodWMASub -= trailingWMAValue
            periodWMASum += (tempReal * 4.0)
            trailingWMAValue = inCandle[trailingWMAIdx][inCandleInputType]
            trailingWMAIdx += 1
            smoothedValue = periodWMASum * 0.1
            periodWMASum -= periodWMASub
            i -= 1
        } while i != 0
        var hilbertIdx = 0
        detrender_Odd[0] = 0.0
        detrender_Odd[1] = 0.0
        detrender_Odd[2] = 0.0
        detrender_Even[0] = 0.0
        detrender_Even[1] = 0.0
        detrender_Even[2] = 0.0
        var detrender = 0.0
        var prev_detrender_Odd = 0.0
        var prev_detrender_Even = 0.0
        var prev_detrender_input_Odd = 0.0
        var prev_detrender_input_Even = 0.0
        Q1_Odd[0] = 0.0
        Q1_Odd[1] = 0.0
        Q1_Odd[2] = 0.0
        Q1_Even[0] = 0.0
        Q1_Even[1] = 0.0
        Q1_Even[2] = 0.0
        var Q1 = 0.0
        var prev_Q1_Odd = 0.0
        var prev_Q1_Even = 0.0
        var prev_Q1_input_Odd = 0.0
        var prev_Q1_input_Even = 0.0
        jI_Odd[0] = 0.0
        jI_Odd[1] = 0.0
        jI_Odd[2] = 0.0
        jI_Even[0] = 0.0
        jI_Even[1] = 0.0
        jI_Even[2] = 0.0
        var jI = 0.0
        var prev_jI_Odd = 0.0
        var prev_jI_Even = 0.0
        var prev_jI_input_Odd = 0.0
        var prev_jI_input_Even = 0.0
        jQ_Odd[0] = 0.0
        jQ_Odd[1] = 0.0
        jQ_Odd[2] = 0.0
        jQ_Even[0] = 0.0
        jQ_Even[1] = 0.0
        jQ_Even[2] = 0.0
        var jQ = 0.0
        var prev_jQ_Odd = 0.0
        var prev_jQ_Even = 0.0
        var prev_jQ_input_Odd = 0.0
        var prev_jQ_input_Even = 0.0
        var period = 0.0
        var outIdx = 0
        
        var prevQ2 = 0.0
        var prevI2 = prevQ2
        var Im = 0.0
        var Re = Im
        var fama = 0.0
        var mama = fama
        var I1ForEvenPrev3 = 0.0
        var I1ForOddPrev3 = I1ForEvenPrev3
        var I1ForEvenPrev2 = 0.0
        var I1ForOddPrev2 = I1ForEvenPrev2
        var prevPhase = 0.0
        while true {
            var hilbertTempReal: Double
            var tempReal2: Double
            var I2: Double
            var Q2: Double
            if today > endIndex {
                break
            }
            let adjustedPrevPeriod = (0.075 * period) + 0.54
            let todayValue = inCandle[today][inCandleInputType]
            periodWMASub += todayValue
            periodWMASub -= trailingWMAValue
            periodWMASum += todayValue * 4.0
            trailingWMAValue = inCandle[trailingWMAIdx][inCandleInputType]
            trailingWMAIdx += 1
            smoothedValue = periodWMASum * 0.1
            periodWMASum -= periodWMASub
            if (today % 2) == 0 {
                hilbertTempReal = a * smoothedValue
                detrender = -detrender_Even[hilbertIdx]
                detrender_Even[hilbertIdx] = hilbertTempReal
                detrender += hilbertTempReal
                detrender -= prev_detrender_Even
                prev_detrender_Even = b * prev_detrender_input_Even
                detrender += prev_detrender_Even
                prev_detrender_input_Even = smoothedValue
                detrender *= adjustedPrevPeriod
                hilbertTempReal = a * detrender
                Q1 = -Q1_Even[hilbertIdx]
                Q1_Even[hilbertIdx] = hilbertTempReal
                Q1 += hilbertTempReal
                Q1 -= prev_Q1_Even
                prev_Q1_Even = b * prev_Q1_input_Even
                Q1 += prev_Q1_Even
                prev_Q1_input_Even = detrender
                Q1 *= adjustedPrevPeriod
                hilbertTempReal = a * I1ForEvenPrev3
                jI = -jI_Even[hilbertIdx]
                jI_Even[hilbertIdx] = hilbertTempReal
                jI += hilbertTempReal
                jI -= prev_jI_Even
                prev_jI_Even = b * prev_jI_input_Even
                jI += prev_jI_Even
                prev_jI_input_Even = I1ForEvenPrev3
                jI *= adjustedPrevPeriod
                hilbertTempReal = a * Q1
                jQ = -jQ_Even[hilbertIdx]
                jQ_Even[hilbertIdx] = hilbertTempReal
                jQ += hilbertTempReal
                jQ -= prev_jQ_Even
                prev_jQ_Even = b * prev_jQ_input_Even
                jQ += prev_jQ_Even
                prev_jQ_input_Even = Q1
                jQ *= adjustedPrevPeriod
                hilbertIdx += 1
                if hilbertIdx == 3 {
                    hilbertIdx = 0
                }
                Q2 = (0.2 * (Q1 + jI)) + (0.8 * prevQ2)
                I2 = (0.2 * (I1ForEvenPrev3 - jQ)) + (0.8 * prevI2)
                I1ForOddPrev3 = I1ForOddPrev2
                I1ForOddPrev2 = detrender
                if I1ForEvenPrev3 != 0.0 {
                    tempReal2 = atan(Q1 / I1ForEvenPrev3) * rad2Deg
                } else  {
                    tempReal2 = 0.0
                }
            } else {
                hilbertTempReal = a * smoothedValue
                detrender = -detrender_Odd[hilbertIdx]
                detrender_Odd[hilbertIdx] = hilbertTempReal
                detrender += hilbertTempReal
                detrender -= prev_detrender_Odd
                prev_detrender_Odd = b * prev_detrender_input_Odd
                detrender += prev_detrender_Odd
                prev_detrender_input_Odd = smoothedValue
                detrender *= adjustedPrevPeriod
                hilbertTempReal = a * detrender
                Q1 = -Q1_Odd[hilbertIdx]
                Q1_Odd[hilbertIdx] = hilbertTempReal
                Q1 += hilbertTempReal
                Q1 -= prev_Q1_Odd
                prev_Q1_Odd = b * prev_Q1_input_Odd
                Q1 += prev_Q1_Odd
                prev_Q1_input_Odd = detrender
                Q1 *= adjustedPrevPeriod
                hilbertTempReal = a * I1ForOddPrev3
                jI = -jI_Odd[hilbertIdx]
                jI_Odd[hilbertIdx] = hilbertTempReal
                jI += hilbertTempReal
                jI -= prev_jI_Odd
                prev_jI_Odd = b * prev_jI_input_Odd
                jI += prev_jI_Odd
                prev_jI_input_Odd = I1ForOddPrev3
                jI *= adjustedPrevPeriod
                hilbertTempReal = a * Q1
                jQ = -jQ_Odd[hilbertIdx]
                jQ_Odd[hilbertIdx] = hilbertTempReal
                jQ += hilbertTempReal
                jQ -= prev_jQ_Odd
                prev_jQ_Odd = b * prev_jQ_input_Odd
                jQ += prev_jQ_Odd
                prev_jQ_input_Odd = Q1
                jQ *= adjustedPrevPeriod
                Q2 = (0.2 * (Q1 + jI)) + (0.8 * prevQ2)
                I2 = (0.2 * (I1ForOddPrev3 - jQ)) + (0.8 * prevI2)
                I1ForEvenPrev3 = I1ForEvenPrev2
                I1ForEvenPrev2 = detrender
                if (I1ForOddPrev3 != 0.0) {
                    tempReal2 = atan(Q1 / I1ForOddPrev3) * rad2Deg
                } else {
                    tempReal2 = 0.0
                }
            }
            tempReal = prevPhase - tempReal2
            prevPhase = tempReal2
            if tempReal < 1.0 {
                tempReal = 1.0
            }
            if tempReal > 1.0 {
                tempReal = optInFastLimit / tempReal
                if tempReal < optInSlowLimit {
                    tempReal = optInSlowLimit
                }
            } else {
                tempReal = optInFastLimit
            }
            mama = (tempReal * todayValue) + ((1.0 - tempReal) * mama)
            tempReal *= 0.5
            fama = (tempReal * mama) + ((1.0 - tempReal) * fama)
            if today >= startIndex {
                outMAMA[outIdx] = mama
                outFAMA[outIdx] = fama
                outIdx += 1
            }
            Re = (0.2 * ((I2 * prevI2) + (Q2 * prevQ2))) + (0.8 * Re)
            Im = (0.2 * ((I2 * prevQ2) - (Q2 * prevI2))) + (0.8 * Im)
            prevQ2 = Q2
            prevI2 = I2
            tempReal = period
            if Im != 0.0 && Re != 0.0 {
                period = 360.0 / (atan(Im / Re) * rad2Deg)
            }
            tempReal2 = 1.5 * tempReal
            if period > tempReal2 {
                period = tempReal2
            }
            tempReal2 = 0.67 * tempReal
            if period < tempReal2 {
                period = tempReal2
            }
            if period < 6.0 {
                period = 6.0
            } else if period > 50.0 {
                period = 50.0
            }
            period = (0.2 * period) + (0.8 * tempReal)
            today += 1
        }
        
        outElementCount = outIdx
        
        return TA_ReturnCode.Success
    }
    
    public class func lookback(optInFastLimit: Double,
                               optInSlowLimit: Double) -> Int
    {
        var optInFastLimit = optInFastLimit
        var optInSlowLimit = optInSlowLimit
        
        if optInFastLimit == -4E+37 {
            optInFastLimit = self.optInFastLimitDefault
        } else if optInFastLimit < 0.01 || optInFastLimit > 0.99 {
            return -1
        }
        if optInSlowLimit == -4E+37 {
            optInSlowLimit = self.optInSlowLimitDefault
        } else if optInSlowLimit < 0.01 || optInSlowLimit > 0.99 {
            return -1
        }
        
        return (TA_Core.sharedInstance.globals.unstablePeriod[TA_FunctionUnstableId.Mama.rawValue] + 32)
    }
    
    public class func allocationSize(startIndex: Int,
                                     endIndex: Int,
                                     optInFastLimit: Double,
                                     optInSlowLimit: Double) -> Int
    {
        let lookback = self.lookback(optInFastLimit: optInFastLimit,
                                     optInSlowLimit: optInSlowLimit)
        let temp = max(lookback, startIndex)
        var allocationSize = 0
        if temp > endIndex {
        } else {
            allocationSize = endIndex - temp + 1
        }
        
        return allocationSize
    }
}




