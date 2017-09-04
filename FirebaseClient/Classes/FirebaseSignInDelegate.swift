//
//  FirebaseSignInDelegate.swift
//  Pods
//
//  Created by Jose David Mantilla Pabon on 8/27/17.
//
//

import Foundation
// MARK: - FirebaseSignInDelegate
/**
 * An Object that adopts FirebaseSignInDelegate is responsible for providing the actions to take
 * after an user has successfully signed in.
 */
public protocol FirebaseSignInDelegate: class {
    
    /**
     * Function to be called after the sign in process is finished.
     * - parameter signedIn: nil if there's an error, true if user has successfully signed in or
     * false if user did not signed in.
     * - parameter error: Error that may occur during the signing in process.
     */
    func userDidSignIn(signedIn: Bool?, error: FirebaseError?)
}
