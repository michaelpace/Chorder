//
//  main.swift
//  Chorder
//
//  Created by Michael Pace on 4/7/17.
//  Copyright © 2017 Michael Pace. All rights reserved.
//

import Foundation

// MARK: - Types

/// Represents a parsed command line argument.
struct Argument {

    /// The command line key for this argument.
    let key: Key

    /// The command line value for this argument.
    let value: String

    // MARK: Initialization

    init?(key: String, value: String) {
        guard let validKey = Key(rawValue: key) else { return nil }

        self.key = validKey
        self.value = value
    }

    // MARK: Nested types

    /// Encapsulates keys for command line arguments.
    enum Key: String {

        /// Key for a Hooktheory API activkey.
        case activkey = "--activkey"

        /// Key for the time signature to use.
        case timeSignature = "--ts"
    }
}

/// Represents a configuration passed in via the command line with which to run Chorder.
struct Configuration {

    /// The activkey with which to authenticate with Hooktheory's API.
    let activkey: String

    /// The time signature with which to generate chords.
    let timeSignature: TimeSignature

    init?(arguments: [Argument]) {
        guard
            let activkey = arguments.first(where: { $0.key == .activkey })?.value,
            let timeSignatureString = arguments.first(where: { $0.key == .timeSignature })?.value,
            let timeSignature = TimeSignature(rawValue: timeSignatureString) else
        { return nil }

        self.activkey = activkey
        self.timeSignature = timeSignature
    }

}

/// Encapsulates various time signatures supported by Chorder.
enum TimeSignature: String {

    /// A 3/4 time signature.
    case threeFour = "3/4"

    /// A 4/4 time signature.
    case fourFour = "4/4"

    /// Valid beats in a measure for a chord to land in this time signature.
    var validChordBeats: [[Int]] {
        switch self {
        case .threeFour:
            return [[1], [1, 2], [1, 3]]
        case .fourFour:
            return [[1], [1, 3], [1, 4], [2, 4], [3]]
        }
    }
}

/// Represents the rhythm of a measure.
struct MeasureRhythm {

    /// An array of `Int`s in which each `Int` represents a beat that has a chord in this measure.
    let beatsWithChords: [Int]

}

// MARK: - Networking

func urlSession(with activkey: String) -> URLSession {
    let sessionConfiguration = URLSessionConfiguration.default
    sessionConfiguration.httpAdditionalHeaders = ["Authorization": "Bearer \(activkey)"]
    return URLSession(configuration: sessionConfiguration)
}

/// A protocol describing a type which is a process which can be finished.
protocol Process {

    /// Whether this process is finished. Set to `true` to finish the process.
    var isFinished: Bool { get set }

    /// Starts the process.
    func start()
}

/// Represents a Hooktheory chord, as returned from the `trends/nodes` endpoint.
struct HooktheoryChord {

    /// The chord's Hooktheory ID.
    let id: String

    /// The chord's HTML representation.
    let html: String

    /// The chord's probability of occurring relative to all chords within Hooktheory's database. This probability is independent of the chord progression containing this chord.
    let probability: Double

    /// The chord's child path describing the sequence of chords culminating with this chord. Used to ask Hooktheory about chords following this chord.
    let childPath: String

    /// Initializes a new `Chord` given a JSON object retrieved from Hooktheory's API. May return `nil` if invalid JSON is provided.
    ///
    /// - parameter json: The JSON retrieved from Hooktheory's API. Expected to contain "chord_ID", "chord_HTML", "probability", and "child_path" key-value pairs.
    init?(json: [String: Any]?) {
        guard let json = json else { return nil }

        guard
            let id = json["chord_ID"] as? String,
            let html = json["chord_HTML"] as? String,
            let probability = json["probability"] as? Double,
            let childPath = json["child_path"] as? String else { return nil }

        self.id = id
        self.html = html
        self.probability = probability
        self.childPath = childPath

    }
}

extension Character {

    var unicodeScalar: UnicodeScalar? {
        return String(self).unicodeScalars.first
    }

    var isNumeric: Bool {
        guard let unicodeScalar = unicodeScalar else { return false }
        return CharacterSet.decimalDigits.contains(unicodeScalar)
    }

    var isLetter: Bool {
        guard let unicodeScalar = unicodeScalar else { return false }
        return CharacterSet.letters.contains(unicodeScalar)
    }

    var isSlash: Bool {
        guard let unicodeScalar = unicodeScalar else { return false }
        return CharacterSet(charactersIn: "/").contains(unicodeScalar)
    }

}

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

enum Mode {
    case ionian
    case dorian
    case phrygian
    case lydian
    case mixolydian
    case aeolian
    case locrian
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

// TODO: Find actual names for these.
enum Inversion {
    case fourTwo
    case fourThree
    case six
    case sixFour
    case sixFive
    case seven
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

enum Function {
    case four
    case five
    case seven
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

protocol Chord {
    var numeral: Numeral { get }
    var notes: [Int] { get }
}

struct SimpleChord: Chord {
    let mode: Mode
    let inversion: Inversion?

    // MARK: Chord
    let numeral: Numeral
    var notes: [Int] {
        return [1, 4, 7]
    }
}

struct AppliedChord: Chord {
    let function: Function
    let inversion: Inversion?

    // MARK: Chord

    let numeral: Numeral
    var notes: [Int] {
        return [1, 4, 7]
    }
}

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

                return SimpleChord(mode: mode, inversion: inversion, numeral: numeral)

            } else if case (let .number(functionString), let .additionalNumbers(inversionString), let .number(numeralString)) = threeTokens {

                guard
                    let function = Function(hooktheoryString: functionString),
                    let inversion = Inversion(hooktheoryString: inversionString),
                    let numeral = Numeral(hooktheoryString: numeralString) else
                {
                    assertionFailure("Invalid tokens: \(tokens)")
                    return nil
                }

                return AppliedChord(function: function, inversion: inversion, numeral: numeral)

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

                return SimpleChord(mode: mode, inversion: nil, numeral: numeral)

            } else if case (let .number(numeralString), let .additionalNumbers(inversionString)) = twoTokens {

                guard
                    let numeral = Numeral(hooktheoryString: numeralString),
                    let inversion = Inversion(hooktheoryString: inversionString) else
                {
                    assertionFailure("Invalid tokens: \(tokens)")
                    return nil
                }

                return SimpleChord(mode: numeral.defaultMode, inversion: inversion, numeral: numeral)

            } else if case (let .number(functionString), let .number(numeralString)) = twoTokens {

                guard
                    let function = Function(hooktheoryString: functionString),
                    let numeral = Numeral(hooktheoryString: numeralString) else
                {
                    assertionFailure("Invalid tokens: \(tokens)")
                    return nil
                }

                return AppliedChord(function: function, inversion: nil, numeral: numeral)

            }

        case 1:
            guard case let .number(numeralString) = tokens[0], let numeral = Numeral(hooktheoryString: numeralString) else { assertionFailure("Invalid tokens: \(tokens)"); return nil }
            return SimpleChord(mode: numeral.defaultMode, inversion: nil, numeral: numeral)

        default:
            assertionFailure("Invalid tokens: \(tokens)")
            return nil

        }

        return nil
    }

}

final class Chorder: Process {

    // MARK: - Process

    var isFinished = false

    func start() {
        let enumeratedArguments = CommandLine.arguments.suffix(from: 1).enumerated()
        let keys = enumeratedArguments.flatMap { (index, argument) in return index.isEven ? argument : nil }
        let values = enumeratedArguments.flatMap { (index, argument) in return index.isOdd ? argument : nil }
        let parsedArguments = zip(keys, values).flatMap { (key, value) in return Argument(key: key, value: value) }
        guard let configuration = Configuration(arguments: parsedArguments) else { fatalError("Invalid arguments.") }

        main(configuration: configuration)
    }

    private func main(configuration: Configuration) {

        // TODO: Constant-ize or configure-ize [2, 4, 8]?
        guard let numberOfMeasures = [2, 4, 8].randomElement else { return assertionFailure("Failure retrieving a random element.") }
        let measureRhythms: [MeasureRhythm] = (0..<numberOfMeasures).flatMap { _ in
            guard let beatsWithChords = configuration.timeSignature.validChordBeats.randomElement else { assertionFailure("Failure retrieving a random element."); return nil }
            return MeasureRhythm(beatsWithChords: beatsWithChords)
        }

        // TODO: Start here next time. Organize this stuff. Should only need to make cp-less /trends/nodes request once, and then can append the query parameter `cp`, like `?cp=4,1` or w/e. See https://www.hooktheory.com/api/trends/docs and http://forum.hooktheory.com/t/trends-api-chord-input/272

        let session = urlSession(with: configuration.activkey)

        var childPath = ""
        print("going to request \(measureRhythms.count) chords")

        func request(with measureRhythms: [MeasureRhythm]) {
            guard let _ = measureRhythms.first else {
                print("requested all the chords")
                isFinished = true
                return
            }

            sleep(1)

            var urlComponents = URLComponents(string: "https://api.hooktheory.com/v1/trends/nodes")
            if !childPath.isEmpty {
                urlComponents?.queryItems = [URLQueryItem(name: "cp", value: childPath)]
            }
            guard let url = urlComponents?.url else { return assertionFailure("Invalid URL") }

            let task = session.dataTask(with: url) { (data, response, error) in
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    print("non-200")
                    self.isFinished = true
                    return
                }

                if let error = error {
                    print("error: \(error)")
                    return
                }

                guard let data = data else {
                    print("no data")
                    return
                }

                do {
                    let commonChords = try JSONSerialization.jsonObject(with: data, options: []) as! [[String: Any]]

                    guard
                        let chordJSON = Array(commonChords.prefix(8)).randomElement else
                    {
                        print("no chords returned from hooktheory")
                        self.isFinished = true
                        return
                    }

                    guard let hooktheoryChord = HooktheoryChord(json: chordJSON) else {
                        print("invalid chord")
                        self.isFinished = true
                        return
                    }

                    childPath = hooktheoryChord.childPath

                    guard let tokens = Tokenizer.tokenize(string: hooktheoryChord.id) else { assertionFailure("Unable to tokenize chord: \(hooktheoryChord.id)"); return }
                    let chord = Parser.parse(tokens: tokens)
                    print("Parsed version of \(hooktheoryChord.id): \(chord)")

                    let remainingMeasureRhythms = Array(measureRhythms.suffix(from: 1))
                    request(with: remainingMeasureRhythms)

                } catch let error {
                    print(error)
                }
            }
            
            task.resume()
        }
        
        request(with: measureRhythms)
    }
}

autoreleasepool {
    let chorder = Chorder()
    chorder.start()

    while !chorder.isFinished {}
}
