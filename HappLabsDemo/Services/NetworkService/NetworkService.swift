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
    private var authenticationToken: String?
    
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
    func update(authenticationToken: String) {
        self.authenticationToken = authenticationToken
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
    func request(parameters: Parameters?, headerParameter: HTTPHeaders? = nil, serverUrl: String = NetworkConfiguration.baseURL, apiPath: String, httpMethod: HTTPMethod, queue: DispatchQueue? = nil, success: @escaping(_ statusCode: Int, _ response: [String: Any], _ authorisationToken: String?) -> Void, failure: @escaping(_ statusCode: Int, _ error: Error?) -> Void) {
        
        setAlamofireDefaultConfiguration()
        // Set path
        var completeURL = serverUrl + apiPath
        
        // Add parameters to URL if request is .GET and clear passing parameters for the get request
        var passingParameters = parameters
        if httpMethod == .get, let value = passingParameters?.values.first as? String {
            completeURL += "/" + value
            passingParameters = nil
        }

        // Set header
        let headerParam = headerParameter == nil ? [
            "Content-Type": "application/json",
            "Authorization": authenticationToken ?? ""] :
        headerParameter
        
        AF.request(completeURL, method: httpMethod, parameters: passingParameters, encoding: JSONEncoding.default, headers: headerParam).responseJSON(queue: queue ?? .main) { response in
            
            var authToken = ""
            if let headers = response.response?.allHeaderFields as? [String: String] {
                if let token = headers["Authorization"] {
                    authToken = token
                }
            }
            switch response.result {
            case .success:
                if let responseDict = response.value as? [String: Any] {
                    success(response.response?.statusCode ?? 200, responseDict, authToken)
                } else {
                    failure(response.response?.statusCode ?? 404, response.error)
                }
            case .failure:
                failure(response.response?.statusCode ?? 404, response.error)
            }
        }
    }
    
    func uploadChunkToAWS(withURL url: String, chunkData: Data, success: @escaping(_ statusCode: Int, _ eTag: String?) -> Void, failure: @escaping(_ statusCode: Int, _ error: Error?) -> Void) {
                        
        let dataResponseSerializer = DataResponseSerializer(emptyResponseCodes: [200, 204, 205]) // Default is [204, 205]
        AF.upload(chunkData, to: url, method: .put, headers: nil).response(responseSerializer: dataResponseSerializer) { (response) in
            
            switch response.result {
            case .success:
                
                if (response.response?.statusCode ?? 400) == 200 {
                    
                    var eTag = ""
                    if let headers = response.response?.allHeaderFields as? [String: String] {
                        if let tag = headers["ETag"] {
                            eTag = tag
                        }
                        success(response.response?.statusCode ?? 200, eTag)
                    } else {
                        failure(response.response?.statusCode ?? 200, response.error)
                    }
                    
                } else {
                    failure(response.response?.statusCode ?? 404, response.error)
                }
            case .failure:
                failure(response.response?.statusCode ?? 404, response.error)
            }
        }
    }
}
