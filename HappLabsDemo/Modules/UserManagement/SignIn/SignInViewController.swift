//
//  SignInViewController.swift
//  HappLabsDemo
//
//  Created by Pramit on 24/03/20.
//  Copyright © 2020 Pramit Tewari. All rights reserved.
//

import UIKit

class SignInViewController: BaseViewController<SignInInteractor> {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    @IBAction func signInTapped(_ sender: UIButton) {
        
        interactor?.dismissSignInScreen()
    }

    @IBAction func navigateToSignUpTapped (_ sender: UIButton) {
    
        interactor?.navigateToSignUpScreen()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

}
