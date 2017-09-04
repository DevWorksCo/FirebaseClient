//
//  FirebaseData.swift
//  Pods
//
//  Created by Jose David Mantilla Pabon on 8/27/17.
//
//

import Foundation
/**
 * An objects that adopts the FirebaseData protocol is responsible for providing the methods
 * for converting from a dictionary to facilitate the process of creating and reusing
 * the data model.
 */
public protocol FirebaseData: Equatable {
    
    /// Firebase object key in database.
    var key: String? { get }
    
    /**
     * Creates a FirebaseData object using a dictionary.
     * - parameter id: Firebase object key.
     * - parameter dictionary: Dictionary containing the data needed for its creation.
     */
    init?(key: String, dictionary: [String: Any])
    
}
