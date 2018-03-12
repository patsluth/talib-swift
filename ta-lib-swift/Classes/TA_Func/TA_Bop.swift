//
//  TA_Bop.swift
//  ta-lib-swift
//
//  Created by Pat Sluth on 2017-09-18.
//  Copyright © 2017 patsluth. All rights reserved.
//

import Foundation





// BOP - Balance Of Power
public class TA_Bop
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
        outElementStartIndex = 0
        outElementCount = 0
        
        if startIndex < 0 {
            return TA_ReturnCode.OutOfRangeStartIndex
        }
        if endIndex < 0 || endIndex < startIndex {
            return TA_ReturnCode.OutOfRangeStartIndex
        }
        
        let allocationSize = self.allocationSize(startIndex: startIndex,
                                                 endIndex: endIndex)
        outDouble = [Double](repeating: Double.nan, count: allocationSize)
        
        var outIdx = 0
        for i in (startIndex...endIndex) {
            let tempReal = inHigh[i] - inLow[i]
            if tempReal < 1E-08 {
                outDouble[outIdx] = 0.0
            } else {
                outDouble[outIdx] = (inClose[i] - inOpen[i]) / tempReal
            }
            outIdx += 1
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
        outElementStartIndex = 0
        outElementCount = 0
        
        if startIndex < 0 {
            return TA_ReturnCode.OutOfRangeStartIndex
        }
        if endIndex < 0 || endIndex < startIndex {
            return TA_ReturnCode.OutOfRangeStartIndex
        }
        
        let allocationSize = self.allocationSize(startIndex: startIndex,
                                                 endIndex: endIndex)
        outDouble = [Double](repeating: Double.nan, count: allocationSize)
        
        var outIdx = 0
        for i in (startIndex...endIndex) {
            let tempReal = inCandle[i][TA_CandleInputType.High] - inCandle[i][TA_CandleInputType.Low]
            if tempReal < 1E-08 {
                outDouble[outIdx] = 0.0
            } else {
                outDouble[outIdx] = (inCandle[i][TA_CandleInputType.Close] - inCandle[i][TA_CandleInputType.Open]) / tempReal
            }
            outIdx += 1
        }
        
        outElementStartIndex = startIndex
        outElementCount = outIdx
        
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




