//
//  FirebaseConstants.swift
//  Pods
//
//  Created by Jose David Mantilla Pabon on 8/27/17.
//
//

import Foundation
// Firebase database keys.
public typealias FirebaseKeys = FirebaseClient.Keys

// MARK: - FirebaseClient (Constants)
extension FirebaseClient {
    
    // MARK: - Constants
    /// Firebase constants used by the FirebaseClient
    internal struct Constants {
        /// API version
        internal static var APIVersion = "/v1"
        /// Scheme used by the API
        internal static let APIScheme = "https"
        /// API host where request are made
        internal static var APIHost = "us-central1-vivebacano.cloudfunctions.net"
    }
    
    // MARK: - Keys
    /// Firebase database keys used in requests and listeners.
    public struct Keys {
        
        /// Keys for the user related requests.
        public struct Users {
            static let users = "users"
            static let email = "email"
            static let password = "password"
            static let name = "name"
            static let photoURL = "photoURL"
        }
        
        /// Keys for the constants values.
        internal struct Constants {
            internal static let APIVersion = "FirebaseClientAPIVersion"
            internal static let APIHost = "FirebaseClientAPIHost"
        }
        
        /// Key to relate objects in database.
        public static let key = "key"
        /// Id to relate objects in database.
        public static let id = "id"
    }
    
}
