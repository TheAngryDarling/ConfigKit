//
//  URL+LosslessStringConvertible.swift
//  ConfigKit
//
//  Created by Tyler Anger on 2018-05-15.
//

import Foundation

extension URL: LosslessStringConvertible {
    public init?(_ description: String) {
        self.init(string: description)
    }
}
