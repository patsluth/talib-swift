//
//  TA_Candle.swift
//  SWQuestrade
//
//  Created by Pat Sluth on 2017-09-25.
//  Copyright © 2017 patsluth. All rights reserved.
//

import Foundation





public enum TA_CandleInputType: Int
{
    case Open
    case High
    case Low
    case Close
    case Volume
}





public protocol TA_Candle
{
    func ta_open() -> Double
    func ta_high() -> Double
    func ta_low() -> Double
    func ta_close() -> Double
    func ta_volume() -> Double
    
    subscript(candleInputType: TA_CandleInputType) -> Double { get }
}




