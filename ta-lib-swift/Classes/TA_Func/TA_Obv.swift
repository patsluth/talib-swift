//
//  TA_Obv.swift
//  ta-lib-swift
//
//  Created by Pat Sluth on 2017-09-18.
//  Copyright © 2017 patsluth. All rights reserved.
//

import Foundation





// OBV - On Balance Volume
public class TA_Obv
{
    public class func calculate(startIndex: Int,
                                endIndex: Int,
                                inDouble: [Double],
                                inVolume: [Double],
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
        
        var prevOBV = inVolume[startIndex]
        var prevReal = inDouble[startIndex]
        var outIdx = 0
        
        for i in stride(from: startIndex, through: endIndex, by: 1) {
            let tempReal = inDouble[i]
            if tempReal > prevReal {
                prevOBV += inVolume[i]
            } else if tempReal < prevReal {
                prevOBV -= inVolume[i]
            }
            outDouble[outIdx] = prevOBV
            outIdx += 1
            prevReal = tempReal
        }
        
        outElementStartIndex = startIndex
        outElementCount = outIdx
        
        return TA_ReturnCode.Success
    }
    
    public class func calculate(startIndex: Int,
                                endIndex: Int,
                                inCandle: [TA_Candle],
                                inCandleInputType: TA_CandleInputType,
                                optInTimePeriod: Int,
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
        
        var prevOBV = inCandle[startIndex][TA_CandleInputType.Volume]
        var prevReal = inCandle[startIndex][inCandleInputType]
        var outIdx = 0
        
        for i in stride(from: startIndex, through: endIndex, by: 1) {
            let tempReal = inCandle[i][inCandleInputType]
            if tempReal > prevReal {
                prevOBV += inCandle[i][TA_CandleInputType.Volume]
            } else if tempReal < prevReal {
                prevOBV -= inCandle[i][TA_CandleInputType.Volume]
            }
            outDouble[outIdx] = prevOBV
            outIdx += 1
            prevReal = tempReal
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




