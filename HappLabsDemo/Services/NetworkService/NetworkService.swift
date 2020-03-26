//
//  NetworkService.swift
//  HappLabsDemo
//
//  Created by Pramit on 23/03/20.
//  Copyright © 2020 Pramit Tewari. All rights reserved.
//
import UIKit
import Alamofire
import Reachability
import CocoaLumberjack
import SwiftyJSON

///
class NetworkService {
    
    // MARK: - Variables
    
    ///
    private var reachability: Reachability?
    ///
    private(set) var isReachable: Bool = false
    ///
    private let notificationService: NotificationService
    ///
    private var sessionKey: String?
    
    // MARK: - Life Cycle Methods
    
    ///
    init(buildEnvirnment: BuildEnvironment, notificationService: NotificationService) {
        
        self.notificationService = notificationService
        ///
        NetworkConfiguration.configureNetwork(buildEnvironment: .local)
        ///
        configureReachablity()
    }
    
    // MARK: - Configuration Methods

    ///
    func update(sessionKey: String) {
        self.sessionKey = sessionKey
    }

    ///
    @objc func reachabilityChanged(_ notification: Notification) {
        
        guard let reachability = notification.object as? Reachability, reachability.connection != .unavailable else {
           // DDLogError("Invalid Reachability notification type or connection is none.")
            isReachable = false
            // Show Internet alert/View
            notificationService.showInternetAlert()
            return
        }
        isReachable = true
            // DDLogVerbose("Reachable via \(reachability.connection)")
    }
    
    ///
    func configureReachablity() {
        //Reachability
        do {
            try  reachability = Reachability.init()
        } catch { print("cant access") }
        NotificationCenter.default.addObserver(self, selector: #selector(self.reachabilityChanged(_:)), name: Notification.Name.reachabilityChanged, object: reachability)
        do {
            try reachability?.startNotifier()
        } catch { print("cant access") }
    }
    
    // MARK: - Alamofire Configuration
    
    ///
    func setAlamofireDefaultConfiguration() {
        
        Alamofire.Session.default.session.configuration.timeoutIntervalForRequest = NetworkConfiguration.timeoutIntervalForRequest
        Alamofire.Session.default.session.configuration.timeoutIntervalForResource = NetworkConfiguration.timeoutIntervalForResource
    }
    
    /// Custom API Calling methods. We can call any rest API With this common API calling method.
    ///
    /// - Parameters:
    ///   - path: API path
    ///   - ver: firmware version
    ///   - httpMethod: http Method.
    ///   - queue: queue object.
    ///   - success: success block.
    ///   - failure: failure block.
    /// - Returns: request object
    @discardableResult func request(parameters: Parameters?, headerParameter: HTTPHeaders? = nil, serverUrl: String = NetworkConfiguration.baseURL, apiPath: String, httpMethod: HTTPMethod, queue: DispatchQueue? = nil, success:@escaping(_ statusCode: Int, _ response: [String: Any]) -> Void, failure:@escaping(_ statusCode: Int, _ error: Error?) -> Void) -> DataRequest {
        
        setAlamofireDefaultConfiguration()
        // Set path
        var completeURL = serverUrl + apiPath
        
        // Add parameters to URL if request is get and clear passing parameters for the get request
        var passingParameters = parameters
        if httpMethod == .get, let value = passingParameters?.values.first as? String {
            completeURL += "/" + value
            passingParameters = nil
        }
        // application/x-www-form-urlencoded
        // Set header
        let headerParam = headerParameter == nil ? ["Content-Type": "application/json", "authorization": ""] : headerParameter
        
        let request = AF.request(completeURL, method: httpMethod, parameters: passingParameters, encoding: JSONEncoding.default, headers: headerParam).responseJSON(queue: queue ?? .main) { response in
            if let headers = response.response?.allHeaderFields as? [String: String] {
                if let header = headers["x-access-token"] { print(header) }
            }
            switch response.result {
            case .success:
                //let jsonResponse = JSON(response.result.value ?? [String: Any]())
                if let responseDict = response.value as? [String: Any] {
                    success(response.response?.statusCode ?? 200, responseDict)
                //    DDLogInfo("\((response.value ?? "success"))")
                } else if let responseArray = response.value as? [Any] {
                    // Handling scenario where array is sent is converted into a dictionary with response key
                    let responseDict = ["response": responseArray]
                    success(response.response?.statusCode ?? 200, responseDict)
                //    DDLogInfo("\((response.value ?? "success"))")
                } else {
                    failure(response.response?.statusCode ?? 200, response.error)
                 //   DDLogError("\((response.error?.localizedDescription ?? "failed"))")
                }
            case .failure:
                failure(response.response?.statusCode ?? 404, response.error)
             //   DDLogError("\((response.error?.localizedDescription ?? "error"))")
            }
        }
        return request
    }
    
    /// Custom Multipart API Calling methods. We can call any rest API With this common API calling method.
    ///
    /// - Parameters:
    ///   - path: API path
    ///   - ver: firmware version
    ///   - httpMethod: http Method.
    ///   - queue: queue object.
    ///   - success: success block.
    ///   - failure: failure block.
    func multipartRequest(parameter: Parameters?, imageData: Data?, imageParameterName: String?, headerParameter: HTTPHeaders? = nil, serverUrl: String = NetworkConfiguration.baseURL, apiPath: String, httpMethod: HTTPMethod, queue: DispatchQueue? = nil, success:@escaping(_ statusCode: Int, _ response: [String: Any]) -> Void, failure:@escaping(_ statusCode: Int, _ error: Error?) -> Void) {
        
        setAlamofireDefaultConfiguration()
        // Set path
        let completeURL = serverUrl + apiPath
        // Set header
        let headerParam = headerParameter == nil ? ["Content-type": "multipart/form-data"] : headerParameter
        if imageData != nil {
            AF.upload(multipartFormData: { (multipartFormData) in
                
                if let data = imageData {
                    let imageName = "\(Date())"
                    multipartFormData.append(data, withName: imageParameterName ?? "", fileName: imageName + ".jpeg", mimeType: "image/jpeg")
                }
                
                for (key, value) in (parameter ?? [:]) {
                    guard let data = "\(value)".data(using: String.Encoding.utf8) else { continue }
                    multipartFormData.append(data, withName: key as String)
                }
                
            }, to: completeURL, method: .post, headers: headerParam).responseJSON { (response) in
                switch response.result {
                    
                case .success(let upload):
                    if let responseDict = response.value as? [String: Any] {
                        success(response.response?.statusCode ?? 200, responseDict)
                    } else {
                        failure(response.response?.statusCode ?? 404, response.error)
                    }
                case .failure(let error):
                    failure(404, error)
                }
            }
        } else {
            request(parameters: parameter, apiPath: apiPath, httpMethod: httpMethod, success: success, failure: failure)
        }
    }
    
    func fileUpload(withFileURL fileURL: String, fileSize: Int, parameters: [String: Any], serverPath: String = NetworkConfiguration.baseURL, apiPath: String) {
        
        let completeURL = serverPath + apiPath
        
        let headers = [
            "Authorization": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6MTUxNywidW5hbWUiOiJwYW5rYWoiLCJlbWFpbCI6InRlc3Rmb3IxQG1haWxpbmF0b3IuY29tIiwidXNlcl90eXBlIjoiTk9STUFMX1VTRVIiLCJpYXQiOjE1ODUxMDkxNzYsImV4cCI6MTU4NTQ2OTE3Nn0.QQwDNV05FP3x15UcFJPMUMzd4561lydUEEk9PhD8kts",
            "Content-Type": "application/json"
        ]
        
        let httpHeaders = HTTPHeaders(headers)
                
        //let size = fileSize
        
        //guard let stream = InputStream(fileAtPath: fileURL) else { return }
        guard let url = URL(string: fileURL) else { return }
        do {
            let data = try Data(contentsOf: url)
            
            AF.upload(multipartFormData: { (multipartFormData) in
               
                //multipartFormData.append(stream, withLength: 5_000_000, headers: ["Content-Type": "multipart/form-data"])
                //multipartFormData.append(stream, withLength: UInt64(size), name: <#T##String#>, fileName: <#T##String#>, mimeType: <#T##String#>)
                multipartFormData.append(data.base64EncodedData(), withName: "fileName")
                for (key, value) in (parameters) {
                    guard let data = "\(value)".data(using: String.Encoding.utf8) else { continue }
                    multipartFormData.append(data, withName: key as String)
                }

            }, to: completeURL, usingThreshold: 5_000_000, method: .post, headers: httpHeaders, interceptor: nil, fileManager: .default)
            .uploadProgress { progress in
                print("Upload Progress: \(progress.fractionCompleted)")
            }
            .downloadProgress { progress in
                print("Download Progress: \(progress.fractionCompleted)")
            }
            .responseString { response in
                debugPrint(response)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}
