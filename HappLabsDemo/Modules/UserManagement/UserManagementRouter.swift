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
    
    ///
    func assembleInitialScreen() -> UINavigationController {
        
        guard let nav = navigationController,
            let vc = nav.children.first as? SignInViewController else {
                DDLogError("Unable to get SignInViewController.")
                fatalError("Unable to get SignInViewController.")
        }
        let interactor = SignInInteractor(router: self)
        vc.interactor = interactor
        interactor.view = vc
        return nav
    }
    
    // Navigation Methods
    
    ///
    func presentSignInAsRoot() {
        
        let vc = assembleInitialScreen()
        window.rootViewController = vc

    }
    
    ///
    func presentUploadListAsRoot() {
        let router = UploadManagementRouter(router: mainRouter, launchOptions: launchOptions, window: window, userService: userService, uploadService: uploadService)
        router.presentUploadListingAsRoot()
    }
}
