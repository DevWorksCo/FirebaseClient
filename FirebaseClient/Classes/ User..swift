//
//   User..swift
//  Pods
//
//  Created by Jose David Mantilla Pabon on 8/27/17.
//
//

import Foundation
// MARK: - StandardUser: FirebaseData
/**
 * Defines an user object.
 *
 * You can set a delegate for the settings and the profile view so that when a change occur in any
 * property it gets updated acording to the delegate implementation.
 */
open class User: FirebaseData {
    
    // MARK: - Properties
    public var key: String?
    /// User's name.
    public var name: String {
        didSet {
            // Calls all the delegates to update with changes.
            for delegate in delegates {
                delegate.didChange(name: name)
            }
        }
    }
    /// User's email.
    public var email: String {
        didSet {
            // Calls all the delegates to update with changes.
            for delegate in delegates {
                delegate.didChange(email: email)
            }
        }
    }
    /// User's profile picture.
    public var profilePicture: UIImage? {
        didSet {
            // Calls all the delegates to update with changes.
            for delegate in delegates {
                delegate.didChange(profilePicture: profilePicture)
            }
        }
    }
    
    /// ProfilePictureURL
    private var profilePictureURL: String?
    
    /// Delegates for changes in settings.
    private var delegates = [UserDelegate]()
    
    // MARK: - Initializers
    public required init?(key: String, dictionary: [String : Any]) {
        // GUARD: Name
        guard let name = dictionary[FirebaseKeys.Users.name] as? String else {
            return nil
        }
        
        // GUARD: email
        guard let email = dictionary[FirebaseKeys.Users.email] as? String else {
            return nil
        }
        
        // GUARD: profile picture
        if let profilePictureURL = dictionary[FirebaseKeys.Users.photoURL] as? String {
            self.profilePictureURL = profilePictureURL
        }
        
        // Create object
        self.key = key
        self.name = name
        self.email = email
    }
    
    /**
     * Initializer for user not retrieved from the database, i.e., currently signed in user.
     *
     * - parameter name: User's name.
     * - parameter email: User's email.
     * - parameter profilePicture: User's profile picture.
     */
    internal init(name: String, email: String, profilePicture: UIImage? = nil) {
        self.name = name
        self.email = email
        self.profilePicture = profilePicture
    }
    
    // MARK: - Methods
    /**
     * Adds provided UserDelegate as a delegate for this user.
     *
     * **Important:** you must remove the delegate before the object should be deinitialized so that
     * a strong reference can not be held.
     *
     * - parameter delegate: Delegate to add to this user.
     */
    open func add(delegate: UserDelegate) {
        delegates.append(delegate)
    }
    
    /**
     * Removes provided UserDelegate as a delegate for this user.
     *
     * - parameter delegate: Delegate to remove from this user.
     */
    open func remove(delegate: UserDelegate) {
        for i in 0 ..< self.delegates.count {
            if delegates[i].isEqual(delegate) {
                self.delegates.remove(at: i)
                break
            }
        }
    }
}

// MARK: - User: Equatable
extension User {
    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func ==(lhs: User, rhs: User) -> Bool {
        return lhs.key == rhs.key
    }
}

// MARK: - UserDelegate: NSObjectProtocol
/**
 * A class that conforms to the UserDelegate protocol is responsible for providing the
 * implementations for the methods called when there's an update in the user information.
 */
public protocol UserDelegate: NSObjectProtocol {
    /**
     * Called after the name is set.
     * - parameter name: User's new name.
     */
    func didChange(name: String?)
    
    /**
     * Called after the email is set.
     * - parameter email: User's new email.
     */
    func didChange(email: String?)
    
    /**
     * Called after the profile picture is set.
     * - parameter profilePicture: User's new profile picture.
     */
    func didChange(profilePicture: UIImage?)
}
