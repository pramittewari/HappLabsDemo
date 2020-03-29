//
//  SignInInteractor.swift
//  HappLabsDemo
//
//  Created by Pramit on 24/03/20.
//  Copyright © 2020 Pramit Tewari. All rights reserved.
//

import UIKit
import Foundation
import CocoaLumberjack

class SignInInteractor: Interacting {
    
    private var router: UserManagementRouter
    
    var view: SignInViewController?
    
    var userService: UserService
    
    init (router: UserManagementRouter, userService: UserService) {
        
        self.router = router
        self.userService = userService
    }
    
    func validate(email: String?, password: String?) -> Bool {
        
        // Email address
        let emailValidation = Validator.validate(email: email ?? "", customName: "email address.")
        guard emailValidation.isValid else {
            view?.showOkAlert(message: emailValidation.message ?? "")
            return false
        }
        
        // Password
        if view?.passwordTextField.text == "" {
            view?.showOkAlert(message: "Password can't be empty")
            return false
        }
        
        return true
    }
    
    func signInUser(email: String?, password: String?) {
        
        guard validate(email: email, password: password) else { return }
        
        let parameters: [String: Any] = [
            "form_username": email ?? "",
            "form_password": password ?? ""
        ]
        
        view?.showProgressHudView()
        userService.loginUser(withParameters: parameters) { [weak self] (_, success, message) in
            
            self?.view?.hideProgressHudView()
            
            guard success else {
                self?.view?.showOkAlert(message: message ?? "Could not login")
                return
            }
            
            self?.dismissSignInScreen()
        }
    }
 
    func navigateToSignUpScreen() {
        
        router.presentSignUpScreen()
    }
    
    func dismissSignInScreen() {
        
        router.dismissScreen()
    }
}
