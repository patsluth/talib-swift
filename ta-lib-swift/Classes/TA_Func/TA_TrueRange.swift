//
//  TA_TrueRange.swift
//  ta-lib-swift
//
//  Created by Pat Sluth on 2017-09-18.
//  Copyright © 2017 patsluth. All rights reserved.
//

import Foundation





// TRANGE - True Range
public class TA_TrueRange
{
    public class func calculate(startIndex: Int,
                                endIndex: Int,
                                inOpen: [Double],
                                inHigh: [Double],
                                inLow: [Double],
                                inClose: [Double],
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
        if startIndex < 1 {
            startIndex = 1
        }
        if startIndex > endIndex {
            outElementStartIndex = 0
            outElementCount = 0
            return TA_ReturnCode.Success
        }
        
        let allocationSize = self.allocationSize(startIndex: startIndex,
                                                 endIndex: endIndex)
        outDouble = [Double](repeating: Double.nan, count: allocationSize)
        
        var outIdx: Int = 0
        var today: Int = startIndex
        while true {
            if today > endIndex {
                break
            }
            let tempLT = inLow[today]
            let tempHT = inHigh[today]
            let tempCY = inClose[today - 1]
            var greatest = tempHT - tempLT
            let val2 = fabs(tempCY - tempHT)
            if val2 > greatest {
                greatest = val2
            }
            let val3 = fabs(tempCY - tempLT)
            if val3 > greatest {
                greatest = val3
            }
            outDouble[outIdx] = greatest
            outIdx += 1
            today += 1
        }
        outElementStartIndex = startIndex
        outElementCount = outIdx
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
        if startIndex > endIndex {
            outElementStartIndex = 0
            outElementCount = 0
            return TA_ReturnCode.Success
        }
        
        let allocationSize = self.allocationSize(startIndex: startIndex,
                                                 endIndex: endIndex)
        outDouble = [Double](repeating: Double.nan, count: allocationSize)
        
        var outIdx: Int = 0
        var today: Int = startIndex
        while true {
            if today > endIndex {
                break
            }
            let tempLT = inCandle[today][TA_CandleInputType.Low]
            let tempHT = inCandle[today][TA_CandleInputType.High]
            let tempCY = inCandle[today - 1][TA_CandleInputType.Close]
            var greatest = tempHT - tempLT
            let val2 = fabs(tempCY - tempHT)
            if val2 > greatest {
                greatest = val2
            }
            let val3 = fabs(tempCY - tempLT)
            if val3 > greatest {
                greatest = val3
            }
            outDouble[outIdx] = greatest
            outIdx += 1
            today += 1
        }
        
        outElementStartIndex = startIndex
        outElementCount = outIdx
        
        return TA_ReturnCode.Success
    }
    
    public class func lookback() -> Int
    {
        return 1
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




