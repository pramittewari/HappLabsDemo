//
//  Validator.swift
//  HappLabsDemo
//
//  Created by Pramit on 23/03/20.
//  Copyright © 2020 Pramit Tewari. All rights reserved.
//

import UIKit

///
enum CommonValidationType {
    ///
    case empty
    ///
    case minLength
    ///
    case maxLength
    ///
    case notValid
    ///
    case shouldContain
    ///
    case notMatched
    ///
    case none
}

///
class Validator: NSObject {

    // MARK: - Variables

    /// Email regex
    private static let emailRegEx = "[.0-9a-zA-Z_-]+@[0-9a-zA-Z.-]+\\.[a-zA-Z]{2,20}"

    // MARK: Password Variables
    /// Password regex 1 uppercase, 1 special character mandatory. Min length 6 and max 20
    private static let passwordRegEx = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[d$@$!%*?&#])[A-Za-z\\dd$@$!%*?&#]{6,}"//"^(?=.*[a-z])(?=.*[A-Z]).{6,20}$"
    /// Minimum length of password
    private static let passwordMinLength = 6
    /// Maximum length of password
    private static let passwordMaxLength = 20
    /// Number of maximum years or months
    static let maxYearsLength = 2
    
    // MARK: Passcode Variables
    /// Passcode regex
    private static let passcodeRegEx = "^[0-9]"
    /// Minimum length of password
    static let passcodeLength = 6

    // MARK: Name Variables
    /// Name regex
    private static let nameRegEx = "^[a-zA-Z][a-zA-Z]+$"
    /// Minimum length of name
    private static let nameMinLength = 1
    /// Maximum length of name
    private static let nameMaxLength = 50

    // MARK: Phone Variables
    /// Name regex
    private static let phoneRegEx = "^[0-9]{2,}"
    /// Minimum length of phone
    private static let phoneMinLength = 10
    /// Maximum length of phone
    private static let phoneMaxLength = 10

    // MARK: - Validation Methods

    /// Check if stringValue is valid or not for common use cases like:  empty string
    ///
    /// - Parameter stringValue: stringValue to be validated
    /// - Returns:
    ///    - isValid: true: correct stringValue false: incorrect stringValue
    ///    - message: error message
    ///    - type: error type
    static func validate(stringValue: String)  -> (isValid: Bool, message: String?, type: CommonValidationType) {

        // Check Empty
        if stringValue.isEmpty {
            return (false, String(format: ValidationMessages.Common.empty, stringValue), .empty)
        }
        // Success
        return (true, nil, .none)
    }

    /// Check if Email is valid or not
    ///
    /// - Parameter
    ///     - email: email to be validated
    /// - Returns:
    ///    - isValid: true: correct email false: incorrect email
    ///    - message: error message
    ///    - type: error type
    static func validate(email: String, customName: String = "Email") -> (isValid: Bool, message: String?, type: CommonValidationType) {

        // Check Empty
        if email.isEmpty {
            return (false, String(format: ValidationMessages.Email.empty, customName), .empty)
        }
        // Check Regex
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", Validator.emailRegEx)
        if !emailPredicate.evaluate(with: email) {
            return (false, String(format: ValidationMessages.Email.notValid, customName), .notValid)
        }
        // Success
        return (true, nil, .none)
    }

    /// Check if password is valid or not
    ///
    /// - Parameter
    ///    - password: password to be validated
    ///     - customPassword: Pass custom password like:- ConfirmPassword, OldPassword etc.
    /// - Returns:
    ///    - isValid: true:- correct password false:- incorrect password
    ///    - message: error message
    ///    - type: error type
    static func validate(password: String, customPassword: String = "Password") -> (isValid: Bool, message: String?, type: CommonValidationType) {
        
        // Check Regex
        let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", Validator.passwordRegEx)
        if password.isEmpty {
            return (false,
                    String(format: ValidationMessages.Password.empty, customPassword),
                    .empty)
        } else if password.count < Validator.passwordMinLength {
            return (false, String(format: ValidationMessages.Password.minLength, customPassword, Validator.passwordMinLength),
                    .minLength)
        } else if password.count > Validator.passwordMaxLength {
            return (false, String(format: ValidationMessages.Password.maxLength, customPassword, Validator.passwordMaxLength),
                    .maxLength)
        } else if !passwordPredicate.evaluate(with: password) {
            return (false, String(format: ValidationMessages.Password.shouldContain, customPassword), .shouldContain)
        }
        return (true, nil, .none)
    }

    /// Check if old and new password matches
    ///
    /// - Parameters:
    ///   - firstPassword: FirstPassword value
    ///   - secondPassword: SecondPassword value
    ///   - firstCustomPassword: Custom name for firstPassword
    ///   - secondCustomPassword: Custom name for secondPassword
    /// - Returns:
    ///    - isValid: true:- correct password false:- incorrect password
    ///    - message: error message
    ///    - type: error type
    static func validate(firstPassword: String, secondPassword: String, firstCustomPassword: String = "Old Password", secondCustomPassword: String = "New Password") -> (isValid: Bool, message: String?, type: CommonValidationType) {

        if firstPassword != secondPassword {
             return (false, String(format: ValidationMessages.Password.notMatch), .notMatched)
        }
        return (true, nil, .none)
    }

    /// Check if name is valid or not
    ///
    /// - Parameter
    ///     - name: name to be validated
    ///     - customName: Pass custom name like:- FirstName, MiddleName etc.
    /// - Returns:
    ///    - isValid: true:- correct name false:- incorrect name
    ///    - message: error message
    ///    - type: error type
    static func validate(name: String, customName: String = "Name") -> (isValid: Bool, message: String?, type: CommonValidationType) {

        // Check Empty
        if name.isEmpty {
            return (false, String(format: ValidationMessages.Name.empty, customName), .empty)
        } else if name.count < Validator.nameMinLength {
            return (false, String(format: ValidationMessages.Name.minLength, customName, nameMinLength), .minLength)
        } else if name.count > Validator.nameMaxLength {
            return (false, String(format: ValidationMessages.Name.maxLength, customName, nameMaxLength), .maxLength)
        }
        // Check Regex
        let namePredicate = NSPredicate(format: "SELF MATCHES %@", Validator.nameRegEx)
        if !namePredicate.evaluate(with: name) {
            return (false, String(format: ValidationMessages.Name.notValid, customName), .notValid)
        }
        // Success
        return (true, nil, .none)
    }
    
    static func validate(address: String, customName: String = "address") -> (isValid: Bool, message: String?, type: CommonValidationType) {

        // Check Empty
        if address.isEmpty {
            return (false, String(format: ValidationMessages.Common.empty, customName), .empty)
        }
        // Success
        return (true, nil, .none)
    }
    
    static func validate(businessName: String, customName: String = "business name") -> (isValid: Bool, message: String?, type: CommonValidationType) {

        // Check Empty
        if businessName.isEmpty {
            return (false, String(format: ValidationMessages.Common.empty, customName), .empty)
        }
        // Success
        return (true, nil, .none)
    }
    
    static func validate(businessNumber: String, customName: String = "business number") -> (isValid: Bool, message: String?, type: CommonValidationType) {

           // Check Empty
           if businessNumber.isEmpty {
               return (false, String(format: ValidationMessages.Common.empty, customName), .empty)
           }
           // Success
           return (true, nil, .none)
       }

    /// Check if phone is valid or not
    ///
    /// - Parameter phone: phone to be validated
    /// - Returns:
    ///    - isValid: true:- correct phone false:- incorrect phone
    ///    - message: error message
    ///    - type: error type
    static func validate(phone: String, customName: String = "Phone Number") -> (isValid: Bool, message: String?, type: CommonValidationType) {

        // Check Empty
        if phone.isEmpty {
            return (false, String(format: ValidationMessages.Phone.empty, customName), .empty)
        } else if phone.count < Validator.phoneMinLength {
            return (false, String(format: ValidationMessages.Phone.minLength, customName, Validator.phoneMinLength), .minLength)
        } else if phone.count > Validator.phoneMaxLength {
            return (false, String(format: ValidationMessages.Phone.maxLength, customName, Validator.phoneMaxLength), .maxLength)
        }
        // Check Regex
        let phonePredicate = NSPredicate(format: "SELF MATCHES %@", Validator.phoneRegEx)
        if !phonePredicate.evaluate(with: phone) {
            return (false, String(format: ValidationMessages.Phone.notValid, customName), .notValid)
        }
        // Success
        return (true, nil, .none)
    }
    
    /// Check if passcode is valid or not
    ///
    /// - Parameter
    ///    - passcode: passcode to be validated
    ///     - customPasscode: Pass custom password like:- ConfirmPasscode, OldPasscode etc.
    /// - Returns:
    ///    - isValid: true:- correct password false:- incorrect password
    ///    - message: error message
    ///    - type: error type
    static func validate(passcode: String, customPassword: String = "passcode") -> (isValid: Bool, message: String?, type: CommonValidationType) {
        
        // Check Regex
        let passcodePredicate = NSPredicate(format: "SELF MATCHES %@", Validator.passcodeRegEx)
        if passcode.isEmpty {
            return (false,
                    String(format: ValidationMessages.Passcode.empty, customPassword),
                    .empty)
        } else if passcode.count < Validator.passcodeLength {
            return (false, String(format: ValidationMessages.Passcode.length, customPassword, Validator.passcodeLength),
                    .minLength)
        } else if passcodePredicate.evaluate(with: passcode) {
            return (false, String(format: ValidationMessages.Passcode.shouldContain, customPassword), .shouldContain)
        }
        return (true, nil, .none)
    }
    
    /// Check if old and new passcode matches
    ///
    /// - Parameters:
    ///   - firstPassword: FirstPasscode value
    ///   - secondPassword: SecondPasscode value
    ///   - firstCustomPassword: Custom name for firstPasscode
    ///   - secondCustomPassword: Custom name for secondPasscode
    /// - Returns:
    ///    - isValid: true:- correct passcode false:- incorrect passcode
    ///    - message: error message
    ///    - type: error type
    static func validate(firstPasscode: String, secondPasscode: String, firstCustomPasscode: String = "Old Passcode", secondCustomPasscode: String = "New Passcode") -> (isValid: Bool, message: String?, type: CommonValidationType) {
        
        if firstPasscode != secondPasscode {
            return (false, String(format: ValidationMessages.Passcode.notMatch, secondCustomPasscode, firstCustomPasscode), .notMatched)
        }
        return (true, nil, .none)
    }
}
