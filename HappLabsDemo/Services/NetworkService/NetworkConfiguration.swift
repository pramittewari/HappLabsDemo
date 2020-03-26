//
//  NetworkConfiguration.swift
//  HappLabsDemo
//
//  Created by Pramit on 23/03/20.
//  Copyright © 2020 Pramit Tewari. All rights reserved.
//
import UIKit
///
class NetworkConfiguration: NSObject {
    
    // MARK: - Variables
    
    /// Time Interval in second for request time out
    static let timeoutIntervalForRequest = 90.0
    
    /// Time Interval in second for resource time out
    static let timeoutIntervalForResource = 90.0
    
    ///
    // static let currentVersion = "v1"
    ///
    static var baseURL: String = "http://sfs.dev.venktesh.happlabs.in/dev"

    ///
    static func configureNetwork(buildEnvironment: BuildEnvironment) {
        switch buildEnvironment {
            
        case .local:
            
            baseURL = "http://sfs.dev.venktesh.happlabs.in/dev"

        case .development:
            
            baseURL = "http://sfs.dev.venktesh.happlabs.in/dev"

        case .live:
            
            baseURL = "http://sfs.dev.venktesh.happlabs.in/dev"

        }
    }
}
