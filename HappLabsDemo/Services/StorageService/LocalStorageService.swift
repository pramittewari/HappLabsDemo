//
//  LocalStorageService.swift
//  HappLabsDemo
//
//  Created by Pramit on 23/03/20.
//  Copyright © 2020 Pramit Tewari. All rights reserved.
//

import Foundation
import CocoaLumberjack

// This service will handle saving and retrieving locally
class LocalStorageService {

    // MARK: - Private  Save and Get Methods
    // these are generic reusable methods not available outside this class

    /**
     Call to save object data in local storage.
     Use this method for storing items that don't have their own built-in storage method
     and objects that are not simple PList objects.
     Bool, URL, Dictionary, Array, [String], Int, Float, Data all have their own built-in
     methods, the rest we store as objects of type (`Any?`)

     - parameter object: The object data to be stored.
     - parameter key: The key used to get and set the value
     */
    private static func save<T: Codable>(_ object: T, for key: String) {

        // create an encoder to encode the object to data
        let encoder = JSONEncoder()
        do {
            // encode and store
            let data = try encoder.encode(object)
            UserDefaults.standard.set(data, forKey: key)
        } catch let error {
            // encoding failed
            DDLogError("error encoding: \(error)")
        }
    }

    /**
     Call to retrieve previously stored object data from UserDefaults

     - parameter key: The key used to get and set the value

     - returns: Optional object of the specified type `T` (e.g. String?, User?)
     or nil if not found
     */
    private static func get<T: Codable>(for key: String) -> T? {

        // if we do not find the saved data, return nil
        guard let data = UserDefaults.standard.data(forKey: key) else {
            return nil
        }

        // the saved data was found so create a decoder to decode it
        let decoder = JSONDecoder()
        do {
            // decode the retrieved data to specified type
            return try decoder.decode(T.self, from: data)
        } catch let error {
            // decoding failed; return nil
            DDLogError("error encoding: \(error)")
            return nil
        }
    }

    // MARK: - Types of save and get methods

    ///
    private static func saveDate(_ date: Date, for key: String) {

        UserDefaults.standard.set(date, forKey: key)
    }

    ///
    private static func getDate(for key: String) -> Date? {

        return UserDefaults.standard.value(forKey: key) as? Date
    }

    /**
     Call to save a Bool value. An example of this would be saving a Bool named
     `showUserOnboarding` with the value `false` if the user has already been
     through the onboarding slideshow. That value would be checked when the user
     opens the app and if false, the app would load the tabBar instead of showing
     the onboarding slideshow.

     - parameter bool: The Bool value to be stored.
     - parameter key: The key used to get and set the value
     */
    private static func saveBool(_ bool: Bool?, for key: String) {

        UserDefaults.standard.set(bool, forKey: key)
    }

    /**
     Call to retrieve a previously stored Bool from UserDefaults

     - parameter key: The key used to get and set the Bool value

     - returns: Optional value of the Bool for the specified key or nil if not found
     */
    private static func getBool(for key: String) -> Bool? {

        return UserDefaults.standard.bool(forKey: key)
    }

    /**
     Call to delete a previously saved object for the specified key

     - parameter key: Key that was used to store the object in `UserDefaults`
     */
    private static func deleteObject(for key: String) {

        UserDefaults.standard.removeObject(forKey: key)
    }
}

// MARK: - Public Methods

// for specific storage needs
extension LocalStorageService {

    /**
     Call to set the flag that determines whether to show the onboarding slideshow
     when the app is launched. Probably will only be set as `false` because by
     default, we show the slideshow and then set to false after the user has seen it.

     - paramater show: Should we show the user onboarding slideshow when the app launches?
     */
    public static func setShowUserOnboarding(_ show: Bool) {

        LocalStorageService.saveBool(show, for: LocalStorageKeys.Onboarding)
    }

    /**
     Call to get the flag that determines whether to show the onboarding slideshow
     when the app is launched. Probably will only be set as `false` because by
     default, we show the slideshow and then set to false after the user has seen it.
     */
    public static func getShowUserOnboarding() -> Bool? {

        return LocalStorageService.getBool(for: LocalStorageKeys.Onboarding)
    }
    
    // MARK: - User Methods
    
    /**
     Call to save User
     
     - parameter user: user info to save
     */
    static func saveUser(_ user: User) {
        LocalStorageService.save(user, for: LocalStorageKeys.UserInfo)
    }
    
    /**
     Call to get User saved info and preferences
     
     - returns: previously saved user info
     */
    static func getUser() -> User? {
        let user: User? = LocalStorageService.get(for: LocalStorageKeys.UserInfo)
        return user
    }
    
    /**
     Call to save User login credentials
     
     - parameter loginCredentials: user info to save
     */
    static func saveLoginCredentials(_ loginCredentials: LoginCredentials) {
        LocalStorageService.save(loginCredentials, for: LocalStorageKeys.LoginCredentials)
    }
    
    /**
    Call to delete User login credentials
    
    - parameter loginCredentials: user info to save
    */
    static func deleteCredentials() {
        LocalStorageService.deleteObject(for: LocalStorageKeys.LoginCredentials)
    }
    /**
     Call to get User saved login credentials
     
     - returns: previously saved user info
     */
    static func getLoginCredentials() -> LoginCredentials? {
        let loginCredentials: LoginCredentials? = LocalStorageService.get(for: LocalStorageKeys.LoginCredentials)
        return loginCredentials
    }
    
    /**
     Call to delete Users saved info and preferences
     
     */
    static func deleteUser() {
        LocalStorageService.deleteObject(for: LocalStorageKeys.UserInfo)
    }
}
