//
//  AuthenticationResult.swift
//  Chorder
//
//  Created by Michael Pace on 5/2/17.
//  Copyright © 2017 Michael Pace. All rights reserved.
//

import Foundation

/// TODO
struct AuthenticationResult: Parseable {

    /// TODO
    let id: Int

    /// TODO
    let username: String

    /// TODO
    let activkey: String

    static func parse(from data: Data) -> AuthenticationResult? {
        guard
            let json = JSONSerialization.dictionary(from: data),
            let id = json["id"] as? Int,
            let username = json["username"] as? String,
            let activkey = json["activkey"] as? String else { fatalError("Parsing error.") }

            return AuthenticationResult(id: id, username: username, activkey: activkey)
    }

}
