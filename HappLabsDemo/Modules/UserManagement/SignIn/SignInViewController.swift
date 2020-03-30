//
//  SignInViewController.swift
//  HappLabsDemo
//
//  Created by Pramit on 24/03/20.
//  Copyright © 2020 Pramit Tewari. All rights reserved.
//

import UIKit

class SignInViewController: BaseViewController<SignInInteractor> {
    
    // MARK: - Outlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    // MARK: - Actions
    @IBAction func signInTapped(_ sender: UIButton) {
        
        interactor?.signInUser(email: emailTextField.text, password: passwordTextField.text)
    }

    @IBAction func navigateToSignUpTapped (_ sender: UIButton) {
    
        interactor?.navigateToSignUpScreen()
    }
    
    // MARK: - Life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()

    }

}
