//
//  Array+Random.swift
//  Chorder
//
//  Created by Michael Pace on 4/15/17.
//  Copyright © 2017 Michael Pace. All rights reserved.
//

import Foundation

/// Provides convenience properties and functions related to randomness.
extension Array {

    /// A random element in this array if it isn't empty, or nil otherwise.
    var randomElement: Element? {
        guard isNotEmpty else { return nil }

        let index = Int(arc4random_uniform(UInt32(count)))
        return self[index]
    }
    
}
