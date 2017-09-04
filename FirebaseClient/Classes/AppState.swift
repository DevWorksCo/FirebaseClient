//
//  AppState.swift
//  Pods
//
//  Created by Jose David Mantilla Pabon on 8/27/17.
//
//

import Foundation
// MARK: AppState
/**
 * This class manages the app state, i.e., signed in users, etc. This class is a
 * singleton so you need to called the `shared` property to perform any changes in the app state.
 */
open class AppState {
    
    // MARK: - Properties.
    /// Shared instance.
    public static let shared = AppState()
    
    /// Defines the currently signed in user.
    public var currentUser: User?
    
    /**
     * FirebaseClient private initializer to keep users from accidentally creating an instance of
     * the AppState.
     */
    private init() {}
    
}
