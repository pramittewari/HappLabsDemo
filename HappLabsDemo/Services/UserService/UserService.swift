//
//  UserService.swift
//  HappLabsDemo
//
//  Created by Pramit on 23/03/20.
//  Copyright © 2020 Pramit Tewari. All rights reserved.
//

import UIKit
import SwiftyJSON
import CocoaLumberjack
import Alamofire

protocol LoginDelegate: class {
    
    func userLoggedIn()
}

/// This service is responsible for all user related opertions like: - login, forgot password, view and edit profile
class UserService {
    
    // MARK: - Variables
    
    ///
    private let networkSerivce: NetworkService
    ///
    private let storageService: StorageService
    ///
    private var user: User?
    ///
    weak var loginDelegate: LoginDelegate?

    // MARK: - Life Cycle Methods
    
    ///
    init(networkSerivce: NetworkService, storageService: StorageService) {
        
        self.networkSerivce = networkSerivce
        self.storageService = storageService
        
        user = storageService.getUser()
        networkSerivce.update(authenticationToken: user?.authenticationToken ?? "")
    }
    
    // MARK: - Save/Get Methods
    
    /**
     Call to get the saved use
     
     - returns: the current user.
     */
    func getUser() -> User? {
        return user
    }
    
    /// Call to save the user
    func saveUser() {
        guard let user = user else {
            storageService.deleteUser()
            return
        }
        // Make access token publicly available for api
        networkSerivce.update(authenticationToken: user.authenticationToken ?? "")
        storageService.saveUser(user)
    }
    
    /// Delete info of user
    func deleteUser() {
        // Delete info
        self.user = nil
        networkSerivce.update(authenticationToken: "")
        saveUser()
    }
    
    // MARK: - API Methods
    
    /// Login user into the app
    func loginUser(withParameters parameters: [String: Any], completionHandler: @escaping ((_ statusCode: Int, _ isSuccess: Bool, _ error: String?) -> Void)) {
        
        networkSerivce.request(parameters: parameters, apiPath: APIList.UserManagement.signIn, httpMethod: .post, success: { [weak self] (statusCode, response, authenticationToken)  in
            
            let jsonResponse = JSON(response)
            let basicResponse = BasicResponse(jsonResponse: jsonResponse)
            
            if basicResponse.success {
                
                // Create new user
                self?.user = User()
                self?.user?.updateValues(fromResponse: jsonResponse)
                self?.user?.authenticationToken = authenticationToken ?? ""
                self?.saveUser()
                self?.loginDelegate?.userLoggedIn()
                completionHandler(statusCode, true, nil)
                
            } else {
                completionHandler(statusCode, false, basicResponse.message)
            }
            }, failure: { (statusCode, error) in
                print(error?.localizedDescription ?? "SOMETHING_WENT_WRONG")
                completionHandler(statusCode, false, error?.localizedDescription)
        })
    }
    
    /// Register user
    func registerUser(withParameters parameters: [String: Any], completionHandler: @escaping BasicCompletion) {

        networkSerivce.request(parameters: parameters, apiPath: APIList.UserManagement.signUp, httpMethod: .post, success: { (statusCode, response, _)  in
            
            let jsonResponse = JSON(response)
            let basicResponse = BasicResponse(jsonResponse: jsonResponse)
            
            if basicResponse.success {
                completionHandler(statusCode, true, basicResponse.message)
            } else {
                completionHandler(statusCode, false, basicResponse.message)
            }

        }, failure: { (statusCode, error) in
                completionHandler(statusCode, false, error?.localizedDescription)
        })
    }
}
