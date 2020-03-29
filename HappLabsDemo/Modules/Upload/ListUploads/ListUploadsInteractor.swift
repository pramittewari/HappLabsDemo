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
    
    var uploadService: UploadService
    
    init (router: UploadManagementRouter, uploadService: UploadService) {
        
        self.router = router
        self.uploadService = uploadService
    }
        
    func beginUpload(fromFileURL fileURL: String, fileSize: Int, fileName: String) {
        uploadService.beginUpload(fromFileURL: fileURL, fileSize: fileSize, fileName: fileName)
    }
    
    func presentSignInScreen() {
        
        router.presentSignInScreen()
    }
}
