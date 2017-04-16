//
//  Tokenizer.swift
//  Chorder
//
//  Created by Michael Pace on 4/16/17.
//  Copyright © 2017 Michael Pace. All rights reserved.
//

import Foundation

// MARK: - Token

enum Token: Equatable {
    case letter(value: String)
    case number(value: String)
    case additionalNumbers(value: String)
    case slash

    init?(character: Character) {
        if character.isLetter {
            self = .letter(value: String(character))
        } else if character.isNumeric {
            self = .number(value: String(character))
        } else if character.isSlash {
            self = .slash
        } else {
            return nil
        }
    }

    // MARK: Equatable

    static func == (lhs: Token, rhs: Token) -> Bool {
        switch (lhs, rhs) {
        case (.letter, .letter), (.number, .number), (.additionalNumbers, .additionalNumbers), (.slash, .slash):
            return true
        default:
            return false
        }
    }
    
}

// MARK: - Tokenizer

struct Tokenizer {

    static func tokenize(string: String) -> [Token]? {
        let characters = string.characters

        var tokens = [Token]()
        var index = string.characters.startIndex

        while index != characters.endIndex {

            let character = characters[index]
            guard let token = Token(character: characters[index]) else { assertionFailure("Encountered unexpected character: \(character)"); break }
            if token != .slash {
                tokens.append(token)
            }

            // Only continue beyond this guard to parse additional numbers if _this_ one was a number. Otherwise, we'll pick them up on the next loop.
            guard character.isNumeric else { index = characters.index(after: index); continue }

            var nextIndex = characters.index(after: index)
            var numbersSeen = String()

            while nextIndex != characters.endIndex {
                let nextCharacter = characters[nextIndex]
                guard nextCharacter.isNumeric else { break }

                numbersSeen.append(nextCharacter)
                nextIndex = characters.index(after: nextIndex)
            }

            guard numbersSeen.characters.count > 0 else { index = characters.index(after: index); continue }

            tokens.append(.additionalNumbers(value: numbersSeen))
            index = nextIndex
        }
        
        return tokens
    }
    
}
