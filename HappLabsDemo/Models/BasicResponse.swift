//
//  BasicResponse.swift
//  HappLabsDemo
//
//  Created by Pramit on 25/03/20.
//  Copyright © 2020 Pramit Tewari. All rights reserved.
//

import UIKit
import SwiftyJSON

///
typealias BasicCompletion = ((_ statusCode: Int, _ isSuccess: Bool, _ error: String?) -> Void)

class MessageParseResponse: Codable {
    
    var field: String?
    var message: String?
    
    init(jsonResponse: [String: Any]) {
        field = jsonResponse["field"] as? String
        message = jsonResponse["message"] as? String
    }
}

///
class BasicResponse: NSObject {
    
    var success: Bool
    var message: String?
    
    init(jsonResponse: JSON) {

        success = jsonResponse["success"].bool ?? false
        message = jsonResponse["message"].string
    }
}
