//
//  Request.swift
//  Chorder
//
//  Created by Michael Pace on 5/2/17.
//  Copyright © 2017 Michael Pace. All rights reserved.
//

import Foundation

/// TODO
enum Request {

    /// TODO
    case authenticate(username: String, password: String)

    /// TODO
    case trends

    /// TODO
    var method: String {
        // TODO: Make a `Method` enum.
        switch self {
        case .authenticate:
            return "POST"
        case .trends:
            return "GET"
        }
    }

    /// TODO
    var path: String {
        switch self {
        case .authenticate:
            return "users/auth"
        case .trends:
            return "trends/nodes"
        }
    }

    /// TODO
    var body: Data? {
        switch self {
        case let .authenticate(username: username, password: password):
            let authenticationInformation = "username=\(username)&password=\(password)"
            return authenticationInformation.data(using: .utf8)
        case .trends:
            return nil
        }
    }
}
