//
//  UploadManagementRouter.swift
//  HappLabsDemo
//
//  Created by Pramit on 23/03/20.
//  Copyright © 2020 Pramit Tewari. All rights reserved.
//

import Foundation
import UIKit
import CocoaLumberjack

///
class UploadManagementRouter {
    
    // MARK: - Variables
    private weak var navigationController: UINavigationController?
    
    var mainRouter: MainRouter
    var launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    var window: UIWindow
    
    var userService: UserService
    var uploadService: UploadService
    
    // MARK: - Life cycle methods
    // MARK: - Life cycle methods
    init(router: MainRouter, launchOptions: [UIApplication.LaunchOptionsKey: Any]?, window: UIWindow, userService: UserService, uploadService: UploadService) {
        
        self.mainRouter = router
        self.launchOptions = launchOptions
        self.window = window
        
        self.userService = userService
        self.uploadService = uploadService
        
        self.navigationController = R.storyboard.uploadManagement.instantiateInitialViewController()
    }
    
    // MARK: - Assemble methods
    
    ///
    func assembleInitialScreen() -> UINavigationController {
        
        guard let nav = navigationController,
            let vc = nav.children.first as? ListUploadsViewController else {
                DDLogError("Unable to get ListUploadsViewController.")
                fatalError("Unable to get ListUploadsViewController.")
        }
        let interactor = ListUploadsInteractor(router: self, uploadService: uploadService)
        vc.interactor = interactor
        interactor.view = vc
        return nav
    }
    
    // Navgation Methods
    
    ///
    func presentUploadListingAsRoot() {
        
        let vc = assembleInitialScreen()
        window.rootViewController = vc

    }
    
    ///
    func presentSignInScreen() {
        mainRouter.presentSignInScreen()
    }
}
