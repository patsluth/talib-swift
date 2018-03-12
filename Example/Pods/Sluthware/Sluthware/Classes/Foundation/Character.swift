//
//  Array.swift
//  Sluthware
//
//  Created by Pat Sluth on 2017-09-30.
//  Copyright © 2017 patsluth. All rights reserved.
//

import Foundation





public extension Character
{
	var isNumeric: Bool {
		guard let unicodeScalar = self.unicodeScalars.first else { return false }
		return CharacterSet.decimalDigits.contains(unicodeScalar)
	}
	
	var isLetter: Bool {
		guard let unicodeScalar = self.unicodeScalars.first else { return false }
		return CharacterSet.letters.contains(unicodeScalar)
	}
	
	var isLowercaseLetter: Bool {
		guard let unicodeScalar = self.unicodeScalars.first else { return false }
		return CharacterSet.lowercaseLetters.contains(unicodeScalar)
	}
	
	var isUpperLetter: Bool {
		guard let unicodeScalar = self.unicodeScalars.first else { return false }
		return CharacterSet.uppercaseLetters.contains(unicodeScalar)
	}
	
	var isAlphaNumeric: Bool {
		guard let unicodeScalar = self.unicodeScalars.first else { return false }
		return CharacterSet.alphanumerics.contains(unicodeScalar)
	}
	
	var isWhitespace: Bool {
		guard let unicodeScalar = self.unicodeScalars.first else { return false }
		return CharacterSet.whitespaces.contains(unicodeScalar)
	}
	
	var isIllegal: Bool {
		guard let unicodeScalar = self.unicodeScalars.first else { return false }
		return CharacterSet.illegalCharacters.contains(unicodeScalar)
	}
}




