//
//  CreateUploadInteractor.swift
//  HappLabsDemo
//
//  Created by Pramit on 24/03/20.
//  Copyright © 2020 Pramit Tewari. All rights reserved.
//

import UIKit
import Foundation
import CocoaLumberjack

class CreateUploadInteractor: Interacting {
    
    private var router: UploadManagementRouter
    
    var view: CreateUploadViewController?
    
    init (router: UploadManagementRouter) {
        
        self.router = router
    }
        
}
