//
//  Parser.swift
//  Chorder
//
//  Created by Michael Pace on 4/16/17.
//  Copyright © 2017 Michael Pace. All rights reserved.
//

import Foundation

struct Parser {

    static func parse(tokens: [Token]) -> Chord? {

        switch tokens.count {
        case 3:
            let threeTokens = (tokens[0], tokens[1], tokens[2])

            if case (let .letter(modeString), let .number(numeralString), let .additionalNumbers(inversionString)) = threeTokens {

                guard
                    let mode = Mode(hooktheoryString: modeString),
                    let numeral = Numeral(hooktheoryString: numeralString),
                    let inversion = Inversion(hooktheoryString: inversionString) else
                {
                    assertionFailure("Invalid tokens: \(tokens)")
                    return nil
                }

                return Chord(mode: mode, inversion: inversion, function: nil, numeral: numeral)

            } else if case (let .number(functionString), let .additionalNumbers(inversionString), let .number(numeralString)) = threeTokens {

                guard
                    let function = Function(hooktheoryString: functionString),
                    let inversion = Inversion(hooktheoryString: inversionString),
                    let numeral = Numeral(hooktheoryString: numeralString) else
                {
                    assertionFailure("Invalid tokens: \(tokens)")
                    return nil
                }

                return Chord(mode: .ionian, inversion: inversion, function: function, numeral: numeral)

            } else {
                assertionFailure("Unexpected sequence of tokens: \(tokens)"); return nil
            }

        case 2:
            let twoTokens = (tokens[0], tokens[1])

            if case (let .letter(modeString), let .number(numeralString)) = twoTokens {

                guard
                    let mode = Mode(hooktheoryString: modeString),
                    let numeral = Numeral(hooktheoryString: numeralString) else
                {
                    assertionFailure("Invalid tokens: \(tokens)")
                    return nil
                }

                return Chord(mode: mode, inversion: nil, function: nil, numeral: numeral)

            } else if case (let .number(numeralString), let .additionalNumbers(inversionString)) = twoTokens {

                guard
                    let numeral = Numeral(hooktheoryString: numeralString),
                    let inversion = Inversion(hooktheoryString: inversionString) else
                {
                    assertionFailure("Invalid tokens: \(tokens)")
                    return nil
                }

                return Chord(mode: .ionian, inversion: inversion, function: nil, numeral: numeral)

            } else if case (let .number(functionString), let .number(numeralString)) = twoTokens {

                guard
                    let function = Function(hooktheoryString: functionString),
                    let numeral = Numeral(hooktheoryString: numeralString) else
                {
                    assertionFailure("Invalid tokens: \(tokens)")
                    return nil
                }

                return Chord(mode: .ionian, inversion: nil, function: function, numeral: numeral)

            }

        case 1:
            guard case let .number(numeralString) = tokens[0], let numeral = Numeral(hooktheoryString: numeralString) else { assertionFailure("Invalid tokens: \(tokens)"); return nil }
            return Chord(mode: .ionian, inversion: nil, function: nil, numeral: numeral)
            
        default:
            assertionFailure("Invalid tokens: \(tokens)")
            return nil
            
        }
        
        return nil
    }
    
}
