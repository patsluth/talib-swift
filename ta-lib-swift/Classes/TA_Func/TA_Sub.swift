//
//  TA_Sub.swift
//  ta-lib-swift
//
//  Created by Pat Sluth on 2017-09-18.
//  Copyright © 2017 patsluth. All rights reserved.
//

import Foundation





public class TA_Sub
{
    public class func calculate(startIndex: Int,
                                endIndex: Int,
                                inDouble0: [Double],
                                inDouble1: [Double],
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
        
        var i = startIndex
        var outIdx = 0
        while i <= endIndex {
            outDouble[outIdx] = inDouble0[i] - inDouble1[i]
            i += 1
            outIdx += 1
        }
        
        outElementStartIndex = startIndex
        outElementCount = outIdx
        
        return TA_ReturnCode.Success
    }
    
    public class func calculate(startIndex: Int,
                                endIndex: Int,
                                inCandle: [TA_Candle],
                                inCandleInputType0: TA_CandleInputType,
                                inCandleInputType1: TA_CandleInputType,
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
        
        var i = startIndex
        var outIdx = 0
        while i <= endIndex {
            outDouble[outIdx] = inCandle[i][inCandleInputType0] - inCandle[i][inCandleInputType1]
            i += 1
            outIdx += 1
        }
        
        outElementStartIndex = startIndex
        outElementCount = outIdx
        
        return TA_ReturnCode.Success
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
        
        let allocationSize = self.allocationSize(startIndex: startIndex,
                                                 endIndex: endIndex)
        outDouble = [Double](repeating: Double.nan, count: allocationSize)
        
        var i = startIndex
        var outIdx = 0
        while i <= endIndex {
            outDouble[outIdx] = acos(inCandle[i][inCandleInputType])
            i += 1
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




