//
//  TA_AvgPrice.swift
//  ta-lib-swift
//
//  Created by Pat Sluth on 2017-09-18.
//  Copyright © 2017 patsluth. All rights reserved.
//

import Foundation





// AVGPRICE - Average Price
public class TA_AvgPrice
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
        for i in stride(from: startIndex, through: endIndex, by: 1) {
            outDouble[outIdx] = (((inHigh[i] + inLow[i]) + inClose[i]) + inOpen[i]) / 4.0
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
        for i in stride(from: startIndex, through: endIndex, by: 1) {
            let high = inCandle[i][TA_CandleInputType.High]
            let low = inCandle[i][TA_CandleInputType.Low]
            let close = inCandle[i][TA_CandleInputType.Close]
            let open = inCandle[i][TA_CandleInputType.Open]
            outDouble[outIdx] = (((high + low) + close) + open) / 4.0
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




