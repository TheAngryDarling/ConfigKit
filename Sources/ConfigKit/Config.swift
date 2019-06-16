//
//  Config.swift
//  ConfigKit
//
//  Created by Tyler Anger on 2018-04-17.
//

//import Foundation


public final class Config: Codable {
    
    private enum CodingKeys: String, CodingKey {
        case connections
        case properties
        case contacts
    }
    
    /// Stored connections
    public private(set) var connections: [Connection]
    /// Stored properties
    public private(set) var properties: [String: String]
    //Stored contacts
    public private(set) var contacts: [Contact]
    
    //public var connectionNames: [String] { return self.connections.compactMap({ return $0.name }) }
    //public var parameterKeys: [String] { return self.parameters.keys.compactMap({ $0 }) }
    
    
    public init() {
        self.connections = []
        self.properties = [:]
        self.contacts = []
    }
    
    public init(keyValuePair: [String: String]) {
        let f = Connection.filterFromKeyValuePairs(keyValuePair)
        self.connections = f.connections
        
        let c = Contact.filterFromKeyValuePairs(f.kv)
        self.contacts = c.contacts
        
        self.properties = c.kv
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.connections = try container.decodeIfPresent([Connection].self, forKey: .connections) ?? []
        self.properties = try container.decodeIfPresent([String: String].self, forKey: .properties) ?? [:]
        self.contacts = try container.decodeIfPresent([Contact].self, forKey: .contacts) ?? []
        //self.fixPropertyConnections()
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        if self.connections.count > 0 {
            try container.encode(self.connections, forKey: .connections)
        }
        if self.properties.count > 0 {
            try container.encode(self.properties, forKey: .properties)
        }
        if self.contacts.count > 0 {
            try container.encode(self.contacts, forKey: .contacts)
        }
    }
    
    /// Returns the connection with the provided name or nil if the connection is not found
    public func getConnection(withName name: String) -> Connection? {
        return self.connections.first(where: { $0.name == name })
    }
    
    
    /// A method for accessing the additional property values.
    ///
    /// - parameter name: Name of parameter to access
    ///
    /// - returns: Returns an object dynamically converted to the type you specify or nil if the property does not exist
    public func getProperty<T>(withName name: String) -> T? where T: LosslessStringConvertible {
        guard let v = self.properties[name] else { return nil }
        return T.init(v)
    }
    
    
    /// Wrapped method for getParameter explicitly to get boolean values.
    /// If the parameter does not exist or is not convertable to a bool this will return false
    ///
    /// - parameter name: Name of parameter to access
    /// - returns: Returns true if the property exists and the value is conerted to a bool with true as the results, otherwise this method returns false
    public func getBoolProperty(withName name: String) -> Bool {
        guard let b: Bool = self.getProperty(withName: name) else { return false }
        return b
    }
    
    /// Returns the contact with the provided name or nil of the contact is not found
    public func getContact(withName name: String) -> Contact? {
        return self.contacts.first(where: { $0.name == name })
    }
    
    
    /// Merges the provied configuration with the current configuration overwriting any existing values
    public func merge(with config: Config) {
        
        for (k, v) in config.properties {
            self.addProperty(v, withName: k)
        }
        
        for c in config.connections {
            // Remove prevously loaded connection if one was there
            self.connections.removeAll(where: { return $0.name == c.name } )
            self.addConnection(c)
        }
        
        for c in config.contacts {
            // Remove prevously loaded contact if one was there
            self.contacts.removeAll(where: { return $0.name == c.name } )
            self.addContact(c)
        }
    }
    
    
    /// Manually add a connection to the configuration
    public func addConnection( _ connection: Connection) {
        
        //We must remove previous connections with same name
        while let idx = self.connections.index(where: { $0.name == connection.name}) {
            self.connections.remove(at: idx)
        }
        self.connections.append(connection)
        
    }
    
    /// Manually add a property to the configuration
    public func addProperty(_ value: String, withName name: String) {
        self.properties[name] = value
    }
    
    /// Manually add a contact to the configuration
    public func addContact( _ contact: Contact) {
        //We must remove previous contact with same name
        while let idx = self.contacts.index(where: { $0.name == contact.name}) {
            self.contacts.remove(at: idx)
        }
        self.contacts.append(contact)
    }
}
