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
    
    var id: Int?
    var lastLogin: String?
    var lastName: String?
    var sessionKey: String?
    var name: String?
    var email: String?
    var phone: String?
    var firstName: String?
    
    private enum CodingKeys: String, CodingKey {
        
        case id = "user_id"
        case lastLogin = "last_login"
        case lastName = "last_name"
        case sessionKey = "session_key"
        case name
        case email = "user_email"
        case phone
        case firstName = "first_name"
    }
    
    func updateValues(fromResponse response: [String: Any]) {
        let json = JSON(response)
        id = json[CodingKeys.id.rawValue].intValue
        
        if id == nil {
            id = json["id"].intValue
        }
        
        let idString = json["id"].string
        if id == 0 {
            id = Int(idString ?? "0")
        }
        lastLogin = json[CodingKeys.lastLogin.rawValue].string
        lastName = json[CodingKeys.lastName.rawValue].string
        sessionKey = json[CodingKeys.sessionKey.rawValue].string
        name = json[CodingKeys.name.rawValue].string
        email = json[CodingKeys.email.rawValue].string
        phone = json[CodingKeys.phone.rawValue].string
        firstName = json[CodingKeys.firstName.rawValue].string
    }
}
