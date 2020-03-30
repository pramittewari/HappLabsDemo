//
//  UserManagementRouter.swift
//  HappLabsDemo
//
//  Created by Pramit on 23/03/20.
//  Copyright © 2020 Pramit Tewari. All rights reserved.
//

import Foundation
import UIKit
import CocoaLumberjack

///
class UserManagementRouter {
    
    // MARK: - Variables
    private weak var navigationController: UINavigationController?
    
    var mainRouter: MainRouter
    var launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    var window: UIWindow
    
    private let userService: UserService
    private let uploadService: UploadService
    
    // MARK: - Life cycle methods
    init(router: MainRouter, launchOptions: [UIApplication.LaunchOptionsKey: Any]?, window: UIWindow, userService: UserService, uploadService: UploadService) {
        
        self.mainRouter = router
        self.launchOptions = launchOptions
        self.window = window
        
        self.userService = userService
        self.uploadService = uploadService
        
        self.navigationController = R.storyboard.userManagement.instantiateInitialViewController()
    }
    
    // MARK: - Assemble methods
    func assembleInitialScreen() -> UINavigationController {
        
        guard let nav = navigationController,
            let vc = nav.children.first as? SignInViewController else {
                DDLogError("Unable to get SignInViewController.")
                fatalError("Unable to get SignInViewController.")
        }
        
        let interactor = SignInInteractor(router: self, userService: userService)
        vc.interactor = interactor
        interactor.view = vc
        return nav
    }
    
    func assembleSignUpScreen() -> UIViewController {
        
        guard let vc = R.storyboard.userManagement.signUpViewController() else {
            DDLogError("Unable to get SignUpViewController.")
            fatalError("Unable to get SignUpViewController.")
        }
        
        let interactor = SignUpInteractor(router: self, userService: userService)
        vc.interactor = interactor
        interactor.view = vc
        return vc
    }
    
    // MARK: - Navigation Methods
    func presentSignUpScreen() {
        let vc = assembleSignUpScreen()
        navigationController?.pushViewController(vc, animated: true)
    }

    func dismissScreen() {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    func popViewController() {
        navigationController?.popViewController(animated: true)
    }
    
}
