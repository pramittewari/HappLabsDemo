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

/// This service is responsible for all user related opertions like: - login, forgot password, view and edit profile
class UserService {
    
    // MARK: - Variables
    
    ///
    private let networkSerivce: NetworkService
    ///
    private let storageService: StorageService
    ///
    private var user: User?

    // MARK: - Life Cycle Methods
    
    ///
    init(networkSerivce: NetworkService, storageService: StorageService) {
        
        self.networkSerivce = networkSerivce
        self.storageService = storageService
        user = storageService.getUser()
        networkSerivce.update(sessionKey: user?.sessionKey ?? "")
        print("Session Key - \(user?.sessionKey ?? "")")
    }
    
    // MARK: - Save/Get Methods
    
    /**
     Call to get the saved use
     
     - returns: the current user.
     */
    func getUser() -> User? {
        return user
    }
    
    // TODO: Update whole profile when profile is edited
    func updateUserName(withFirstName firstName: String?, lastName: String?) {
        
        user?.firstName = firstName
        user?.lastName = lastName
        
        saveUser()
    }
    
    /// Call to save the user
    func saveUser() {
        guard let user = user else {
            storageService.deleteUser()
            return
        }
        // Make access token publicly available for api
        networkSerivce.update(sessionKey: user.sessionKey ?? "")
        storageService.saveUser(user)
    }
    
    /// Delete info of user
    func deleteUser() {
        // Delete info
        self.user = nil
        networkSerivce.update(sessionKey: "")
        saveUser()
    }
    
    // MARK: - API Methods
    
    /// Login user into the app
    func loginUser(withParameters parameters: [String: Any], completionHandler: @escaping ((_ statusCode: Int, _ isSuccess: Bool, _ data: JSON?, _ error: String?) -> Void)) {
        
        networkSerivce.request(parameters: parameters, apiPath: APIList.UserManagement.signIn, httpMethod: .post, success: { [weak self](statusCode, response) in
            let jsonResponse = JSON(response)
            let basicResponse = BasicResponse(jsonResponse: jsonResponse)
            
            if basicResponse.success, let data = response["data"] as? [String: Any] {
                
                // Create new user
                self?.user = User()
                self?.user?.updateValues(fromResponse: data)
                self?.saveUser()
                completionHandler(statusCode, true, nil, nil)
                
            } else {
                completionHandler(statusCode, false, nil, basicResponse.message)
            }
            }, failure: { (statusCode, error) in
                print(error?.localizedDescription ?? "SOMETHING_WENT_WRONG")
                completionHandler(statusCode, false, nil, error?.localizedDescription)
        })
    }
    
    /// Register user
    func registerUser(withParameters parameters: [String: Any], completionHandler: @escaping BasicCompletion) {

        networkSerivce.request(parameters: parameters, apiPath: APIList.UserManagement.signUp, httpMethod: .post, success: { [weak self](statusCode, response) in
            let jsonResponse = JSON(response)
            let basicResponse = BasicResponse(jsonResponse: jsonResponse)
            
            var userDetails = [String: Any]()
            if basicResponse.success, let value = response["data"] as? [String: Any] {
                userDetails = value
            } else {
                completionHandler(statusCode, false, basicResponse.message)
            }
            // Create new user
            if basicResponse.success {
                self?.user = User()
                self?.user?.updateValues(fromResponse: userDetails)
                self?.saveUser()
            }
            completionHandler(statusCode, basicResponse.success, basicResponse.message ?? "")
            }, failure: { (statusCode, error) in
                print(error?.localizedDescription ?? "SOMETHING_WENT_WRONG")
                completionHandler(statusCode, false, error?.localizedDescription)
        })
    }
}
