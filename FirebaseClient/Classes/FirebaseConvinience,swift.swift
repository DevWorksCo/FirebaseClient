//
//  FirebaseConvinience,swift.swift
//  Pods
//
//  Created by Jose David Mantilla Pabon on 8/27/17.
//
//

import Foundation
/**
 * Defines errors that can be presented during the execution of any firebase task.
 */
public typealias FirebaseError = FirebaseClient.ErrorType

// MARK: - FirebaseClient (Convinience)
extension FirebaseClient {
    
    // MARK: - Helpers
    /**
     * Makes a request to a the FirebaseClient cloud functions.
     *
     * - parameter type: Type of request to perform.
     * - parameter headers: headers to be sent with the request.
     * - parameter body: Request body.
     * - parameter parameters: required request parameters.
     * - parameter completion: invoked when the request is completed or if there's an error.
     */
    public func firebaseRequest(type: FirebaseRequest, headers: [String: String]? = nil, body: [String: Any]? = nil, parameters: [String: Any]? = nil , completion: @escaping (_ response: Any?, _ error: FirebaseError?) -> Void) {
        
        if type.requiresAuthorization {
            // Is user signed in
            guard let currentUser = currentUser else {
                return completion(nil, .notSignedIn)
            }
            
            // Get token
            currentUser.getIDTokenForcingRefresh(true, completion: { (idToken, error) in
                if error != nil {
                    return completion(nil, .firebaseInternalError)
                }
                
                // Add authorization header
                var headers = headers
                if var headers = headers {
                    headers["Authorization"] = idToken!
                } else {
                    headers = ["Authorization": idToken!]
                }
                
                self.firebaseRequestOnly(type: type, headers: headers, body: body, parameters: parameters, completion: completion)
            })
        } else {
            firebaseRequestOnly(type: type, headers: headers, body: body, parameters: parameters, completion: completion)
        }
        
    }
    
    /**
     * Makes a request to a the FirebaseClient cloud functions. Used by firebaseRequest so that
     * there's no repetition of code.
     *
     * - parameter type: Type of request to perform.
     * - parameter headers: headers to be sent with the request.
     * - parameter body: Request body.
     * - parameter parameters: required request parameters.
     * - parameter completion: invoked when the request is completed or if there's an error.
     */
    private func firebaseRequestOnly(type: FirebaseRequest, headers: [String: String]? = nil, body: [String: Any]? = nil, parameters: [String: Any]? = nil , completion: @escaping (_ response: Any?, _ error: FirebaseError?) -> Void) {
        
        // Create url object
        var components = URLComponents()
        components.scheme = Constants.APIScheme
        components.host = Constants.APIHost
        components.path = type.path
        
        // Add parameters to query if provided
        if let parameters = parameters {
            components.queryItems = [URLQueryItem]()
            
            for (key, value) in parameters {
                let queryItem = URLQueryItem(name: key, value: "\(value)")
                components.queryItems!.append(queryItem)
            }
        }
        
        // Create request object
        var request = URLRequest(url: components.url!)
        request.httpMethod = type.method
        
        if let body = body {
            do {
                // Create request body if provided.
                let data = try JSONSerialization.data(withJSONObject: body, options: [])
                
                request.httpBody = data
                
                // Add json header because of body.
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                
            } catch {
                completion(nil, ErrorType.taskError)
            }
        }
        
        // Add headers to request if provided.
        if let headers = headers {
            for (key, value) in headers {
                request.addValue(value, forHTTPHeaderField: key)
            }
        }
        
        // Create session
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            // Connectivity errors, etc.
            if error != nil {
                return completion(nil, ErrorType.taskError)
            }
            
            // GUARD: There was a response from server
            guard let response = response as? HTTPURLResponse else {
                return completion(nil, ErrorType.noResponse)
            }
            
            // Check status code and respond accordingly
            let statusCode = response.statusCode
            switch (statusCode) {
            case 200:
                let response = try? JSONSerialization.jsonObject(with: data!, options: [])
                completion(response, nil)
            case 400 ..< 500:
                let message = String(data: data!, encoding: String.Encoding.utf8)!
                completion(nil, ErrorType.validation(with: message))
            default:
                completion(nil, ErrorType.firebaseInternalError)
            }
        }
        
        // Start task
        task.resume()
    }
    
    // MARK: - Types
    /**
     * Defines errors that can be presented during the execution of any firebase task.
     */
    public enum ErrorType: Error {
        /// There was no response from the server.
        case noResponse
        /// A validation error occurred.
        case validation(with: String)
        /// A Firebase internal error occurred.
        case firebaseInternalError
        /// URLTask error.
        case taskError
        /// There's no user signed in at the moment.
        case notSignedIn
        /// User tried to perform an action with an user that doesn't exists.
        case wrongEmail
        /// User tried to sign in with a wrong password
        case wrongPassword
        /// Error with facebook log in method.
        case facebookLogInError
        /// Error with the google sign in method.
        case googleSignInError
        /// Couldn't parse the recieved data.
        case parseError
        
        /**
         * User friendly error description to be shown in case of error.
         */
        public var description: String {
            get {
                switch self {
                case .validation(let message):
                    return message
                case .notSignedIn:
                    return "User needs to be signed in to perform this action"
                case .wrongEmail:
                    return "User does not exists"
                case .wrongPassword:
                    return "Wrong email/password combination"
                case .facebookLogInError:
                    return "An error with the facebook login ocurred"
                case .googleSignInError:
                    return "An error with the google sign in ocurred"
                case .parseError:
                    return "Couln't parse found data"
                default:
                    return "Connection error. Please try again"
                }
            }
        }
    }
    
}
