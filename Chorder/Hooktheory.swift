//
//  Hooktheory.swift
//  Chorder
//
//  Created by Michael Pace on 4/16/17.
//  Copyright © 2017 Michael Pace. All rights reserved.
//

import Foundation

extension Numeral {

    init?(hooktheoryString: String) {
        switch hooktheoryString {
        case "1":
            self = .one
        case "2":
            self = .two
        case "3":
            self = .three
        case "4":
            self = .four
        case "5":
            self = .five
        case "6":
            self = .six
        case "7":
            self = .seven
        default:
            return nil
        }
    }

}

extension Mode {

    init?(hooktheoryString: String) {
        switch hooktheoryString.lowercased() {
        case "d":
            self = .dorian
        case "y":
            self = .phrygian
        case "l":
            self = .lydian
        case "m":
            self = .mixolydian
        case "b":
            self = .aeolian
        case "c":
            self = .locrian
        default:
            return nil
        }
    }

}

extension Inversion {

    init?(hooktheoryString: String) {
        switch hooktheoryString {
        case "42":
            self = .fourTwo
        case "43":
            self = .fourThree
        case "6":
            self = .six
        case "64":
            self = .sixFour
        case "65":
            self = .sixFive
        case "7":
            self = .seven
        default:
            return nil
        }
    }

}

extension Function {

    init?(hooktheoryString: String) {
        switch hooktheoryString {
        case "4":
            self = .four
        case "5":
            self = .five
        case "7":
            self = .seven
        default:
            return nil
        }
    }
    
}
