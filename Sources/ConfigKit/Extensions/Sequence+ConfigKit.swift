//
//  Sequence+ConfigKit.swift
//  ConfigKit
//
//  Created by Tyler Anger on 2019-06-16.
//

import Foundation

internal extension Sequence {
    #if !(os(macOS) || os(iOS) || os(tvOS) || os(watchOS)) && !swift(>=4.1)
    func compactMap<ElementOfResult>(_ transform: (Element) throws -> ElementOfResult?) rethrows -> [ElementOfResult] {
        var rtn: [ElementOfResult] = []
        for v in self {
            if let nV = try transform(v) { rtn.append(nV) }
        }
        return rtn
    }
    #endif
    
}

internal extension Array {
    #if !swift(>=4.1.4)
    mutating func removeAll(where predicate: (Element) throws -> Bool) rethrows {
        var idx = self.startIndex
        while idx < self.endIndex {
            if try predicate(self[idx]) {
                self.remove(at: idx)
            } else {
                idx = self.index(after: idx)
            }
        }
    }
    #endif
}
