//
//  FirebaseClient.swift
//  Pods
//
//  Created by Jose David Mantilla Pabon on 8/27/17.
//
//

import Foundation
import FirebaseAnalytics
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase
import GoogleSignIn
import FBSDKLoginKit

// MARK: - FirebaseClient
/**
 * Defines a completion handler for a non-returning FirebaseClient function.
 * - parameter error: nil if no error ocurred during the process.
 */
public typealias FirebaseCompletion = (_ error: FirebaseError?) -> Void

/**
 * Defines a completion handler for a FirebaseClient function that should return an user.
 * - parameter user: User fetched from the database.
 * - parameter error: nil if no error ocurred during the process.
 */
public typealias FirebaseAuthUserCompletion = (_ user: FirebaseAuth.User?, _ error: FirebaseError?) -> Void

/**
 * Defines a completion handler for a FirebaseClient function that should return an user.
 * - parameter user: User fetched from the database.
 * - parameter error: nil if no error ocurred during the process.
 */
public typealias FirebaseUserCompletion = (_ user: User?, _ error: FirebaseError?) -> Void

/**
 * FirebaseClient defines an API to perform all of the app's Firebase requests. This client is a
 * singleton so you need to called the `shared` property to perform any request to the database.
 *
 * For all sign in methods it's necessary to provide a delegate that conforms to the
 * FirebaseSignInDelegate protocol. It should be assigned to `signInDelegate`.
 */
public class FirebaseClient: NSObject {
    
    // MARK: - Properties
    // Client properties
    /// FirebaseClient shared singleton
    public static let shared = FirebaseClient()
    /// Firebase sign in delegate
    public weak var signInDelegate: FirebaseSignInDelegate?
    /// Database reference object to the root of the Firebase database.
    fileprivate let ref = Database.database().reference()
    
    // State properties
    /// Currently signed in user. If it's nil, that means the no user is signed in.
    internal var currentUser: FirebaseAuth.User?
    /// View controller requesting sign in with google. This value is stored so that the
    /// FirebaseClient can show the google sign in WebView.
    fileprivate var googleSignInViewController: UIViewController?
    
    // MARK: - Initializers
    /**
     * FirebaseClient private initializer to keep users from accidentally creating an instance of
     * the FirebaseClient. It also handles the user state and takes measures when user signs in or out.
     */
    override private init() {
        Auth.auth().addStateDidChangeListener {(auth, user) in
            FirebaseClient.shared.currentUser = user
        }
    }
    
    // MARK: - Methods
    /**
     * Configures this app so that it's ready to used. This method is to be called before
     * any request using the FirebaseClient.
     */
    public static func configure() {
        FirebaseApp.configure()
        
        guard let path = Bundle.main.path(forResource: "Info", ofType: "plist") else {
            return
        }
        
        guard let dict = NSDictionary(contentsOfFile: path) as? [String: Any] else {
            return
        }
        
        if let version = dict[Keys.Constants.APIVersion] as? String {
            Constants.APIVersion = version
        }
        
        if let host = dict[Keys.Constants.APIHost] as? String {
            Constants.APIHost = host
        }
    }
    
    // MARK: - User methods
    /**
     * Creates an user using email, password and name.
     *
     * - parameter email: User's email.
     * - parameter password: User's password.
     * - parameter name: Users' name.
     * - parameter completion: Invoked when request failed or completed.
     */
    public func createUser(email: String, password: String, name: String, completion: @escaping FirebaseCompletion) {
        // Create parameter dictionary
        let body = [Keys.Users.email: email as AnyObject,
                    Keys.Users.password: password as AnyObject,
                    Keys.Users.name: name as AnyObject] as [String: AnyObject]
        
        // Make the request to the database.
        firebaseRequest(type: .createUser, body: body) { (data, error) in
            // Check if there was an error
            if let error = error {
                return completion(error)
            }
            
            // User created correctly
            completion(nil)
        }
    }
    
    /**
     * Updates an user's field.
     *
     * - parameter email: User's new email.
     * - parameter name: User's new name.
     * - parameter compeltion: invoked when the request failed or completed.
     */
    public func editUser(email: String? = nil, name: String? = nil, completion: @escaping FirebaseCompletion) {
        
        // Create parameter body
        var body = [String: AnyObject]()
        body[Keys.Users.email] = email as AnyObject?
        body[Keys.Users.name] = name as AnyObject?
        
        FirebaseClient.shared.firebaseRequest(type: .updateUser, body: body) { (data, error) in
            // Check if there was an error
            if let error = error {
                return completion(error)
            }
            
            // User updated correctly
            completion(nil)
        }
    }
    
    /**
     * Change an user's password.
     *
     * For this method to work user needs to have reauthenticated.
     *
     * - parameter password: User's new password.
     * - parameter completion: Invoked when the request failed or completed.
     */
    public func editUser(password: String, completion: @escaping FirebaseCompletion) {
        FirebaseClient.shared.currentUser?.updatePassword(to: password, completion: { (error) in
            if error != nil {
                return completion(.firebaseInternalError)
            }
            
            completion(nil)
        })
    }
    
    // MARK: - Authentication methods
    /**
     * Signs user in with email and password.
     *
     * The `signInDelegate` will be called at the end of this process indicating success or error.
     *
     * - parameter email: User's email.
     * - parameter password: User's password.
     */
    public func signIn(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password, completion: { (_, error) in
            // Is there an error?
            if let error = error{
                // Get error code
                if let code = AuthErrorCode(rawValue: error._code) {
                    // Check error type
                    switch code {
                    case AuthErrorCode.wrongPassword, AuthErrorCode.userNotFound:
                        // Wrong password
                        self.signInDelegate?.userDidSignIn(signedIn: nil, error: .wrongPassword)
                    default:
                        // Any other case
                        self.signInDelegate?.userDidSignIn(signedIn: nil, error: .firebaseInternalError)
                    }
                    return
                }
                // Couldn't get error code
                self.signInDelegate?.userDidSignIn(signedIn: nil, error: .firebaseInternalError)
                return
            }
            
            self.signInDelegate?.userDidSignIn(signedIn: true, error: nil)
        })
    }
    
    /**
     * Signs user in using the facebook SDK.
     *
     * The `signInDelegate` will be called at the end of this process indicating success or error.
     *
     * - parameter viewController: UIViewController responsible for showing the facebook log in modal.
     */
    public func signInWithFacebook(from viewController: UIViewController) {
        let login = FBSDKLoginManager()
        // Flush user if there is one
        login.logOut()
        
        // Log in
        login.logIn(withReadPermissions: ["public_profile", "email"], from: viewController) { (result, error) in
            // Facebook could log in
            guard error == nil, let result = result else {
                self.signInDelegate?.userDidSignIn(signedIn: nil, error: .facebookLogInError)
                return
            }
            
            // Did user cancelled?
            guard !result.isCancelled else {
                self.signInDelegate?.userDidSignIn(signedIn: false, error: nil)
                return
            }
            
            // Get credential for firebase
            let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
            
            // Sign in with credentials
            Auth.auth().signIn(with: credential, completion: { (_, error) in
                // is there an error?
                if error != nil {
                    self.signInDelegate?.userDidSignIn(signedIn: nil, error: .noResponse)
                    return
                }
                
                self.signInDelegate?.userDidSignIn(signedIn: true, error: nil)
            })
        }
    }
    
    /**
     * Signs user in using google sign in.
     *
     * The `signInDelegate` will be called at the end of this process indicating success or error.
     *
     * - parameter viewController: View controller responsible for showing the google sign in modal.
     */
    public func signInWithGoogle(from viewController: UIViewController) {
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        FirebaseClient.shared.googleSignInViewController = viewController
        
        GIDSignIn.sharedInstance().signIn()
    }
    
    /**
     * Reauthanticates an already signed in user.
     *
     * Used when performing dangerous actions, e.g., changing password, etc.
     *
     * - parameter password: User's password.
     */
    public func reauthenticateUser(password: String, completion: @escaping FirebaseCompletion) {
        guard let email = AppState.shared.currentUser?.email else {
            return completion(.notSignedIn)
        }
        
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        
        guard let currentUser = currentUser else {
            return completion(.notSignedIn)
        }
        
        currentUser.reauthenticate(with: credential, completion: { (error) in
            if error != nil {
                return completion(.firebaseInternalError)
            }
            
            return completion(nil)
        })
    }
    
    /**
     * Gets currently signed in user.
     *
     * - parameter completion: Invoked when the request failed or completed.
     */
    public func getCurrentUser(completion: @escaping FirebaseAuthUserCompletion) {
        if currentUser != nil {
            completion(currentUser, nil)
        } else {
            let handle = Auth.auth().addStateDidChangeListener { (auth, user) in
                completion(user, nil)
            }
            
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
    /**
     * Signs user out using Firebase standard sign out method.
     *
     * - throws: If there's an error with the firebase method.
     */
    public func signOut() throws {
        guard let uid = currentUser?.uid else {
            return
        }
        FirebaseClient.shared.ref.child(Keys.Users.users)
            .child(uid).child(Keys.Users.name).removeAllObservers()
        
        FirebaseClient.shared.ref.child(Keys.Users.users)
            .child(uid).child(Keys.Users.email).removeAllObservers()
        
        try! Auth.auth().signOut()
    }
    
    // MARK: - User methods
    /**
     * Retrieves information of an user with the provided id.
     *
     * - parameter id: User key.
     * - parameter completion: Invoked when the request failed or completed.
     */
    public func getInfoForUser(withId id: String, completion: @escaping FirebaseUserCompletion) {
        self.ref.child(Keys.Users.users).child(id).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let dict = snapshot.value as? [String: Any] else {
                return completion(nil, .noResponse)
            }
            
            guard let user = User(key: snapshot.key, dictionary: dict) else {
                return completion(nil, .parseError)
            }
            
            completion(user, nil)
        })
    }
}

// MARK: - FirebaseClient: GIDSignInDelegate, GIDSignInUIDelegate
extension FirebaseClient: GIDSignInDelegate, GIDSignInUIDelegate {
    public func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if error != nil {
            signInDelegate?.userDidSignIn(signedIn: nil, error: .googleSignInError)
            return
        }
        
        let authentication = user.authentication!
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        
        Auth.auth().signIn(with: credential) { (user, error) in
            if error != nil {
                self.signInDelegate?.userDidSignIn(signedIn: nil, error: .firebaseInternalError)
                return
            }
            
            self.signInDelegate?.userDidSignIn(signedIn: true, error: nil)
        }
    }
    
    public func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
        googleSignInViewController?.present(viewController, animated: true, completion: nil)
    }
    
    public func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
        viewController.dismiss(animated: true, completion: nil)
    }
}

