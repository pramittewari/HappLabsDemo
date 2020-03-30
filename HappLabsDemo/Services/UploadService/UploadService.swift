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

protocol UploadUpdatesDelegate: class {
    
    func uploadBegan(forTotalSize totalSize: UInt64)
    func uploadProgressChanged(withUploadedBytes uploadedBytes: UInt64, totalSize: UInt64)
    func uploadEnded(withSuccess success: Bool, message: String?)
}

/// This service is responsible for all user related opertions like: - login, forgot password, view and edit profile
class UploadService {
    
    // MARK: - Variables
    
    private let networkSerivce: NetworkService
    private let userService: UserService
    private let notificationService: NotificationService

    private let authenticationExpiredCode: Int = -2
    private var uploadingFile: UploadingFile?
    weak var uploadUpdatesDelegate: UploadUpdatesDelegate?
    private var backgroundTaskID: UIBackgroundTaskIdentifier = .invalid
    
    var isUploadInProgress: Bool {
        return uploadingFile != nil
    }
    
    // MARK: - Life Cycle Methods
    
    init(networkSerivce: NetworkService, userService: UserService, notificationService: NotificationService) {
        
        self.networkSerivce = networkSerivce
        self.userService = userService
        self.notificationService = notificationService
    }
    
    // MARK: - Upload related functions
    func beginUpload(fromFileURL fileURL: String) {
        
        // Perform the task on a background queue.
        // Request the task assertion and save the ID.
        self.backgroundTaskID = UIApplication.shared.beginBackgroundTask(withName: "Finish Upload Tasks") {
            // End the task if time expires.
            UIApplication.shared.endBackgroundTask(self.backgroundTaskID)
            self.backgroundTaskID = UIBackgroundTaskIdentifier.invalid
        }
        
        // Send the data synchronously.
        self.beginBackgroundUpload(fromFileURL: fileURL)
    }
    
    func updateUploadStatus() {
        
        var uploadedBytes = ((uploadingFile?.partNumber ?? 1) - 1) * maxChunkSize
        let totalSize = uploadingFile?.totalSize ?? maxChunkSize
        
        uploadedBytes = uploadedBytes > totalSize ? totalSize : uploadedBytes
        
        uploadUpdatesDelegate?.uploadProgressChanged(withUploadedBytes: uploadedBytes, totalSize: totalSize)
    }
    
    func stopUploading(withSuccess success: Bool, message: String?) {
        
        // End the task assertion.
        UIApplication.shared.endBackgroundTask(self.backgroundTaskID)
        self.backgroundTaskID = UIBackgroundTaskIdentifier.invalid

        uploadingFile?.clearData()
        uploadingFile = nil
        uploadUpdatesDelegate?.uploadEnded(withSuccess: success, message: message)
    }
    
    // MARK: - API Methods
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
    
    func beginBackgroundUpload(fromFileURL fileURL: String) {
    
        uploadingFile = UploadingFile(withFileURL: fileURL)
        
        uploadUpdatesDelegate?.uploadBegan(forTotalSize: uploadingFile?.totalSize ?? 0)
        
        guard let name = uploadingFile?.fileName else {
            // Break upload with error
            stopUploading(withSuccess: false, message: "Failed to retrive file name!")
            return
        }
        
        let parameters: [String: Any] = [
            "file_name": name,
            "part_number": uploadingFile?.partNumber ?? 1
        ]
        networkSerivce.request(parameters: parameters, apiPath: APIList.UploadManagement.upload, httpMethod: .post, success: { [weak self] (_, response, message) in
            
            let jsonResponse = JSON(response)
            
            if let url = jsonResponse["url"].string,
                let uploadId = jsonResponse["upload_id"].string,
                let fileHexName = jsonResponse["file_name_hex"].string {
                
                self?.uploadingFile?.updateAfterUpload(fileNameHex: fileHexName, uploadId: uploadId)
                self?.uploadChunkToAWS(withURL: url)
                
            } else {
                
                self?.stopUploading(withSuccess: false, message: jsonResponse["message"].string ?? "Failed to upload!")
                
            }
            
        }, failure: { [weak self] (_, error) in
            
            self?.stopUploading(withSuccess: false, message: error?.localizedDescription ?? "Failed to upload!")
        })
        
    }
    
    func continueUpload() {
        
        let parameters: [String: Any] = [
            "file_name": uploadingFile?.fileName ?? "",
            "part_number": uploadingFile?.partNumber ?? 1,
            "file_name_hex": uploadingFile?.fileNameHex ?? "",
            "upload_id": uploadingFile?.uploadId ?? ""
        ]
        
        networkSerivce.request(parameters: parameters, apiPath: APIList.UploadManagement.upload, httpMethod: .post, success: { [weak self] (_, response, message) in
            
            let jsonResponse = JSON(response)
            
            if let url = jsonResponse["url"].string,
                let uploadId = jsonResponse["upload_id"].string,
                let fileHexName = jsonResponse["file_name_hex"].string {
                
                self?.uploadingFile?.updateAfterUpload(fileNameHex: fileHexName, uploadId: uploadId)
                self?.uploadChunkToAWS(withURL: url)
                
            } else {
                
                self?.stopUploading(withSuccess: false, message: jsonResponse["message"].string ?? "Failed to upload!")
                
            }
            
        }, failure: { [weak self] (_, error) in
            self?.stopUploading(withSuccess: false, message: error?.localizedDescription ?? "Failed to upload!")
        })
    }
    
    func completeUpload() {
        
        let parameters: [String: Any] = [
            "chunk_details": uploadingFile?.eTags ?? [],
            "upload_id": uploadingFile?.uploadId ?? "",
            "file_name_hex": uploadingFile?.fileNameHex ?? "",
            "file_size": uploadingFile?.totalSize ?? 0,
            "file_name": uploadingFile?.fileName ?? ""
        ]
        
        networkSerivce.request(parameters: parameters, apiPath: APIList.UploadManagement.completeUpload, httpMethod: .post, success: { [weak self] (_, response, message) in
            
            let jsonResponse = JSON(response)
            let basicResponse = BasicResponse(jsonResponse: jsonResponse)
            
            guard basicResponse.success else {
                self?.stopUploading(withSuccess: false, message: jsonResponse["message"].string ?? "Failed to complete!")
                return
            }
            
            self?.stopUploading(withSuccess: true, message: "Upload successful!")
            
        }, failure: { [weak self] (_, error) in
            
            self?.stopUploading(withSuccess: false, message: error?.localizedDescription ?? "Failed to upload!")
        })
    }
    
    func uploadChunkToAWS(withURL url: String) {
        
        guard let chunkData = uploadingFile?.getNextDataChunk() else {
            // Handle empty data
            stopUploading(withSuccess: false, message: "Could not read data!")
            return
        }
        
        networkSerivce.uploadChunkToAWS(withURL: url, chunkData: chunkData, success: { [weak self] (statusCode, eTag)  in
            
            guard statusCode == 200 else {
                self?.stopUploading(withSuccess: false, message: "Failed to upload to AWS!")
                return
            }
            
            self?.uploadingFile?.collectETag(withValue: eTag)
            self?.updateUploadStatus()
            if self?.uploadingFile?.hasUploadedAllChunks ?? true {
                self?.completeUpload()
            } else {
                self?.continueUpload()
            }
            
        }, failure: { [weak self] (_, error) in
            self?.stopUploading(withSuccess: false, message: error?.localizedDescription ?? "Failed to upload to AWS!")
        })
    }
}
