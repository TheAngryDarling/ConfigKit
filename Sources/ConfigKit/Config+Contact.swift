//
//  Config+Contact.swift
//  ConfigKit
//
//  Created by Tyler Anger on 2018-05-18.
//

import Foundation

public extension Config {
    
    public struct Contact: Codable {
        
        /**
         Stores the contact information
         
         - email: Contact email address
         */
        public enum ContactType: Codable {
            private enum CodingKeys: String, CodingKey {
                case email
            }
            
            case email(String)
            
            public init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                if let v = try container.decodeIfPresent(String.self, forKey: .email) {
                    self = .email(v)
                } else {
                    fatalError("Unsupported contact type")
                }
                
            }
            
            public func encode(to encoder: Encoder) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)
                
                switch self {
                case .email(let v): try container.encode(v, forKey: .email)
                }
                
            }
        }
        
        let name: String
        let types: [ContactType]
    }
}

extension Config.Contact {
    
    /**
     Takes in a dictionary of values and extracts any that are in the contact format and creates contact objects.
     After all contacts are extracted, this function will return a new dictionary removing the values it used to create the connection objects as well as an array of the newly created contact objects.
     The format for propertyes in the dictionary to be picked up as connection objects is as follows:
     
     **** Currently this method does not extract any contacts ****
     
     - parameters:
     - kv: Dictionary of properties
     
     - returns:
     Returns a new dictionary removing any properties used in the creation of contacts as well as an array of newly created contacts
     */
    
    
    static func filterFromKeyValuePairs(_ kv: [String: String]) -> (kv: [String: String], contacts: [Config.Contact]) {
        let parameters: [String: String] = kv
        let contacts: [Config.Contact] = []
        
        // TODO: In the future, must implement
        
        return (kv: parameters, contacts: contacts)
    }
    
}
