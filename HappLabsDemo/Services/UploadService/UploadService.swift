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
    ///
    private let notificationService: NotificationService
    ///
    private let authenticationExpiredCode: Int = -2
    // MARK: - Life Cycle Methods
    
    ///
    init(networkSerivce: NetworkService, userService: UserService, notificationService: NotificationService) {
        
        self.networkSerivce = networkSerivce
        self.userService = userService
        self.notificationService = notificationService
    }
    
    ///
    func fetchUploadedFiles(completionHandler: @escaping ((_ statusCode: Int, _ isSuccess: Bool, _ uploadedFiles: [UploadedFile]?, _ error: String?, _ requiresHandling: Bool) -> Void)) {
        
        networkSerivce.request(parameters: nil, serverUrl: NetworkConfiguration.baseURL, apiPath: APIList.UploadManagement.fetchUploads, httpMethod: .get, success: { [weak self] (statusCode, response, _)  in
            
            let jsonResponse = JSON(response)
            let basicResponse = BasicResponse(jsonResponse: jsonResponse)
            
            if basicResponse.success, let data = response["rval"] {
                
                let files = JSON(data).array ?? []
                var uploadedFiles: [UploadedFile] = []
                files.forEach { (file) in
                    uploadedFiles.append(UploadedFile(jsonResponse: file))
                }
                
                completionHandler(statusCode, true, uploadedFiles, nil, true)
                
            } else {
                
                guard let code = JSON(jsonResponse["rval"]).int,
                    let expirationCode = self?.authenticationExpiredCode,
                    code != expirationCode else {
                    // Handle expiration code
                    self?.notificationService.showUserLogoutAlert()
                    completionHandler(statusCode, false, nil, basicResponse.message, false)
                    return
                }
                completionHandler(statusCode, false, nil, basicResponse.message, true)
            }
            
        }, failure: { (statusCode, error) in
            print(error?.localizedDescription ?? "SOMETHING_WENT_WRONG")
            completionHandler(statusCode, false, nil, error?.localizedDescription, true)
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
