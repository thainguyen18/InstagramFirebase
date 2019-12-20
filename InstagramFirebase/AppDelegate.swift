//
//  AppDelegate.swift
//  InstagramFirebase
//
//  Created by Thai Nguyen on 12/4/19.
//  Copyright © 2019 Thai Nguyen. All rights reserved.
//

import UIKit
import UserNotifications
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        FirebaseApp.configure()
        
        attemptToRegisterForNotifications(application)
        
        return true
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Registered with FCM with token:", fcmToken)
    }
    
    fileprivate func  attemptToRegisterForNotifications(_ application: UIApplication) {
        
        UNUserNotificationCenter.current().delegate = self
        
        Messaging.messaging().delegate = self
        
        // User authorization for notifications
        let options: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: options) { (granted, error) in
            if let err = error {
                print("Unable to obtain user authorization for notifications ", err)
                return
            }
            
            if granted {
                print("Granted")
                
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
                
            } else {
                print("Denied")
            }
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("Registered for remote notification with device token: ", deviceToken)
        
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        completionHandler([.alert, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        // Reset badge to 0
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        let userInfo = response.notification.request.content.userInfo
        
        if let followerId = userInfo["followerId"] as? String {
            
            // Create user profile controller with follower id
            let userProfileController = UserProfileController()
            userProfileController.userId = followerId
            
            // Access main UI from AppDelegate
            let window = UIApplication.shared.windows.filter{$0.isKeyWindow}.first
            if let mainTabBarController = window?.rootViewController as? MainTabBarController {
                mainTabBarController.selectedIndex = 0
                
                // Dismiss any view controller (Photo selector view controller) in motion
                mainTabBarController.presentedViewController?.dismiss(animated: true)
                
                if let homeNav = mainTabBarController.viewControllers?.first as? UINavigationController {
                    homeNav.pushViewController(userProfileController, animated: true)
                }
            }
        }
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

