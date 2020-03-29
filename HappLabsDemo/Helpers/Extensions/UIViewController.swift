//
//  UIViewController+Extensions.swift
//  HappLabsDemo
//
//  Created by Pramit on 23/03/20.
//  Copyright © 2020 Pramit Tewari. All rights reserved.
//

import Foundation
import UIKit
import MBProgressHUD

/// View Controller Helpers
extension UIViewController {
    
    // MARK: - Alert Methods
    
    ///
    private func showAlert(forTitle title: String = "",
                           message: String,
                           actions: [UIAlertAction]) {
        
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: UIAlertController.Style.alert)
        
        actions.forEach { alertController.addAction($0) }
        
        alertController.modalPresentationStyle = .custom
        alertController.modalTransitionStyle = .crossDissolve
        present(alertController, animated: true, completion: nil)
    }
    
    /// Method to show native alert
    ///
    /// - Parameters:
    ///   - title: title of Alert
    ///   - message: description of the Alert
    ///   - buttonTitles: Array of buttons
    ///   - customAlertViewTapButtonBlock: returns completion handler
    ///   - isHighPriority: Its a unique parameter that dismiss any alert or view presenting
    ///     over the current view controller. Only to be used for high priority alerts.
    func showAlert(forTitle title: String = "",
                   message: String,
                   buttonTitles: [String],
                   customAlertViewTapButtonBlock: ((Int) -> Void)?, isHighPriority: Bool = false) {
        DispatchQueue.main.async { [weak self] in
            var actions = [UIAlertAction]()
            for buttonIndex in 0..<(buttonTitles.count) {
                let alertAction = UIAlertAction(title: buttonTitles[buttonIndex],
                                                style: UIAlertAction.Style.default,
                                                handler: { _ in
                                                    customAlertViewTapButtonBlock?(buttonIndex)
                })
                actions.append(alertAction)
            }
            if isHighPriority {
                guard let presentedVC = self?.presentedViewController else {
                    self?.showAlert(forTitle: title, message: message, actions: actions)
                    return
                }
                presentedVC.dismiss(animated: true, completion: {
                    self?.showAlert(forTitle: title, message: message, actions: actions)
                })
            } else {
                self?.showAlert(forTitle: title, message: message, actions: actions)
            }
        }
    }
        
    /**
     Call to show an alert with a single OK button and no action blocks attached.
     
     - parameter message: The message to be shown in the alert dialog
     */
    func showOkAlert(message: String) {
        
        showAlert(message: message,
                  buttonTitles: ["Okay"],
                  customAlertViewTapButtonBlock: nil)
    }
    
    func showSettingsAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        if
            let settings = URL(string: UIApplication.openSettingsURLString),
            UIApplication.shared.canOpenURL(settings) {
            alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { _ in
                UIApplication.shared.open(settings)
            })
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in })
        present(alert, animated: true)
    }

    /// Called to show loader
    /// - Parameters:
    ///   - title: Title to be displayed while loader is being animated
    ///   - view: View on which the loader is to be displayed
    func showProgressHudView(title: String = "", view: UIView? = nil) {
        
        hideProgressHudView()
        
        DispatchQueue.main.async(execute: {[weak self] in
        
            let hud = MBProgressHUD.showAdded(to: view ?? self?.view ?? UIView(), animated: true)
            hud.contentColor = UIColor.gray
            hud.bezelView.alpha = 1.0
            hud.bezelView.color = UIColor.white
            hud.bezelView.style = .solidColor
            hud.backgroundView.style = .solidColor
            hud.label.text = title
        })
    }
    
    /// Called to hide the loader
    /// - Parameter view: View on which loader is being shown
    func hideProgressHudView(view: UIView? = nil) {
        
        DispatchQueue.main.async(execute: {[weak self] in
        
            MBProgressHUD.hide(for: view ?? self?.view ?? UIView(), animated: true)
        })
    }
}
