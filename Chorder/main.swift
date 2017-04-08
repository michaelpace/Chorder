//
//  main.swift
//  Chorder
//
//  Created by Michael Pace on 4/7/17.
//  Copyright © 2017 Michael Pace. All rights reserved.
//

import Foundation

/*
 future TODO:
 - access control
 - test extensions
 */

// MARK: - Extensions

extension Array {

    /// A random element in this array if it isn't empty, or nil otherwise.
    var randomElement: Element? {
        guard isNotEmpty else { return nil }

        let index = Int(arc4random_uniform(UInt32(count)))
        return self[index]
    }

    /// Whether this array is empty.
    var isNotEmpty: Bool {
        return !isEmpty
    }
    
}

extension Int {

    /// Whether this `Int` is an even value.
    var isEven: Bool {
        return self % 2 == 0
    }

    /// Whether this `Int` is an odd value.
    var isOdd: Bool {
        return !isEven
    }

}

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

// MARK: - Chorder

private func main(configuration: Configuration) {

    // TODO: Constant-ize or configure-ize [2, 4, 8]?
    guard let numberOfMeasures = [2, 4, 8].randomElement else { return assertionFailure("Failure retrieving a random element.") }
    let measureRhythms: [MeasureRhythm] = (0..<numberOfMeasures).flatMap { _ in
        guard let beatsWithChords = configuration.timeSignature.validChordBeats.randomElement else { assertionFailure("Failure retrieving a random element."); return nil }
        return MeasureRhythm(beatsWithChords: beatsWithChords)
    }

    // TODO: Start here next time. Organize this stuff. Should only need to make cp-less /trends/nodes request once, and then can append the query parameter `cp`, like `?cp=4,1` or w/e. See https://www.hooktheory.com/api/trends/docs and http://forum.hooktheory.com/t/trends-api-chord-input/272 
    let group = DispatchGroup()
    let queue = DispatchQueue(label: "Chorder.networkRequestQueue", qos: .default, attributes: .concurrent)

    let session = urlSession(with: configuration.activkey)

    var chords = ""

    func request(with measureRhythms: [MeasureRhythm]) {
        guard let measureRhythm = measureRhythms.first else { return }

        group.enter()
        queue.async(group: group) {
            var urlComponents = URLComponents(string: "https://api.hooktheory.com/v1/trends/nodes")
            if !chords.isEmpty {
                urlComponents?.queryItems = [URLQueryItem(name: "cp", value: chords)]
            }
            guard let url = urlComponents?.url else { return assertionFailure("Invalid URL") }

            print(url)
            let task = session.dataTask(with: url) { (data, response, error) in
                defer { group.leave() }

                guard let data = data else { return }

                do {
                    let commonChords = try JSONSerialization.jsonObject(with: data, options: []) as! [[String: Any]]
                    guard let chord = commonChords.randomElement?["chord_HTML"] else { return }
                    chords.append("\(chords.isEmpty ? "" : ",")\(chord)")
                    print(chords)

                    let remainingMeasureRhythms = Array(measureRhythms.suffix(from: 1))
                    request(with: remainingMeasureRhythms)
                } catch let error {
                    print(error)
                }
            }
            
            task.resume()
        }
    }

    request(with: measureRhythms)

    group.wait()
}

// MARK: - Entry point

// TODO: Organize.
let enumeratedArguments = CommandLine.arguments.suffix(from: 1).enumerated()
let keys = enumeratedArguments.flatMap { (index, argument) in return index.isEven ? argument : nil }
let values = enumeratedArguments.flatMap { (index, argument) in return index.isOdd ? argument : nil }
let parsedArguments = zip(keys, values).flatMap { (key, value) in return Argument(key: key, value: value) }
guard let configuration = Configuration(arguments: parsedArguments) else { fatalError("Invalid arguments.") }

main(configuration: configuration)
