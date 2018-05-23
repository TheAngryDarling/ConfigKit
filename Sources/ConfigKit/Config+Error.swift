//
//  Config+Error.swift
//  ConfigKit
//
//  Created by Tyler Anger on 2018-05-17.
//

import Foundation

public extension Config {
    /**
     Possible local errors thrown by the Config load functions
     
     - unknownConfigType: Unable to figure out how to parse the file.  File stored within enum
     - fileNotFound: Could not locate file for loading
    */
    public enum Error: Swift.Error {
        /// Unable to figure out how to parse the file.  File stored within enum
        case unknownConfigType(String)
        /// Could not locate file for loading
        case fileNotFound(String)
    }
}
