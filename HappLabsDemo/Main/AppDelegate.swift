//
//  AppDelegate.swift
//  HappLabsDemo
//
//  Created by Pramit on 23/03/20.
//  Copyright © 2020 Pramit Tewari. All rights reserved.
//

import UIKit
import CocoaLumberjack

/// Logs for CocoaLumberjack
let defaultDebugLevel = DDLogLevel.all
///
protocol ApplnDelegate: class {

    /// Used to return device token value
    func fetchedApnsDeviceToken(value: String, errorMsg: String?)

    /// Used to handle remote notification data
    func didReceiveRemoteNotification(withData data: [AnyHashable: Any], application: UIApplication)
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    /// The window for this application
    var window: UIWindow?

    /// The file logger used by CocoaLumberjack
    var fileLogger: DDFileLogger?

    /// Entery point of architecture
    var mainRouter: MainRouter?

    /// Don't assign value to this delegate. It's used in NotificationService.swift. You can use the delegate in that class.
    weak var delegate: ApplnDelegate?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // Configure Logger
        configureLogger()
        
        // MainRouter is the entry point. Override point for customization after application launch.
        guard let window = window else { return true }
        mainRouter = MainRouter(window: window, launchOptions: launchOptions)
        mainRouter?.setInitialViewController()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
    }

    func applicationWillTerminate(_ application: UIApplication) {
    }

    // MARK: - Registering notification methods

    ///
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {

        // Convert token to string
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        // Print it to console
        delegate?.fetchedApnsDeviceToken(value: deviceTokenString, errorMsg: nil)
    }

    ///
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {

        print("APNs registration failed: \(error)")
        delegate?.fetchedApnsDeviceToken(value: "", errorMsg: error.localizedDescription)
    }
    
    // MARK: - Receiving notification methods

    ///
    func application(_ application: UIApplication, didReceiveRemoteNotification data: [AnyHashable: Any]) {
        delegate?.didReceiveRemoteNotification(withData: data, application: application)
    }
    
    // MARK: - Helpers
    
    /// Call to configure the logging for this application
    func configureLogger() {

        // Create a File Logger
        let logger = DDFileLogger()
        logger.rollingFrequency = TimeInterval(60 * 60 * 24)  // 24 hours in seconds
        logger.logFileManager.maximumNumberOfLogFiles = 7
        DDLog.add(logger, with: .info)
        fileLogger = logger
        #if DEBUG
        if let sharedLogger = DDTTYLogger.sharedInstance {
            DDLog.add(sharedLogger) // TTY = Xcode console
        }
        #else
        DDLog.add(DDASLLogger.sharedInstance, with: .error) // ASL = Apple System Logs
        #endif
    }

        func configNavigationBar() {
            
    //        UINavigationBar.appearance().backgroundColor = UIColor(named: "OrangeColor")
    //        UIBarButtonItem.appearance().tintColor = UIColor.white
    //        UINavigationBar.appearance().barTintColor = UIColor(named: "OrangeColor")
            UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(UIOffset(horizontal: -1000.0, vertical: 0.0), for: .default)
        }

}

///
extension UIApplication {

    /// Gets the top most VC from the base.
    class func getTopMostViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return getTopMostViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return getTopMostViewController(base: selected)
            }
        }
        if let presented = base?.presentedViewController {
            return getTopMostViewController(base: presented)
        }
        return base
    }
}
