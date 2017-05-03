//
//  Parseable.swift
//  Chorder
//
//  Created by Michael Pace on 5/2/17.
//  Copyright © 2017 Michael Pace. All rights reserved.
//

import Foundation

/// TODO
protocol Parseable {

    /// TODO
    ///
    /// - Parameter data: TODO
    /// - Returns: TODO
    static func parse(from data: Data) -> Self?
}
