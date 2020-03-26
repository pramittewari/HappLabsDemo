//
//  APIList.swift
//  HappLabsDemo
//
//  Created by Pramit on 23/03/20.
//  Copyright © 2020 Pramit Tewari. All rights reserved.
//

import UIKit

///
enum BuildEnvironment: String {
    case local = "Local"
    case live = "Live"
    case development = "Development"
}

///
class APIList: NSObject {

    ///
    struct UserManagement {
        ///
        static let signIn = "/sign_in"
        ///
        static let signUp = "/sign_up"
    }

    ///
    struct UploadManagement {
        ///
        static let upload = "/upload"
        ///
        static let completeUpload = "/"
        ///
        static let fetchUploads = "/getData"
    }

}
