//
//  Int+Parity.swift
//  Chorder
//
//  Created by Michael Pace on 4/15/17.
//  Copyright © 2017 Michael Pace. All rights reserved.
//

import Foundation

/// Provides convenience properties and functions related to parity.
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
