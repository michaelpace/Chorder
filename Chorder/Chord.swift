//
//  Chord.swift
//  Chorder
//
//  Created by Michael Pace on 4/16/17.
//  Copyright © 2017 Michael Pace. All rights reserved.
//

import Foundation

// MARK: - Property types

enum Numeral {
    case one
    case two
    case three
    case four
    case five
    case six
    case seven

    var defaultMode: Mode {
        switch self {
        case .one:
            return .ionian
        case .two:
            return .dorian
        case .three:
            return .phrygian
        case .four:
            return .lydian
        case .five:
            return .mixolydian
        case .six:
            return .aeolian
        case .seven:
            return .locrian
        }
    }
}

enum Mode {
    case ionian
    case dorian
    case phrygian
    case lydian
    case mixolydian
    case aeolian
    case locrian
}

// TODO: Find actual names for these.
enum Inversion {
    case fourTwo
    case fourThree
    case six
    case sixFour
    case sixFive
    case seven
}

enum Function {
    case four
    case five
    case seven
}

// MARK: - Chord

struct Chord {
    let mode: Mode
    let inversion: Inversion?
    let function: Function?
    let numeral: Numeral
    var notes: [Int] {
        return [1, 4, 7]
    }
}
