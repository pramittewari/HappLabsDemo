//
//  SignUpInteractor.swift
//  HappLabsDemo
//
//  Created by Pramit on 24/03/20.
//  Copyright © 2020 Pramit Tewari. All rights reserved.
//

import UIKit
import Foundation
import CocoaLumberjack

class SignUpInteractor: Interacting {
    
    // MARK: - Variables
    private var router: UserManagementRouter
    var view: SignUpViewController?
    var userService: UserService
    
    // MARK: - Life cycle
    init (router: UserManagementRouter, userService: UserService) {
        
        self.router = router
        self.userService = userService
    }
    
    // MARK: - Helpers
    func validate(email: String?, userName: String?, password: String?, confirmPassword: String?) -> Bool {
        
        // Email address
        let emailValidation = Validator.validate(email: email ?? "", customName: "Email")
        guard emailValidation.isValid else {
            view?.showOkAlert(message: emailValidation.message ?? "")
            return false
        }
        
        guard !((userName ?? "").isEmpty) else {
            view?.showOkAlert(message: ValidationMessages.Username.empty)
            return false
        }
        
        // Password
        let passwordValidation = Validator.validate(password: password ?? "", customPassword: "Password")
        guard passwordValidation.isValid else {
            view?.showOkAlert(message: passwordValidation.message ?? "")
            return false
        }
        
        let confirmPasswordValidation = Validator.validate(firstPassword: password ?? "", secondPassword: confirmPassword ?? "")
        guard confirmPasswordValidation.isValid else {
            view?.showOkAlert(message: confirmPasswordValidation.message ?? "")
            return false
        }
        
        return true
    }
    
    func signUpUser(email: String?, userName: String?, password: String?, confirmPassword: String?) {
        
        guard validate(email: email, userName: userName, password: password, confirmPassword: confirmPassword) else { return }
        
        let parameters: [String: Any] = [
            "form_email": email ?? "",
            "form_uname": userName ?? "",
            "form_password": password ?? "",
            "form_confirm_password": confirmPassword ?? ""
        ]
        
        view?.showProgressHudView()
        userService.registerUser(withParameters: parameters) { [weak self] (_, success, message) in
            
            self?.view?.hideProgressHudView()
            
            guard success else {
                self?.view?.showOkAlert(message: message ?? "Could not sign up!")
                return
            }
            
            self?.view?.showAlert(message: "Signed up sucessfully!", buttonTitles: ["Okay"], customAlertViewTapButtonBlock: { [weak self] _ in
                
                self?.popViewController()
                
                }, isHighPriority: true)
        }
        
    }
    
    // MARK: - Navigation methods
    func popViewController() {
        router.popViewController()
    }
}
