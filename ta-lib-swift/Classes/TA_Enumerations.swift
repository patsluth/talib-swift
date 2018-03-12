//
//  TA_Enumerations.swift
//  ta-lib-swift
//
//  Created by Pat Sluth on 2017-09-19.
//  Copyright © 2017 patsluth. All rights reserved.
//





public enum TA_CandleSettingType: Int
{
	case BodyLong
	case BodyVeryLong
	case BodyShort
	case BodyDoji
	case ShadowLong
	case ShadowVeryLong
	case ShadowShort
	case ShadowVeryShort
	case Near
	case Far
	case Equal
	
	static let allValues = [BodyLong,
	                        BodyVeryLong,
	                        BodyShort,
	                        BodyDoji,
	                        ShadowLong,
	                        ShadowVeryLong,
	                        ShadowShort,
	                        ShadowVeryShort,
	                        Near,
	                        Far,
	                        Equal]
}





public enum TA_Compatibility
{
	case Default
	case Metastock
}





public enum TA_FunctionUnstableId: Int
{
	case Adx = 0
	case Adxr = 1
	case AverageTrueRange = 2
	case Cmo = 3
	case Dx = 4
	case Ema = 5
	case FuncUnstAll = 0x17
	case FuncUnstNone = -1
	case HtDcPeriod = 6
	case HtDcPhase = 7
	case HtPhasor = 8
	case HtSine = 9
	case HtTrendline = 10
	case HtTrendMode = 11
	case Kama = 12
	case Mama = 13
	case Mfi = 14
	case MinusDI = 15
	case MinusDM = 0x10
	case NormalizedAverageTrueRange = 0x11
	case PlusDI = 0x12
	case PlusDM = 0x13
	case Rsi = 20
	case StochRsi = 0x15
	case T3 = 0x16
}





public enum TA_MovingAverageType
{
	case Sma
	case Ema
	case Wma
	case Dema
	case Tema
	case Trima
	case Kama
	case Mama
	case T3
}





public enum TA_RangeType
{
	case RealBody
	case HighLow
	case Shadows
}





@objc public enum TA_ReturnCode: Int
{
	case AllocErr = 3
	case BadObject = 15
	case BadParam = 2
	case FuncNotFound = 5
	case GroupNotFound = 4
	case InputNotAllInitialize = 10
	case InternalError = 0x1388
	case InvalidHandle = 6
	case InvalidListType = 14
	case InvalidParamFunction = 9
	case InvalidParamHolder = 7
	case InvalidParamHolderType = 8
	case LibNotInitialize = 1
	case NotSupported = 0x10
	case OutOfRangeEndIndex = 13
	case OutOfRangeStartIndex = 12
	case OutputNotAllInitialize = 11
	case Success = 0
	case UnknownErr = 0xffff
}




