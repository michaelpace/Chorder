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

    var root: Int {
        switch self {
        case .one:
            return 0
        case .two:
            return 1
        case .three:
            return 2
        case .four:
            return 3
        case .five:
            return 4
        case .six:
            return 5
        case .seven:
            return 6
        }
    }
}

extension Array {

    func wrappedFrom(_ index: Int) -> Array {
        return Array(suffix(from: index)) + Array(prefix(upTo: index))
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

    var intervals: [Int] {
        switch self {
        case .ionian:
            return [0, 2, 4, 5, 7, 9, 11]
        case .dorian:
            return Mode.ionian.intervals.wrappedFrom(1)
        case .phrygian:
            return Mode.ionian.intervals.wrappedFrom(2)
        case .lydian:
            return Mode.ionian.intervals.wrappedFrom(3)
        case .mixolydian:
            return Mode.ionian.intervals.wrappedFrom(4)
        case .aeolian:
            return Mode.ionian.intervals.wrappedFrom(5)
        case .locrian:
            return Mode.ionian.intervals.wrappedFrom(6)
        }
    }
}

// TODO: Find actual names for these.
enum Inversion {
    case fourTwo
    case fourThree
    case six
    case sixFour
    case sixFive
    case seven

    var additionalIndices: [Int]? {
        switch self {
        case .fourTwo, .fourThree, .six, .sixFour, .sixFive:
            return nil
        case .seven:
            return [6]
        }
    }
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

    private let triadIndices = [0, 2, 4]

    var notes: [Int] {
        let chordIndices: [Int] = {
            var result = triadIndices

            if let additionalInversionIndices = inversion?.additionalIndices {
                result.append(contentsOf: additionalInversionIndices)
            }

            return result
        }()

        let transposedTriad = chordIndices.map { $0 + numeral.root }
        let possiblyInvertedTriad = transposedTriad.map { $0 % mode.intervals.count }

        return possiblyInvertedTriad.map { mode.intervals[$0] }
    }
}
