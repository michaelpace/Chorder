//
//  Character+Convenience.swift
//  Chorder
//
//  Created by Michael Pace on 4/16/17.
//  Copyright © 2017 Michael Pace. All rights reserved.
//

import Foundation

/// Provides convenience properties and functions to `Character`.
extension Character {

    /// Whether this character is a number between 0 and 9.
    var isNumeric: Bool {
        guard let unicodeScalar = unicodeScalar else { return false }
        return CharacterSet.decimalDigits.contains(unicodeScalar)
    }

    /// Whether this character is a letter.
    var isLetter: Bool {
        guard let unicodeScalar = unicodeScalar else { return false }
        return CharacterSet.letters.contains(unicodeScalar)
    }

    /// Whether this character is a forward slash.
    var isSlash: Bool {
        guard let unicodeScalar = unicodeScalar else { return false }
        return CharacterSet(charactersIn: "/").contains(unicodeScalar)
    }
    
}

// MARK: Private

private extension Character {

    var unicodeScalar: UnicodeScalar? {
        return String(self).unicodeScalars.first
    }

}
