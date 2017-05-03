//
//  Result.swift
//  Chorder
//
//  Created by Michael Pace on 5/2/17.
//  Copyright © 2017 Michael Pace. All rights reserved.
//

import Foundation

/// TODO
enum Result<T> {

    /// TODO
    case success(result: T)

    /// TODO
    case failure(error: Error)
    
}
