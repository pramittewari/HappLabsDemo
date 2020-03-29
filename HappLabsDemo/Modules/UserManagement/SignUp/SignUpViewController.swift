//
//  SignUpViewController.swift
//  HappLabsDemo
//
//  Created by Pramit on 24/03/20.
//  Copyright © 2020 Pramit Tewari. All rights reserved.
//

import UIKit

class SignUpViewController: BaseViewController<SignUpInteractor> {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    @IBAction func signUpTapped(_ sender: UIButton) {
        
    }
    
    @IBAction func navigateToSignInTapped(_ sender: UIButton) {
        
        interactor?.popViewController()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
}
