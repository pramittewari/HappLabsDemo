//
//  ValidationMessages.swift
//  HappLabsDemo
//
//  Created by Pramit on 23/03/20.
//  Copyright © 2020 Pramit Tewari. All rights reserved.
//

import UIKit

///
struct ValidationMessages {

    ///
    struct Common {
        static let empty = "Please enter %@"
    }

    ///
    struct Email {
        static let empty = "Please enter %@"
        static let notValid = "Please enter valid %@"
    }

    ///
    struct Password {
        static let empty = "Please enter %@"
        static let length = "%@ should be of %d digits"
        static let minLength = "%@ should be minimum %d in length"
        static let maxLength = "%@ should be maximum %d in length"
        static let shouldContain = "%@ should contain at least one uppercase letter, one lowercase letter, one special character and one number"
        static let notMatch = "Passwords should match each other."
    }
    
    ///
    struct Passcode {
        static let empty = "Please enter %@"
        static let length = "%@ should be %d digits long"
        static let shouldContain = "%@ should be numeric"
        static let notMatch = "%@ should be same as %@"
    }
    
    ///
    struct Name {
        static let empty = "Please enter %@"
        static let notValid = "Please enter valid %@"
        static let minLength = "%@ should be minimum %d in length"
        static let maxLength = "%@ should be maximum %d in length"
    }

    ///
    struct Phone {
        static let empty = "Please enter %@"
        static let notValid = "Please enter valid %@"
        static let minLength = "%@ should be minimum %d in length"
        static let maxLength = "%@ should be maximum %d in length"
    }
    
    ///
    struct Username {
        static let empty = "Please enter a username"
    }
}
