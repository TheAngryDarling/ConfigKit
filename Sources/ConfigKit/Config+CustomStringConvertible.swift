//
//  Config+CustomStringConvertible.swift
//  ConfigKit
//
//  Created by Tyler Anger on 2018-05-17.
//

import Foundation

extension Config: CustomStringConvertible {
    public var description: String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let dta = try! encoder.encode(self)
        let str = String(data: dta, encoding: .utf8)!
        return str
    }
}
