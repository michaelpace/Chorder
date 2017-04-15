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

/// Represents a Hooktheory chord, as returned from the trends/nodes endpoint.
struct Chord {

    /// The chord's Hooktheory ID.
    let id: String

    /// The chord's HTML representation.
    let html: String

    /// The chord's probability of occurring relative to all chords within Hooktheory's database. This probability is independent of the chord progression containing this chord.
    let probability: Double

    /// The chord's child path describing the sequence of chords culminating with this chord. Used to ask Hooktheory about chords following this chord.
    let childPath: String

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

        var chords = ""
        print("going to request \(measureRhythms.count) chords")

        func request(with measureRhythms: [MeasureRhythm]) {
            guard let _ = measureRhythms.first else {
                print("requested all the chords")
                isFinished = true
                return
            }

            sleep(1)

            var urlComponents = URLComponents(string: "https://api.hooktheory.com/v1/trends/nodes")
            if !chords.isEmpty {
                urlComponents?.queryItems = [URLQueryItem(name: "cp", value: chords)]
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

                    guard let chord = Chord(json: chordJSON) else {
                        print("invalid chord")
                        self.isFinished = true
                        return
                    }

                    chords = chord.childPath
                    print(chord)

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
