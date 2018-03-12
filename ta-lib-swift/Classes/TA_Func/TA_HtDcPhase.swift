//
//  TA_HtDcPhase.swift
//  ta-lib-swift
//
//  Created by Pat Sluth on 2017-09-18.
//  Copyright © 2017 patsluth. All rights reserved.
//

import Foundation





// HT_DCPHASE - Hilbert Transform - Dominant Cycle Phase
public class TA_HtDcPhase
{
    public class func calculate(startIndex: Int,
                                endIndex: Int,
                                inDouble: [Double],
                                outElementStartIndex: inout Int,
                                outElementCount: inout Int,
                                outDouble: inout [Double]) -> TA_ReturnCode
    {
        var startIndex = startIndex
        
        outElementStartIndex = 0
        outElementCount = 0
        
        if startIndex < 0 {
            return TA_ReturnCode.OutOfRangeStartIndex
        }
        if endIndex < 0 || endIndex < startIndex {
            return TA_ReturnCode.OutOfRangeStartIndex
        }
        let lookbackTotal = self.lookback()
        if startIndex < lookbackTotal {
            startIndex = lookbackTotal
        }
        if startIndex > endIndex {
            outElementStartIndex = 0
            outElementCount = 0
            return TA_ReturnCode.Success
        }
        
        let allocationSize = self.allocationSize(startIndex: startIndex,
                                                 endIndex: endIndex)
        outDouble = [Double](repeating: Double.nan, count: allocationSize)
        
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
        var smoothPrice_Idx = 0
        let maxIdx_smoothPrice = 0x31
        var smoothPrice = [Double](repeating: 0.0, count: maxIdx_smoothPrice + 1)
        var tempReal = atan(1.0)
        let rad2Deg = 45.0 / tempReal
        let constDeg2RadBy360 = tempReal * 8.0
        outElementStartIndex = startIndex
        var trailingWMAIdx = startIndex - lookbackTotal
        var today = trailingWMAIdx
        tempReal = inDouble[today]
        today += 1
        var periodWMASub = tempReal
        var periodWMASum = tempReal
        tempReal = inDouble[today]
        today += 1
        periodWMASub += tempReal
        periodWMASum += tempReal * 2.0
        tempReal = inDouble[today]
        today += 1
        periodWMASub += tempReal
        periodWMASum += tempReal * 3.0
        var trailingWMAValue = 0.0
        var i = 0x22
        repeat {
            tempReal = inDouble[today]
            today += 1
            periodWMASub += tempReal
            periodWMASub -= trailingWMAValue
            periodWMASum += tempReal * 4.0
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
        var I1ForEvenPrev3 = 0.0
        var I1ForOddPrev3 = I1ForEvenPrev3
        var I1ForEvenPrev2 = 0.0
        var I1ForOddPrev2 = I1ForEvenPrev2
        var smoothPeriod = 0.0
        i = 0
        while i < 50 {
            smoothPrice[i] = 0.0
            i += 1
        }
        var DCPhase = 0.0
        while true {
            var hilbertTempReal: Double
            var I2: Double
            var Q2: Double
            if today > endIndex {
                outElementCount = outIdx
                return TA_ReturnCode.Success
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
            smoothPrice[smoothPrice_Idx] = smoothedValue
            if today % 2 == 0 {
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
            }
            Re = (0.2 * ((I2 * prevI2) + (Q2 * prevQ2))) + (0.8 * Re)
            Im = (0.2 * ((I2 * prevQ2) - (Q2 * prevI2))) + (0.8 * Im)
            prevQ2 = Q2
            prevI2 = I2
            tempReal = period
            if (Im != 0.0) && (Re != 0.0) {
                period = 360.0 / (atan(Im / Re) * rad2Deg)
            }
            var tempReal2 = 1.5 * tempReal
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
            smoothPeriod = (0.33 * period) + (0.67 * smoothPeriod)
            var DCPeriod = smoothPeriod + 0.5
            let DCPeriodInt = Int(DCPeriod)
            var realPart = 0.0
            var imagPart = 0.0
            var idx = smoothPrice_Idx
            for i in stride(from: 0, to: DCPeriodInt, by: 1) {
                tempReal = (Double(i) * constDeg2RadBy360) / (Double(DCPeriodInt))
                tempReal2 = smoothPrice[idx]
                realPart += sin(tempReal) * tempReal2
                imagPart += cos(tempReal) * tempReal2
                if idx == 0 {
                    idx = 0x31
                } else {
                    idx -= 1
                }
            }
            tempReal = fabs(imagPart)
            if tempReal > 0.0 {
                DCPhase = atan(realPart / imagPart) * rad2Deg
            } else if tempReal <= 0.01 {
                if realPart > 0.0 {
                    DCPeriod -= 90.0
                } else if realPart > 0.0 {
                    DCPhase += 90.0
                }
            }
            DCPhase += 90.0
            DCPhase += 360.0 / smoothPeriod
            if imagPart < 0.0 {
                DCPhase += 180.0
            }
            if DCPhase > 315.0 {
                DCPhase -= 360.0
            }
            if today >= startIndex {
                outDouble[outIdx] = DCPhase
                outIdx += 1
            }
            smoothPrice_Idx += 1
            if smoothPrice_Idx > maxIdx_smoothPrice {
                smoothPrice_Idx = 0
            }
            today += 1
        }
    }
    
    public class func calculate(startIndex: Int,
                                endIndex: Int,
                                inCandle: [TA_Candle],
                                inCandleInputType: TA_CandleInputType,
                                outElementStartIndex: inout Int,
                                outElementCount: inout Int,
                                outDouble: inout [Double]) -> TA_ReturnCode
    {
        var startIndex = startIndex
        
        outElementStartIndex = 0
        outElementCount = 0
        
        if startIndex < 0 {
            return TA_ReturnCode.OutOfRangeStartIndex
        }
        if endIndex < 0 || endIndex < startIndex {
            return TA_ReturnCode.OutOfRangeStartIndex
        }
        let lookbackTotal = self.lookback()
        if startIndex < lookbackTotal {
            startIndex = lookbackTotal
        }
        if startIndex > endIndex {
            outElementStartIndex = 0
            outElementCount = 0
            return TA_ReturnCode.Success
        }
        
        let allocationSize = self.allocationSize(startIndex: startIndex,
                                                 endIndex: endIndex)
        outDouble = [Double](repeating: Double.nan, count: allocationSize)
        
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
        var smoothPrice_Idx = 0
        let maxIdx_smoothPrice = 0x31
        var smoothPrice = [Double](repeating: 0.0, count: maxIdx_smoothPrice + 1)
        var tempReal = atan(1.0)
        let rad2Deg = 45.0 / tempReal
        let constDeg2RadBy360 = tempReal * 8.0
        outElementStartIndex = startIndex
        var trailingWMAIdx = startIndex - lookbackTotal
        var today = trailingWMAIdx
        tempReal = inCandle[today][inCandleInputType]
        today += 1
        var periodWMASub = tempReal
        var periodWMASum = tempReal
        tempReal = inCandle[today][inCandleInputType]
        today += 1
        periodWMASub += tempReal
        periodWMASum += tempReal * 2.0
        tempReal = inCandle[today][inCandleInputType]
        today += 1
        periodWMASub += tempReal
        periodWMASum += tempReal * 3.0
        var trailingWMAValue = 0.0
        var i = 0x22
        repeat {
            tempReal = inCandle[today][inCandleInputType]
            today += 1
            periodWMASub += tempReal
            periodWMASub -= trailingWMAValue
            periodWMASum += tempReal * 4.0
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
        var I1ForEvenPrev3 = 0.0
        var I1ForOddPrev3 = I1ForEvenPrev3
        var I1ForEvenPrev2 = 0.0
        var I1ForOddPrev2 = I1ForEvenPrev2
        var smoothPeriod = 0.0
        i = 0
        while i < 50 {
            smoothPrice[i] = 0.0
            i += 1
        }
        var DCPhase = 0.0
        while true {
            var hilbertTempReal: Double
            var I2: Double
            var Q2: Double
            if today > endIndex {
                outElementCount = outIdx
                return TA_ReturnCode.Success
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
            smoothPrice[smoothPrice_Idx] = smoothedValue
            if today % 2 == 0 {
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
            }
            Re = (0.2 * ((I2 * prevI2) + (Q2 * prevQ2))) + (0.8 * Re)
            Im = (0.2 * ((I2 * prevQ2) - (Q2 * prevI2))) + (0.8 * Im)
            prevQ2 = Q2
            prevI2 = I2
            tempReal = period
            if (Im != 0.0) && (Re != 0.0) {
                period = 360.0 / (atan(Im / Re) * rad2Deg)
            }
            var tempReal2 = 1.5 * tempReal
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
            smoothPeriod = (0.33 * period) + (0.67 * smoothPeriod)
            var DCPeriod = smoothPeriod + 0.5
            let DCPeriodInt = Int(DCPeriod)
            var realPart = 0.0
            var imagPart = 0.0
            var idx = smoothPrice_Idx
            for i in stride(from: 0, to: DCPeriodInt, by: 1) {
                tempReal = (Double(i) * constDeg2RadBy360) / (Double(DCPeriodInt))
                tempReal2 = smoothPrice[idx]
                realPart += sin(tempReal) * tempReal2
                imagPart += cos(tempReal) * tempReal2
                if idx == 0 {
                    idx = 0x31
                } else {
                    idx -= 1
                }
            }
            tempReal = fabs(imagPart)
            if tempReal > 0.0 {
                DCPhase = atan(realPart / imagPart) * rad2Deg
            } else if tempReal <= 0.01 {
                if realPart > 0.0 {
                    DCPeriod -= 90.0
                } else if realPart > 0.0 {
                    DCPhase += 90.0
                }
            }
            DCPhase += 90.0
            DCPhase += 360.0 / smoothPeriod
            if imagPart < 0.0 {
                DCPhase += 180.0
            }
            if DCPhase > 315.0 {
                DCPhase -= 360.0
            }
            if today >= startIndex {
                outDouble[outIdx] = DCPhase
                outIdx += 1
            }
            smoothPrice_Idx += 1
            if smoothPrice_Idx > maxIdx_smoothPrice {
                smoothPrice_Idx = 0
            }
            today += 1
        }
    }
    
    public class func lookback() -> Int
    {
        return TA_Core.sharedInstance.globals.unstablePeriod[TA_FunctionUnstableId.HtDcPhase.rawValue] + 63
    }
    
    public class func allocationSize(startIndex: Int,
                                     endIndex: Int) -> Int
    {
        let lookback = self.lookback()
        let temp = max(lookback, startIndex)
        var allocationSize = 0
        if temp > endIndex {
        } else {
            allocationSize = endIndex - temp + 1
        }
        
        return allocationSize
    }
}




