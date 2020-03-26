//
//  NotificationService.swift
//  HappLabsDemo
//
//  Created by Pramit on 23/03/20.
//  Copyright © 2020 Pramit Tewari. All rights reserved.
//

import UIKit
import UserNotifications
import CocoaLumberjack

///
class NotificationService: NSObject {
    
    // MARK: - Variable
    
    ///
    private var launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ///
    private var router: MainRouter?
    ///
    private let center = UNUserNotificationCenter.current()
    ///
    private var window: UIWindow? {
        return (UIApplication.shared.delegate as? AppDelegate)?.window
    }
    ///
    private var rootViewController: UIViewController? {
        return window?.rootViewController
    }
    
    /// Handles all delegate related to UIApplication or Appdelegate
    weak var applicationDelegate: ApplnDelegate?
    
    // MARK: - Life Cycle Methods
    
    ///
    convenience init(router: MainRouter?, launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        self.init()
        
        self.router = router
        self.launchOptions = launchOptions
        // this delegate should be assigned here
        UNUserNotificationCenter.current().delegate = self
        //
        self.checkIfNotificationAndSetBadgeCount()
    }
    
    /// Notification Configuration
    func notificationConfiguration() {
        // Assign delegate
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        appDelegate?.delegate = self
        
        // Ask for permission
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound], completionHandler: { [weak self](granted, error) in
            if granted {
                DDLogVerbose("Notification permission granted")
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            } else {
                DDLogError(error?.localizedDescription ?? "Notification permission denied")
                self?.showAlert(message: "Please allow notification permission to Bawsala", buttonTitles: ["Settings", "Cancel"], customAlertViewTapButtonBlock: { (index) in
                    if index == 0 {
                        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                        UIApplication.shared.open( url, options: [:], completionHandler: nil)
                    }
                })
            }
        })
    }
    
    // MARK: - Local Notification
    
    /// Fire local notification
    ///
    /// - Parameters:
    ///   - notification: notification object
    ///   - inSeconds: duration after which notification needs to be fired where 1.0 seconds is default value
    ///   - identifier: Unique identifier for a particular notification
    ///   - shouldRepeat: whether the notification should repeat or not. defualt value will be *false*.
    ///   - completion: returns completion block
    func fireLocalNotification(notification: UNMutableNotificationContent, inSeconds: TimeInterval = 1.0, atDate: DateComponents?, identifier: String, shouldRepeat: Bool = false, completion: @escaping (_ Success: Bool) -> Void) {
        let trigger: UNNotificationTrigger
        if let atDate = atDate {
            trigger = UNCalendarNotificationTrigger(dateMatching: atDate, repeats: shouldRepeat)
        } else {
            trigger = UNTimeIntervalNotificationTrigger(timeInterval: inSeconds, repeats: shouldRepeat)
        }
        let request = UNNotificationRequest(identifier: identifier, content: notification, trigger: trigger)
        center.add(request) { (error) in
            if let error = error {
                DDLogError(error.localizedDescription)
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    // MARK: - Alert methods
    ///
    func showInternetAlert() {
        showOkAlert(message: "Please check you're internet connection")
    }
    
    ///
    func showOkAlert(message: String) {
        DispatchQueue.main.async {
            guard let topVC = UIApplication.getTopMostViewController() else { return }
            topVC.showOkAlert(message: message)
        }
    }
        
    ///
    func showAlert(forTitle title: String = "",
                   message: String,
                   buttonTitles: [String],
                   customAlertViewTapButtonBlock: ((Int) -> Void)?, isHighPriority: Bool = false) {
        DispatchQueue.main.async {
            guard let topVC = UIApplication.getTopMostViewController() else { return }
            topVC.showAlert(forTitle: title, message: message, buttonTitles: buttonTitles, customAlertViewTapButtonBlock: customAlertViewTapButtonBlock, isHighPriority: isHighPriority)
        }
    }
    
    /// Logout user when session is expired and show landing screen
    func showUserLogoutAlert() {
        showAlert(forTitle: "Session Expired", message: "Please relogin to continue.", buttonTitles: ["Okay"], customAlertViewTapButtonBlock: { [weak self]_ in
            self?.router?.presentSignInAsRoot()
            }, isHighPriority: true)
    }
    
    // MARK: - Notification Related Methods
    
    /// Method search for particular notification and return true/false value in completion handler
    ///
    /// - Parameters:
    ///   - identifier: Notification identifier
    ///   - completionHandler: returns completion handler with bool value
    func searchIfNotificationAlreadyScheduleFor(identifier: String, completionHandler: @escaping (Bool) -> Void) {
        
        center.getPendingNotificationRequests { (notifications) in
            print("Count: \(notifications.count)")
            for item in notifications where item.identifier == identifier {
                completionHandler(true)
                return
            }
            completionHandler(false)
        }
    }
    
    ///
    func checkIfNotificationAndSetBadgeCount() {
        center.getPendingNotificationRequests { (list) in
            DispatchQueue.main.async {
                UIApplication.shared.applicationIconBadgeNumber = list.count
            }
        }
    }
    
    /// Removes notification from notification stack
    ///
    /// - Parameter identifier: notification identifier that needs to be removed
    func removeNotifications(identifiers: [String]) {
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
    }
    
    ///
    func removeAllNotificaions() {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
}

// MARK: - Notification Delegate Methods

extension NotificationService: UNUserNotificationCenterDelegate {
    
    ///
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(.alert)
        guard let attachment = notification.request.content.attachments.first else {
            return
        }
        print(attachment)
    }
    
    ///
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
//        let application = UIApplication.shared
//        // Delivers a notification to an app running in the foreground.
//        switch response.notification.request.identifier {
//        default: print(response.notification.request.identifier)
//        }
        checkIfNotificationAndSetBadgeCount()
    }
}

///
extension NotificationService: ApplnDelegate {
    func didTapOnReceivedNotification(withData data: [AnyHashable: Any], application: UIApplication) {
        applicationDelegate?.didReceiveRemoteNotification(withData: data, application: application)
    }
    
    func firebaseDeviceToken(token: String) {
    }
    
    ///
    func fetchedApnsDeviceToken(value: String, errorMsg: String?) {
        guard errorMsg?.isEmpty ?? true else {
            print("Failed to fetch device token: - ", errorMsg ?? "")
            applicationDelegate?.fetchedApnsDeviceToken(value: "", errorMsg: errorMsg)
            return
        }
        print("APNs device token: \(value)")
        applicationDelegate?.fetchedApnsDeviceToken(value: value, errorMsg: errorMsg)
    }
    
    ///
    func didReceiveRemoteNotification(withData data: [AnyHashable: Any], application: UIApplication) {
        // Print notification payload data
        if let response = data["aps"] as? [AnyHashable: Any] {
            print("\n Push notifiation response: - \n", response)
        }
        applicationDelegate?.didReceiveRemoteNotification(withData: data, application: application)
    }
}
