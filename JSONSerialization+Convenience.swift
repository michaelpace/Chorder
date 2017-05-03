//
//  JSONSerialization+Convenience.swift
//  Chorder
//
//  Created by Michael Pace on 5/2/17.
//  Copyright © 2017 Michael Pace. All rights reserved.
//

import Foundation

extension JSONSerialization {

    /// TODO
    ///
    /// - Parameter data: TODO
    /// - Returns: TODO
    static func dictionary(from data: Data) -> [String: Any]? {
        do {
            guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else { return nil }
            return json
        } catch {
            return nil
        }
    }

    /// TODO
    ///
    /// - Parameter data: TODO
    /// - Returns: TODO
    static func array(from data: Data) -> [Any]? {
        do {
            guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [Any] else { return nil }
            return json
        } catch {
            return nil
        }
    }
    
}
