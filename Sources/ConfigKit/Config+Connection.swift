//
//  ConfigConnection.swift
//  ConfigKit
//
//  Created by Tyler Anger on 2018-05-15.
//

import Foundation


public extension Config {
    
    /// And structure containing connection configuration information
    /// This is helpful for storing and accessing connections to web services, or database
    public struct Connection: Codable {
        
        private enum CodingKeys: String, CodingKey {
            case name
            case uri
            case credentials
            case properties
        }
        
        
        /// Stores the credentials for the connection
        ///
        ///    - userNameAndPassword: User name and password for this connection
        ///    - apikey: ApiKey for this connection
        ///    - none: Indicates there are no credentials for this connection
        public enum Credentials {
            /// User name and password for this connection
            case userNameAndPassword(username: String, password: String)
            /// ApiKey for this connection
            case apikey(key: String)
            /// ApiKey, user name, and password for this conncetion
            case apikeyUserNameAndPassword(key: String, username: String, password: String)
            /// Indicates there are no credentials for this connection
            case none
            
            
            /// The username and passsword if the credentials are set as such
            ///
            public var usernameAndPasswordValue: (username: String, password: String)? {
                switch self {
                    case .userNameAndPassword(let u, let p): return (username: u, password: p)
                    case .apikeyUserNameAndPassword(_, let u, let p): return (username: u, password: p)
                    case .apikey(_): return nil
                    case .none: return nil
                }
            }
            
            /// The apikey if the credentials are set as such
            public var apikeyValue: String? {
                switch self {
                    case .userNameAndPassword(_, _): return nil
                    case .apikeyUserNameAndPassword(let k, _, _): return k
                    case .apikey(let k): return k
                    case .none: return nil
                }
            }
            
            /// Indicates if there are any credentials set or not
            public var isNone: Bool {
                guard case Credentials.none = self else { return false }
                return true
            }
        }
        
        /// Name of the connection
        public let name: String
        /// Address of the connection (Could be a web service, or a database uri, etc)
        public let uri: String
        /// Connection credentials
        public let credentials: Credentials
        /// Stores additional properties for this connection
        internal let properties: [String: String]
        /// Gives a list of all the additional property keys
        public var propertyKeys: [String] { return self.properties.keys.compactMap({ $0 }) }
        
        /// Create a new instance of Connection
        ///
        /// - Parameters:
        ///   - name: Name of the connection
        ///   - uri: URI of the connection
        ///   - credentials: Credentials of the connection
        ///   - properties: Other properties pertaining the connection
        public init(name: String,
                    uri: String,
                    credentials: Credentials = .none,
                    properties: [String: String] = [:]) {
            self.name = name
            self.uri = uri
            self.credentials = credentials
            self.properties = properties
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.name = try container.decode(String.self, forKey: .name)
            self.uri = try container.decodeIfPresent(String.self, forKey: .uri) ?? ""
            self.credentials = try container.decodeIfPresent(Credentials.self, forKey: .credentials) ?? Credentials.none
            self.properties = try container.decodeIfPresent([String: String].self, forKey: .properties) ?? [:]
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(self.name, forKey: .name)
            if !self.uri.isEmpty { try container.encode(self.uri, forKey: .uri) }
            if !self.credentials.isNone { try container.encode(self.credentials, forKey: .credentials) }
            if self.properties.count > 0 { try container.encode(self.properties, forKey: .properties) }
        }
        
        /// A method for accessing the additional property values.
        ///
        /// - parameter name: Name of property to access
        ///
        /// - returns: Returns an object dynamically converted to the type you specify or nil if the property does not exist
        public func getProperty<T>(withName name: String) -> T? where T: LosslessStringConvertible {
            guard let v = self.properties[name] else { return nil }
            return T.init(v)
        }
        
        /// Wrapped method for getParameter explicitly to get boolean values.
        ///
        /// If the parameter does not exist or is not convertable to a bool this will return false
        ///
        /// - parameter name: Name of parameter to access
        ///
        /// - returns: Returns true if the property exists and the value is conerted to a bool with true as the results, otherwise this method returns false.
        public func getBoolProperty(withName name: String) -> Bool {
            guard let b: Bool = self.getProperty(withName: name) else { return false }
            return b
        }
    }
}

extension Config.Connection.Credentials: Codable {
    private enum CodingKeys: String, CodingKey {
        case username = "username"
        case password = "password"
        case apikey = "apikey"
    }
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let uname = try container.decodeIfPresent(String.self, forKey: .username)
        let pwd = try container.decodeIfPresent(String.self, forKey: .password)
        let key = try container.decodeIfPresent(String.self, forKey: .apikey)
        
        if let u = uname, let p = pwd, let k = key { self = .apikeyUserNameAndPassword(key: k, username: u, password: p) }
        else if let u = uname, let p = pwd { self = .userNameAndPassword(username: u, password: p) }
        else if let k = key { self = .apikey(key: k) }
        else { self = .none }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
            case .apikeyUserNameAndPassword(key: let apikey, username: let uname, password: let pwd):
                try container.encode(apikey, forKey: .apikey)
                try container.encode(uname, forKey: .username)
                try container.encode(pwd, forKey: .password)
            case .userNameAndPassword(username: let uname, password: let pwd):
                try container.encode(uname, forKey: .username)
                try container.encode(pwd, forKey: .password)
            case .apikey(key: let apikey):
                try container.encode(apikey, forKey: .apikey)
            case .none:
                break //Do nothing for none
        }
    }
}

extension Config.Connection {
    
    /// Takes in a dictionary of values and extracts any that are in the connection format and creates connection objects.
    ///
    /// After all connections are extracted, this function will return a new dictionary removing the values it used to create the connection objects as well as an array of the newly created connection objects.
    /// The format for propertyes in the dictionary to be picked up as connection objects is as follows:
    ///  - {name}:connection_uri=value *Required
    ///  - {name}:connection_auth_username=value
    ///  - {name}:connection_auth_password=value
    ///  - {name}:connection_auth_apikey=value
    ///  -  This also supports adding connection parameters using the following format:
    ///  - {name}:connection_param:{param_name}=value
    ///
    /// - parameter kv:Dictionary of properties
    ///
    /// - returns: Returns a new dictionary removing any properties used in the creation of connection as well as an array of newly created connections
    internal static func filterFromKeyValuePairs(_ kv: [String: String]) -> (kv: [String: String], connections: [Config.Connection]) {
        var properties: [String: String] = kv
        var connections: [Config.Connection] = []
        
        let connectionNameList = properties.keys.filter({ $0.hasSuffix(":connection_uri") })
        for connectionName in connectionNameList {
            let connectionName = String(connectionName.prefix(connectionName.count - ":connection_uri".count))
            
            var connectionProperties: [String: String] = [:]
            let connectionParameterList = properties.keys.filter({ $0.hasPrefix(connectionName + ":connection_param:") })
            for p in connectionParameterList {
                guard let value = properties[p] else { continue }
                let pName = p.suffix(p.count - (connectionName + ":connection_param:").count)
                connectionProperties[String(pName)] = value
                properties.removeValue(forKey: p)
            }
            
            if let connectionURI = properties[connectionName + ":connection_uri"] {
                if let userName = properties[connectionName + ":connection_auth_username"],
                    let password = properties[connectionName + ":connection_auth_password"] {
                    
                    properties.removeValue(forKey: connectionName + ":uri")
                    properties.removeValue(forKey: connectionName + ":connection_auth_username")
                    properties.removeValue(forKey: connectionName + ":connection_auth_password")
                    
                    let con = Config.Connection(name: connectionName,
                                                uri: connectionURI,
                                                credentials: .userNameAndPassword(username: userName, password: password),
                                                properties: connectionProperties)
                    
                    connections.append(con)
                    
                } else if let apiKey = properties[connectionName + ":connection_auth_apikey"] {
                    
                    properties.removeValue(forKey: connectionName + ":connection_uri")
                    properties.removeValue(forKey: connectionName + ":connection_auth_apikey")
                    
                    let con = Config.Connection(name: connectionName,
                                                uri: connectionURI,
                                                credentials: .apikey(key: apiKey),
                                                properties: connectionProperties)
                    
                    connections.append(con)
                    
                } else {
                    properties.removeValue(forKey: connectionName + ":connection_uri")
                    
                    let con = Config.Connection(name: connectionName,
                                                uri: connectionURI,
                                                properties: connectionProperties)
                    
                    connections.append(con)
                }
            }
        }
        
        
        
        return (kv: properties, connections: connections)
    }
}
