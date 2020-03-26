//
//  UploadService.swift
//  HappLabsDemo
//
//  Created by Pramit on 23/03/20.
//  Copyright © 2020 Pramit Tewari. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import CocoaLumberjack

/// This service is responsible for all user related opertions like: - login, forgot password, view and edit profile
class UploadService {
    
    // MARK: - Variables
    
    ///
    private let networkSerivce: NetworkService
    ///
    private let userService: UserService

    // MARK: - Life Cycle Methods
    
    ///
    init(networkSerivce: NetworkService, userService: UserService) {
        
        self.networkSerivce = networkSerivce
        self.userService = userService
    }
    
    ///
    func fetchUploadedFiles(withParameters parameters: [String: Any], completionHandler: @escaping ((_ statusCode: Int, _ isSuccess: Bool, _ uploadedFiles: [String]?, _ error: String?) -> Void)) {
        
        networkSerivce.request(parameters: parameters, serverUrl: NetworkConfiguration.baseURL, apiPath: APIList.UploadManagement.fetchUploads, httpMethod: .post, success: { (statusCode, response) in
            
            let jsonResponse = JSON(response)
            let basicResponse = BasicResponse(jsonResponse: jsonResponse)
            
            if basicResponse.success, let data = response["data"] {
                
                print(data)
                
                completionHandler(statusCode, true, [], nil)
                
            } else {
                completionHandler(statusCode, false, nil, basicResponse.message)
            }
            
        }, failure: { (statusCode, error) in
            print(error?.localizedDescription ?? "SOMETHING_WENT_WRONG")
            completionHandler(statusCode, false, nil, error?.localizedDescription)
        })
    }
    
    func beginUpload(fromFileURL fileURL: String, fileSize: Int, fileName: String) {
        
        let parameters: [String: Any] = [
            "file_name": fileName,
            "part_number": 1
        ]
        networkSerivce.fileUpload(withFileURL: fileURL, fileSize: fileSize, parameters: parameters, apiPath: APIList.UploadManagement.upload)
    }
}
