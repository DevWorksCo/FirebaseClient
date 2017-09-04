//
//  RequestType.swift
//  Pods
//
//  Created by Jose David Mantilla Pabon on 8/27/17.
//
//

import Foundation
import UIKit

/**
 * Defines the type of request being made to the database.
 */
public typealias FirebaseRequest = RequestType

// MARK: - RequestType
/**
 * Defines the type of request being made to the database.
 */
public struct RequestType {
    
    // MARK: - Properties
    // Stored
    /// Path where the request is to be made.
    public let path: String
    /// Method to be used in the request.
    private let methodType: Method
    /// `false` if the request doesn't require an authorization header.
    public let requiresAuthorization: Bool
    
    // Computed
    /// Method string to be  used in the request.
    public var method: String {
        get {
            return methodType.rawValue
        }
    }
    
    // MARK: - Requests
    /// Create user request.
    public static let createUser = RequestType(path: "users", method: .post, requiresAuthorization: false)
    /// Update user request.
    public static let updateUser = RequestType(path: "users/me/personal-info", method: .put)
    
    // MARK: - Initializers
    /**
     * Creates a request type with a path and a method.
     */
    public init(path: String, method: Method, requiresAuthorization: Bool = true) {
        self.path = path
        self.methodType = method
        self.requiresAuthorization = requiresAuthorization
    }
}

// MARK: - RequestType (Types)
extension RequestType {
    // MARK: - Methods
    /**
     * Defines the HTTP method that can be used with the request type.
     */
    public enum Method: String {
        /// HTTP `GET` request.
        case get = "GET"
        /// HTTP `POST` request.
        case post = "POST"
        /// HTTP `PUT` request.
        case put = "PUT"
        /// HTTP `DELETE` request.
        case delete = "DELETE"
    }
}

// MARK: - RequestType: Equatable
extension RequestType: Equatable {
    public static func ==(lhs: RequestType, rhs: RequestType) -> Bool {
        return lhs.method == rhs.method && lhs.path == rhs.path
    }
}
