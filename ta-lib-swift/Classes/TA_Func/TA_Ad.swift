//
//  TA_Ad.swift
//  ta-lib-swift
//
//  Created by Pat Sluth on 2017-09-18.
//  Copyright © 2017 patsluth. All rights reserved.
//

import Foundation





// AD - Chaikin A/D Line
public class TA_Ad
{
    public class func calculate(startIndex: Int,
                                endIndex: Int,
                                inHigh: [Double],
                                inLow: [Double],
                                inClose: [Double],
                                inVolume: [Double],
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
        
        let allocationSize = self.allocationSize(startIndex: startIndex,
                                                 endIndex: endIndex)
        outDouble = [Double](repeating: Double.nan, count: allocationSize)
        
        var nbBar = (endIndex - startIndex) + 1
        outElementStartIndex = startIndex
        outElementCount = nbBar
        var currentBar = startIndex
        var outIdx = 0
        var ad = 0.0
        while true {
            if nbBar == 0 {
                break
            }
            let high = inHigh[currentBar]
            let low = inLow[currentBar]
            let tmp = high - low
            let close = inClose[currentBar]
            if tmp > 0.0 {
                ad += (((close - low) - (high - close)) / tmp) * inVolume[currentBar]
            }
            outDouble[outIdx] = ad
            outIdx += 1
            currentBar += 1
            nbBar -= 1
        }
        
        return TA_ReturnCode.Success
    }
    
    public class func calculate(startIndex: Int,
                                endIndex: Int,
                                inCandle: [TA_Candle],
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
        
        let allocationSize = self.allocationSize(startIndex: startIndex,
                                                 endIndex: endIndex)
        outDouble = [Double](repeating: Double.nan, count: allocationSize)
        
        var nbBar = (endIndex - startIndex) + 1
        outElementStartIndex = startIndex
        outElementCount = nbBar
        var currentBar = startIndex
        var outIdx = 0
        var ad = 0.0
        while true {
            if nbBar == 0 {
                break
            }
            let high = inCandle[currentBar][TA_CandleInputType.High]
            let low = inCandle[currentBar][TA_CandleInputType.Low]
            let tmp = high - low
            let close = inCandle[currentBar][TA_CandleInputType.Close]
            if tmp > 0.0 {
                ad += (((close - low) - (high - close)) / tmp) * inCandle[currentBar][TA_CandleInputType.Volume]
            }
            outDouble[outIdx] = ad
            outIdx += 1
            currentBar += 1
            nbBar -= 1
        }
        
        return TA_ReturnCode.Success
    }
    
    public class func lookback() -> Int
    {
        return 0
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




