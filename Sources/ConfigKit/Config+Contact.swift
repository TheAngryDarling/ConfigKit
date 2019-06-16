//
//  Config+Contact.swift
//  ConfigKit
//
//  Created by Tyler Anger on 2018-05-18.
//

import Foundation

public extension Config {
    
    public struct Contact: Codable {
        
        
        /// Stores the contact information
        ///
        /// - email: Contact email address
        public enum ContactType: Codable {
            private enum CodingKeys: String, CodingKey {
                case email
                case emailType
                case phoneType
                case phoneNumber
                
            }
            
            public enum PhoneType: Codable {
                private enum CodingKeys: String, CodingKey {
                    case type
                    case name
                }
                case home(String?)
                case work(String?)
                case fax(String?)
                case cell(String?)
                case other(String)
                
                
                
                public init(from decoder: Decoder) throws {
                    if let strTp = try? decoder.singleValueContainer().decode(String.self) {
                        switch strTp.lowercased() {
                            case "home": self = .home(nil)
                            case "work": self = .work(nil)
                            case "fax": self = .fax(nil)
                            case "cell": self = .cell(nil)
                            default:
                                self = .other(strTp)
                        }
                        
                    } else {
                        let container = try decoder.container(keyedBy: CodingKeys.self)
                        let strTp = try container.decode(String.self, forKey: .type)
                        let name =  try container.decodeIfPresent(String.self, forKey: .name)
                        switch strTp.lowercased() {
                            case "home": self = .home(name)
                            case "work": self = .work(name)
                            case "fax": self = .fax(name)
                            case "cell": self = .cell(name)
                            default:
                                throw DecodingError.dataCorrupted(.init(codingPath: decoder.codingPath, debugDescription: "Invalid PhoneType '\(strTp)'"))
                        }
                    }
                    
                }
                
                public func encode(to encoder: Encoder) throws {
                    switch self {
                    case .home:
                        var container = encoder.singleValueContainer()
                        try container.encode("home")
                    case .work:
                        var container = encoder.singleValueContainer()
                        try container.encode("work")
                    case .fax:
                        var container = encoder.singleValueContainer()
                        try container.encode("fax")
                    case .other(let name):
                        var container = encoder.singleValueContainer()
                        try container.encode(name)
                    case .cell(let name):
                        var container = encoder.container(keyedBy: CodingKeys.self)
                        try container.encode("cell", forKey: .type)
                        try container.encode(name, forKey: .name)
                        
                        
                    }
                }
            }
            
            case email(String, String?)
            case phone(PhoneType, String)
            
            
            public init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                if container.contains(.email) {
                    let strEmail = try container.decode(String.self, forKey: .email)
                    let emailType = try container.decodeIfPresent(String.self, forKey: .emailType)
                    self = .email(strEmail, emailType)
                } else if container.contains(.phoneType) {
                    self = .phone(try container.decode(PhoneType.self, forKey: .phoneType),
                                  try container.decode(String.self, forKey: .phoneNumber))
                } else {
                    fatalError("Unsupported contact type")
                }
                
            }
            
            public func encode(to encoder: Encoder) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)
                
                switch self {
                    case .email(let v, let n):
                        try container.encode(v, forKey: .email)
                        if let nV = n {
                            try container.encode(nV, forKey: .emailType)
                        }
                    case .phone(let tp, let number):
                        try container.encode(tp, forKey: .phoneType)
                        try container.encode(number, forKey: .phoneNumber)
                    
                }
                
            }
        }
        
        let name: String
        let types: [ContactType]
    }
}

extension Config.Contact {
    
    /// Takes in a dictionary of values and extracts any that are in the contact format and creates contact objects.
    ///
    /// After all contacts are extracted, this function will return a new dictionary removing the values it used to create the connection objects as well as an array of the newly created contact objects.
    /// The format for propertyes in the dictionary to be picked up as connection objects is as follows:
    ///
    /// **** Currently this method does not extract any contacts ****
    ///
    /// - parameters:
    /// - kv: Dictionary of properties
    ///
    /// - returns: Returns a new dictionary removing any properties used in the creation of contacts as well as an array of newly created contacts
    static func filterFromKeyValuePairs(_ kv: [String: String]) -> (kv: [String: String], contacts: [Config.Contact]) {
        let parameters: [String: String] = kv
        let contacts: [Config.Contact] = []
        
        // TODO: In the future, must implement
        
        return (kv: parameters, contacts: contacts)
    }
    
}
