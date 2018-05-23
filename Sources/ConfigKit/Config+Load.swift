//
//  Config+Load.swift
//  ConfigKit
//
//  Created by Tyler Anger on 2018-05-17.
//

import Foundation

public extension Config {
    
    /**
     Loads a configuration file from the given path. (Must be a .json or .plist file)
     Any objects with the same name as objects comming in from the load function will be replaced
     
     - returns:
     Returns the same instance of the config object so that you can repeatedly call load functions within the same line
     eg.  config.loadFromEnv().load(fromFile: "global config.json").load(fromFile: "user config.json")
     
     - throws:
     An error of type Config.Error.fileNotFound if the method could not locate the file
     An error of type Config.Error.unknownConfigType if it could not identify the file type
     A decoding error of the data is in an invalid format
     
     - parameters:
        - fromFile: The config file to load.  Should have the extension of .json or .plist
     
    */
    @discardableResult
    public func load(fromFile p: String) throws -> Config {
        // var path = p
        let path = NSString(string: NSString(string: p).expandingTildeInPath).standardizingPath
        guard FileManager.default.fileExists(atPath: path) else { throw Error.fileNotFound(path) }
        
        guard let decoderType = ConfigCodingType.getType(fromExtension:URL(fileURLWithPath: path).pathExtension) else {
            throw Error.unknownConfigType(path)
        }
        
        return try self.load(fromData: FileManager.default.contents(atPath: path)!, usingDecoderType: decoderType)
        
    }
    
    /**
     Loads a configuration file from the given URL.
     If the url is a file location, this method will call the load file method
     Any objects with the same name as objects comming in from the load function will be replaced
     
     - returns:
     Returns the same instance of the config object so that you can repeatedly call load functions within the same line
     eg.  config.loadFromEnv().load(fromFile: "global config.json").load(fromFile: "user config.json")
     
     - throws:
     An error of type Config.Error.fileNotFound if the method could not locate the file
     An error of type Config.Error.unknownConfigType if it could not identify the file type
     A decoding error of the data is in an invalid format
     
     - parameters:
        - fromURL: The config url to load.  Should have the extension of .json or .plist or have a correct mimeType set
     
     */
    @discardableResult
    public func load(fromURL url: URL) throws -> Config {
        guard !url.isFileURL else { return try self.load(fromFile: url.path) }
        let request: URLRequest = URLRequest(url: url)
        let session: URLSession = URLSession(configuration: URLSessionConfiguration.default)
        let semaphore = DispatchSemaphore(value: 0)
        
        var err: Swift.Error? = nil
        var data: Data? = nil
        var decoderType: ConfigCodingType? = nil
        
        let task = session.dataTask(with: request) { (responseData, resp, e) -> Void in
            data = responseData
            err = e
            if let dt = ConfigCodingType.getType(fromMimeType:  resp!.mimeType) {
                decoderType = dt
            } else if let dt = ConfigCodingType.getType(fromExtension: url.pathExtension) {
                decoderType = dt
            }
            semaphore.signal()
            
        }
        task.resume()
        _ = semaphore.wait(timeout: .distantFuture)
        
        if let d = data, let dec = decoderType {
            return try load(fromData: d, usingDecoderType: dec)
        } else if decoderType == nil { throw Error.unknownConfigType(url.absoluteString) }
        else if let e = err { throw e }
        
        return self
    }
    
    /**
     Loads a configuration from the given string an decoder type
     This is a convienience function which calls the load(fromData, usingDecoderType) method
     Any objects with the same name as objects comming in from the load function will be replaced
     
     - returns:
     Returns the same instance of the config object so that you can repeatedly call load functions within the same line
     eg.  config.loadFromEnv().load(fromFile: "global config.json").load(fromFile: "user config.json")
     
     - throws:
     A decoding error of the data is in an invalid format
     
     - parameters:
        - fromString: The string storing the configuration
        - usingDecoderType: Indicating what decoder to use
     */
    @discardableResult
    public func load(fromString string: String, usingDecoderType decoderType: ConfigCodingType) throws -> Config {
        return try self.load(fromData: string.data(using: .utf8)!, usingDecoderType: decoderType)
    }
    
    /**
     Loads a configuration from the given data an decoder type
     Any objects with the same name as objects comming in from the load function will be replaced
     
     - returns:
     Returns the same instance of the config object so that you can repeatedly call load functions within the same line
     eg.  config.loadFromEnv(.load(fromFile: "global config.json").load(fromFile: "user config.json")
     
     - throws:
     A decoding error of the data is in an invalid format
     
     - parameters:
        - fromData: The data storing the configuration
        - usingDecoderType: Indicating what decoder to use
     */
    @discardableResult
    public func load(fromData data: Data, usingDecoderType decoderType: ConfigCodingType) throws -> Config {
        let cfg: Config = try decoderType.getDecoder().decode(Config.self, from: data)
        self.merge(with: cfg)
        
        return self
    }
    
    
   
    /**
     Loads environmental variables into parameters list (ProcessInfo.processInfo.environment)
     This function will move any key value pairs into connection objects if they are in the following format:
        {name}:connection_uri=value *Required
        {name}:connection_auth_username=value
        {name}:connection_auth_password=value
        {name}:connection_auth_apikey=value
        This also supports adding connection parameters using the following format:
        {name}:connection_param:{param_name}=value
     Any objects with the same name as objects comming in from the load function will be replaced
     
     - returns:
     Returns the same instance of the config object so that you can repeatedly call load functions within the same line
     eg.  config.loadFromEnv().load(fromFile: "global config.json").load(fromFile: "user config.json")
     
     - parameters:
        - usingFilter: A way for you to filter which parameters to include or not
     */
    @discardableResult
    public func loadFromEnv(usingFilter filter: (String)-> Bool = { _ in return true }) -> Config {
        var kv: [String: String] = [:]
        for (k,v) in ProcessInfo.processInfo.environment {
            guard filter(k) else { continue }
            kv[k] = v
        }
        return self.load(fromKeyValuePair: kv)
    }
    
    /**
     Loads command line parameters into parameters list (CommandLine.arguments)
     This function will move any key value pairs into connection objects if they are in the following format:
        {name}:connection_uri=value *Required
        {name}:connection_auth_username=value
        {name}:connection_auth_password=value
        {name}:connection_auth_apikey=value
        This also supports adding connection parameters using the following format:
            {name}:connection_param:{param_name}=value
     Any objects with the same name as objects comming in from the load function will be replaced
     
     - returns:
     Returns the same instance of the config object so that you can repeatedly call load functions within the same line
     eg.  config.loadFromEnv().load(fromFile: "global config.json").load(fromFile: "user config.json")
     
     - parameters:
        - commandLineArgumentKeyPrefix: An indicator used to identify a parameter (--{paramName})
        - keyValueSeperator: An indicator for where to split the key and value (--paramName=value)
        - usingFilter: A way for you to filter which parameters to include or not
     */
    @discardableResult
    public func loadCommandLineArguments(commandLineArgumentKeyPrefix: String = "--",
                                         keyValueSeperator seperator: String = "=",
                                         usingFilter filter: @escaping ((String)-> Bool) = { _ in return true }) -> Config {
        var params: [String: String] = [:]
        
        for i in 1..<CommandLine.arguments.count {
            guard CommandLine.arguments[i].hasPrefix(commandLineArgumentKeyPrefix) else { continue }
            
            //Remove the prefix from the parameter
            let param = String(CommandLine.arguments[i].suffix(CommandLine.arguments[i].count - commandLineArgumentKeyPrefix.count))
            if let idx = param.range(of: seperator) { //Find the seperator (first occurance)
                //Split by the seperator
                let key = String(param.prefix(upTo: idx.lowerBound))
                let value = String(param.suffix(from: idx.upperBound))
                
                //Make sure our filter allows it
                if filter(key) {
                    params[key] = value
                }
            }
        }
        
        if params.count > 0 { return self.load(fromKeyValuePair: params) }
        else { return self }
        
    }
    
    /**
     Loads a dictionary into parameters list
     This function will move any key value pairs into connection objects if they are in the following format:
        {name}:connection_uri=value *Required
        {name}:connection_auth_username=value
        {name}:connection_auth_password=value
        {name}:connection_auth_apikey=value
        This also supports adding connection parameters using the following format:
            {name}:connection_param:{param_name}=value
     Any objects with the same name as objects comming in from the load function will be replaced
     
     - returns:
     Returns the same instance of the config object so that you can repeatedly call load functions within the same line
     eg.  config.loadFromEnv().load(fromFile: "global config.json").load(fromFile: "user config.json")
     
     - parameters:
        - fromKeyValuePair: The values to load
     */
    @discardableResult
    public func load(fromKeyValuePair kv: [String: String]) -> Config {
        guard kv.count > 0 else { return self }
        
        let cfg: Config = Config(keyValuePair: kv)
        self.merge(with: cfg)
        
        return self
    }
    
}
