//
//  SignInViewController.swift
//  HappLabsDemo
//
//  Created by Pramit on 24/03/20.
//  Copyright © 2020 Pramit Tewari. All rights reserved.
//

import UIKit

class SignInViewController: BaseViewController<SignInInteractor> {

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func signInTapped(_ sender: UIButton) {
        
        interactor?.navigateToUploadListingScreen()
    }
}
