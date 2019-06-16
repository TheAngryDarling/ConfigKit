//
//  FileDecoder.swift
//  ConfigKit
//
//  Created by Tyler Anger on 2018-05-15.
//

import Foundation


public extension Config {
    
    /// Coding indicator.  Used to indicate which type of coder to use when encoding and decoding configuration data
    /// - json: Used to read from and write to json data.
    /// - plist: Used to read from and write to plist data. (Currently only suppored on the mac/iOS/tvOS platforms)
    public enum ConfigCodingType {
        /// json coder.  Used to read from and write to json data.
        case json
        #if os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || swift(>=4.1)
        /// plist coder. Used to read from and write to plist data. (Currently only suppored on the mac/iOS/tvOS platforms)
        case plist
        #endif
        
        /// Returns the coding type for the specified extension or nil of one could not be located
        public static func getType(fromExtension ext: String?) -> ConfigCodingType? {
            guard let val = ext else { return nil }
            if val == "json" { return .json }
           #if os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || swift(>=4.1)
            if val == "plist" { return .plist }
            #endif
            return nil
        }
        
        /// Returns the coding type for the specified mime type or nil of one could not be located
        public static func getType(fromMimeType mime: String?) -> ConfigCodingType? {
            guard let val = mime else { return nil }
            if val == "application/json" { return .json }
            #if os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || swift(>=4.1)
            if val == "application/x-plist" { return .plist }
            #endif
            return nil
        }
        
        
        /// Returns the Decoder for the given coder type
        internal func getDecoder() -> ConfigDecoder {
            #if os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || swift(>=4.1)
            switch self {
                case .json: return JSONDecoder()
                case .plist: return PropertyListDecoder()
            }
            #else
            switch self {
                case .json: return JSONDecoder()
            }
            #endif
        }
        
        /// Returns the Encoder for the given coder type
        internal func getEncoder() -> ConfigEncoder {
            
            #if os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || swift(>=4.1)
            switch self {
                case .json: return JSONEncoder()
                case .plist: return PropertyListEncoder()
            }
            #else
            switch self {
                case .json: return JSONEncoder()
            }
            #endif
        }
        
    }
}

internal protocol ConfigDecoder {
    func decode<T>(_ type: T.Type, from data: Data) throws -> T where T : Decodable
}

internal protocol ConfigEncoder {
    func encode<T>(_ value: T) throws -> Data where T : Encodable
}

extension JSONDecoder: ConfigDecoder { }
extension JSONEncoder: ConfigEncoder { }
#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || swift(>=4.1)
extension PropertyListDecoder: ConfigDecoder { }
extension PropertyListEncoder: ConfigEncoder { }
#endif

