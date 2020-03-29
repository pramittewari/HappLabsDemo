//
//  UploadedFile.swift
//  HappLabsDemo
//
//  Created by Pramit on 29/03/20.
//  Copyright © 2020 Pramit Tewari. All rights reserved.
//

import Foundation
import SwiftyJSON

///
class UploadedFile: NSObject {
    
    var name: String?
    var size: String?
    var userName: String?
    var creationDate: String?
    
    init(jsonResponse: JSON) {
        print(jsonResponse)

        name = jsonResponse["object_name"].string
        size = jsonResponse["object_size"].string
        userName = jsonResponse["uname"].string
        creationDate = jsonResponse["create_date"].string
    }
}
