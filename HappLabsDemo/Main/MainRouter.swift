//
//  MainRouter.swift
//  HappLabsDemo
//
//  Created by Pramit on 20/02/20.
//  Copyright © 2020 Pramit Tewari. All rights reserved.
//

import Foundation
import UIKit

/// Implementation of MainRouting
final class MainRouter {

    // MARK: - Variables

    ///
    private let storageService: StorageService = StorageService()
    ///
    private lazy var notificationService: NotificationService = NotificationService(router: self, launchOptions: launchOptions)
    ///
    private lazy var networkService: NetworkService = NetworkService(buildEnvirnment: .development, notificationService: notificationService)
    ///
    private lazy var userService: UserService = UserService(networkSerivce: networkService, storageService: storageService)
    ///
    private lazy var uploadService: UploadService = UploadService(networkSerivce: networkService, userService: userService)

    ///
    private let launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ///
    private let window: UIWindow
    /// Root view controller of the app
    private var rootVC: UIViewController? {
        return window.rootViewController
    }

    // MARK: - Life Cycle Methods

    /**
     Initialize the router with required dependencies

     - parameter window: The root window of the application
     */
    init(window: UIWindow, launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {

        self.window = window
        self.launchOptions = launchOptions
    }

    // MARK: - Navigaiton methods

    /// Call to determine and present the root view for this application. Currently that will be either the tabBar or the initial onboarding slideshow.
    func setInitialViewController() {

        presentSignInAsRoot()
    }

    ///
    func presentSignInAsRoot() {
        
        let router = UserManagementRouter(router: self, launchOptions: launchOptions, window: window, userService: userService, uploadService: uploadService)
        router.presentSignInAsRoot()
    }
    
}
