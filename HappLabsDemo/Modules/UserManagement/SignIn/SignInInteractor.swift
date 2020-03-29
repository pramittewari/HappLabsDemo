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
    
    init (router: UserManagementRouter) {
        
        self.router = router
    }
        
    func navigateToSignUpScreen() {
        
        router.presentSignUpScreen()
    }
    
    func dismissSignInScreen() {
        
        router.dismissScreen()
    }
}
