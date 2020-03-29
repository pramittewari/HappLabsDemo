//
//  User.swift
//  HappLabsDemo
//
//  Created by Pramit on 25/03/20.
//  Copyright © 2020 Pramit Tewari. All rights reserved.
//

import UIKit
import SwiftyJSON

class LoginCredentials: Codable {
    
    var email: String?
    var password: String?
}

class User: Codable {
    
    var userName: String?
    var email: String?
    var password: String?
    var authenticationToken: String?
    
    private enum CodingKeys: String, CodingKey {
        
        case userName = "user_name"
        case email
        case password
    }
    
    func updateValues(fromResponse response: JSON) {
                
        userName = response[CodingKeys.userName.rawValue].string
        email = response[CodingKeys.email.rawValue].string
        password = response[CodingKeys.password.rawValue].string
        
    }
}
