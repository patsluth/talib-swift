//
//  TA_ArrayUtils.swift
//  SWQuestrade
//
//  Created by Pat Sluth on 2017-09-25.
//  Copyright © 2017 patsluth. All rights reserved.
//

import Foundation





internal final class TA_ArrayUtils
{
    public class func Copy<T>(sourceArray: [T],
                              sourceIndex: Int,
                              destinationArray: inout [T],
                              destinationIndex: Int,
                              length: Int)
    {
        var sourceIndex = sourceIndex
        var destinationIndex = destinationIndex
        var count = 0
        
        while count < length {
            destinationArray[destinationIndex] = sourceArray[sourceIndex]
            sourceIndex += 1
            destinationIndex += 1
            count += 1
        }
    }
    
    public class func CopyCandleValues(sourceArray: [TA_Candle],
                                       sourceIndex: Int,
                                       sourceCandleInputType: TA_CandleInputType,
                                       destinationArray: inout [Double],
                                       destinationIndex: Int,
                                       length: Int)
    {
        var sourceIndex = sourceIndex
        var destinationIndex = destinationIndex
        var count = 0
        
        while count < length {
            destinationArray[destinationIndex] = sourceArray[sourceIndex][sourceCandleInputType]
            sourceIndex += 1
            destinationIndex += 1
            count += 1
        }
    }
}




