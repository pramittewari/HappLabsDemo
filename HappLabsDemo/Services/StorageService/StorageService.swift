//
//  StorageService.swift
//  HappLabsDemo
//
//  Created by Pramit on 23/03/20.
//  Copyright © 2020 Pramit Tewari. All rights reserved.
//

import Foundation
import CocoaLumberjack

/// This service will handle saving data and retrieving saved data
class StorageService {

    // MARK: - Types of storage service

    /// This stores and manages UserDefaults storage
    // private let localStorage: LocalStorageService? = nil
    ///
    // private let cloudStorage = CloudStorageService()

    // MARK: - Onboarding

    ///  Save true as on boarding is shown once.
    ///
    /// - Parameter isShown: Bool value to be stored
    func setOnBoarding(isShown: Bool) {

        LocalStorageService.setShowUserOnboarding(isShown)
    }

    /**
     Get true or false as on boarding is shown once or not.

     - returns: true or false if on boarding screen is shown or not.
     */
    func getIfOnBoardingIsShown() -> Bool {

        return LocalStorageService.getShowUserOnboarding() ?? false
    }
    
    // MARK: - User
    
    /**
     Call to save User's info and preferences
     
     - parameter user: user info to save
     */
    func saveUser(_ user: User) {
        
        LocalStorageService.saveUser(user)
    }
    
    /**
     Call to get User saved info and preferences
     
     - returns: previously saved user info
     */
    func getUser() -> User? {
        
        return LocalStorageService.getUser()
    }
    
    /**
     Call to save User's login credentials
     
     - parameter user: user info to save
     */
    func saveLoginCredentials(_ loginCredentials: LoginCredentials) {
        
        LocalStorageService.saveLoginCredentials(loginCredentials)
    }
    
    /**
     Call to get User saved login credentials
     
     - returns: previously saved user info
     */
    func getLoginCredentials() -> LoginCredentials? {
        
        return LocalStorageService.getLoginCredentials()
    }
    
    /**
    Call to delete User saved login credentials
    */
    func deleteCredentials() {
        LocalStorageService.deleteCredentials()
    }
    
    /**
     Call to delete User saved info and preferences
     */
    func deleteUser() {
        
        LocalStorageService.deleteUser()
    }
}
