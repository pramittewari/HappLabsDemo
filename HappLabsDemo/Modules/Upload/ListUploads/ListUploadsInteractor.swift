//
//  ListUploadsInteractor.swift
//  HappLabsDemo
//
//  Created by Pramit on 24/03/20.
//  Copyright © 2020 Pramit Tewari. All rights reserved.
//

import UIKit
import Foundation
import CocoaLumberjack

class ListUploadsInteractor: Interacting {
    
    // MARK: - Variables
    private var router: UploadManagementRouter
    var view: ListUploadsViewController?
    var userService: UserService
    var uploadService: UploadService
    var uploadedFiles: [UploadedFile] = []
    
    var isUploadInProgress: Bool { return uploadService.isUploadInProgress }
    var isUserLoggedOut: Bool { return (userService.getUser()?.authenticationToken ?? "") == "" }
    
    // MARK: - Life cycle
    init (router: UploadManagementRouter, uploadService: UploadService, userService: UserService) {
        
        self.router = router
        self.uploadService = uploadService
        self.userService = userService
    }
    
    func viewWillAppear() {
        
        userService.loginDelegate = self
        uploadService.uploadUpdatesDelegate = view
    }
        
    // MARK: - API Methods
    func beginUpload(fromFileURL fileURL: String) {
        
        uploadService.beginUpload(fromFileURL: fileURL)
    }
    
    func fetchUploadedFiles() {
        
        view?.showProgressHudView()
        uploadService.fetchUploadedFiles { [weak self] (_, success, uploadedFiles, message, requiresHandling)  in
            
            let result = Array((uploadedFiles ?? []).reversed())
            self?.view?.hideProgressHudView()
            self?.uploadedFiles = result
            guard success else {
                // Handle error
                if requiresHandling {
                    self?.view?.showOkAlert(message: message ?? "Something went wrong")
                }
                self?.view?.setupTable(withFiles: result)
                return
            }
            self?.view?.setupTable(withFiles: result)
        }
    }
    
    // MARK: - Navigation Methods
    func logOutUser() {
        
        userService.deleteUser()
        presentSignInScreen()
    }
    
    func presentSignInScreen() {
        
        router.presentSignInScreen()
    }
}

// MARK: - Login delegates
extension ListUploadsInteractor: LoginDelegate {
    
    func userLoggedIn() {
        fetchUploadedFiles()
        view?.setButtonStates()
    }
    
}
