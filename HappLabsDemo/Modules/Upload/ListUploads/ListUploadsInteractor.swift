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
    
    private var router: UploadManagementRouter
    
    var view: ListUploadsViewController?
    
    var userService: UserService
    
    var uploadService: UploadService
    
    var uploadedFiles: [UploadedFile] = []
    
    init (router: UploadManagementRouter, uploadService: UploadService, userService: UserService) {
        
        self.router = router
        self.uploadService = uploadService
        self.userService = userService
    }
    
    func viewWillAppear() {
        
        userService.loginDelegate = self
    }
        
    func beginUpload(fromFileURL fileURL: String, fileSize: Int, fileName: String) {
        
        uploadService.beginUpload(fromFileURL: fileURL, fileSize: fileSize, fileName: fileName)
    }
    
    func fetchUploadedFiles() {
        
        view?.showProgressHudView()
        uploadService.fetchUploadedFiles { [weak self] (_, success, uploadedFiles, message, requiresHandling)  in
            
            self?.view?.hideProgressHudView()
            self?.uploadedFiles = uploadedFiles ?? []
            guard success else {
                // Handle error
                if requiresHandling {
                    self?.view?.showOkAlert(message: message ?? "Something went wrong")
                }
                self?.view?.setupView(withFiles: uploadedFiles ?? [])
                return
            }
            self?.view?.setupView(withFiles: uploadedFiles ?? [])
        }
    }
    
    func logOutUser() {
        
        userService.deleteUser()
        presentSignInScreen()
    }
    
    func presentSignInScreen() {
        
        router.presentSignInScreen()
    }
}

extension ListUploadsInteractor: LoginDelegate {
    
    func userLoggedIn() {
        fetchUploadedFiles()
    }
    
}
