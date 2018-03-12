//
//  TA_CandleDoji.swift
//  ta-lib-swift
//
//  Created by Pat Sluth on 2017-09-18.
//  Copyright © 2017 patsluth. All rights reserved.
//

import Foundation





public class TA_CandleDoji
{
    // TODO: TEST
    public class func recognize(startIndex: Int,
                                endIndex: Int,
                                inOpen: [Double],
                                inHigh: [Double],
                                inLow: [Double],
                                inClose: [Double],
                                outElementStartIndex: inout Int,
                                outElementCount: inout Int,
                                outInteger: inout [Int]) -> TA_ReturnCode
    {
        var startIndex = startIndex
        var endIndex = endIndex
        
        outElementStartIndex = 0
        outElementCount = 0
        outInteger.removeAll()
        
        guard let candleSettings = TA_Core.sharedInstance.globals.candleSettings[TA_CandleSettingType.BodyDoji] else {
            return TA_ReturnCode.InternalError
        }
        
        if startIndex < 0 {
            return TA_ReturnCode.OutOfRangeStartIndex
        }
        if endIndex < 0 || endIndex < startIndex {
            return TA_ReturnCode.OutOfRangeStartIndex
        }
        var lookbackTotal = self.lookback()
        if startIndex < lookbackTotal {
            startIndex = lookbackTotal
        }
        if startIndex > endIndex {
            outElementStartIndex = 0
            outElementCount = 0
            return TA_ReturnCode.Success
        }
        var bodyDojiPeriodTotal = 0.0
        var bodyDojiTrailingIdx = startIndex - self.lookback()
        var i = bodyDojiTrailingIdx
        while true {
            var num22: Double
            if i >= startIndex {
                break
            }
            if candleSettings.rangeType == TA_RangeType.RealBody {
                num22 = fabs(inClose[i] - inOpen[i])
            } else {
                var num21: Double
                if candleSettings.rangeType == TA_RangeType.HighLow {
                    num21 = inHigh[i] - inLow[i]
                } else {
                    var num18: Double
                    if candleSettings.rangeType == TA_RangeType.Shadows {
                        var num19: Double
                        var num20: Double
                        if inClose[i] >= inOpen[i] {
                            num19 = inOpen[i]
                            num20 = inClose[i]
                        } else {
                            num19 = inClose[i]
                            num20 = inOpen[i]
                        }
                        num18 = (inHigh[i] - num20) + (num19 - inLow[i])
                    } else {
                        num18 = 0.0
                    }
                    num21 = num18
                }
                num22 = num21
            }
            bodyDojiPeriodTotal += num22
            i += 1
        }
        var outIdx = 0
        repeat {
            var num5: Double
            var num10: Double
            var num11: Double
            var num17: Double
            if candleSettings.averagePeriod != 0 {
                num17 = bodyDojiPeriodTotal / Double(candleSettings.averagePeriod)
            } else {
                var num16: Double
                if candleSettings.rangeType == TA_RangeType.RealBody {
                    num16 = fabs(inClose[i] - inOpen[i])
                } else {
                    var num15: Double
                    if candleSettings.rangeType == TA_RangeType.HighLow {
                        num15 = inHigh[i] - inLow[i]
                    } else {
                        var num12: Double
                        if candleSettings.rangeType == TA_RangeType.Shadows {
                            var num13: Double
                            var num14: Double
                            if inClose[i] >= inOpen[i] {
                                num13 = inOpen[i]
                                num14 = inClose[i]
                            } else {
                                num13 = inClose[i]
                                num14 = inOpen[i]
                            }
                            num12 = (inHigh[i] - num14) + (num13 - inLow[i])
                        } else {
                            num12 = 0.0
                        }
                        num15 = num12
                    }
                    num16 = num15
                }
                num17 = num16
            }
            if candleSettings.rangeType == TA_RangeType.Shadows {
                num11 = 2.0
            } else {
                num11 = 1.0
            }
            if fabs(inClose[i] - inOpen[i]) <= ((candleSettings.factor * num17) / num11) {
                outInteger[outIdx] = 100
                outIdx += 1
            } else {
                outInteger[outIdx] = 0
                outIdx += 1
            }
            if candleSettings.rangeType == TA_RangeType.RealBody {
                num10 = fabs(inClose[i] - inOpen[i])
            } else {
                var num9: Double
                if candleSettings.rangeType == TA_RangeType.HighLow {
                    num9 = inHigh[i] - inLow[i]
                } else {
                    var num6: Double
                    if candleSettings.rangeType == TA_RangeType.Shadows {
                        var num7: Double
                        var num8: Double
                        if inClose[i] >= inOpen[i] {
                            num7 = inOpen[i]
                            num8 = inClose[i]
                        } else {
                            num7 = inClose[i]
                            num8 = inOpen[i]
                        }
                        num6 = (inHigh[i] - num8) + (num7 - inLow[i])
                    } else {
                        num6 = 0.0
                    }
                    num9 = num6
                }
                num10 = num9
            }
            if candleSettings.rangeType == TA_RangeType.RealBody {
                num5 = fabs(inClose[bodyDojiTrailingIdx] - inOpen[bodyDojiTrailingIdx])
            } else {
                var num4: Double
                if candleSettings.rangeType == TA_RangeType.HighLow {
                    num4 = inHigh[bodyDojiTrailingIdx] - inLow[bodyDojiTrailingIdx]
                } else {
                    var num: Double
                    if candleSettings.rangeType == TA_RangeType.Shadows {
                        var num2: Double
                        var num3: Double
                        if inClose[bodyDojiTrailingIdx] >= inOpen[bodyDojiTrailingIdx] {
                            num2 = inOpen[bodyDojiTrailingIdx]
                            num3 = inClose[bodyDojiTrailingIdx]
                        } else {
                            num2 = inClose[bodyDojiTrailingIdx]
                            num3 = inOpen[bodyDojiTrailingIdx]
                        }
                        num = (inHigh[bodyDojiTrailingIdx] - num3) + (num2 - inLow[bodyDojiTrailingIdx])
                    } else {
                        num = 0.0
                    }
                    num4 = num
                }
                num5 = num4
            }
            bodyDojiPeriodTotal += (num10 - num5)
            i += 1
            bodyDojiTrailingIdx += 1
        } while i < endIndex
        
        outElementCount = outIdx
        outElementStartIndex = startIndex
        
        return TA_ReturnCode.Success
    }
    
    public class func lookback() -> Int
    {
        if let candleSettings = TA_Core.sharedInstance.globals.candleSettings[TA_CandleSettingType.BodyDoji] {
            return candleSettings.averagePeriod
        }
        return 0
    }
}




