//
//  AppDelegate.swift
//  fcm-channel-ios
//
//  Created by rubenspessoa on 09/22/2017.
//  Copyright (c) 2017 rubenspessoa. All rights reserved.
//

import UIKit
import Firebase
import UserNotifications
import FBSDKLoginKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        requestPermissionForPushNotification(application)
        FCMChannelManager.setup()

        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.backgroundColor = UIColor.white
        self.window?.rootViewController = LoginViewController()
        self.window?.makeKeyAndVisible()

        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func requestPermissionForPushNotification(_ application:UIApplication) {
        
        if #available(iOS 10.0, *) {
            let center  = UNUserNotificationCenter.current()
            center.delegate = self
            center.requestAuthorization(options: [.sound,.alert,.badge], completionHandler: { (success, error) in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    print("success: \(success)")
                    DispatchQueue.main.async {
                        application.registerForRemoteNotifications()
                    }
                }
            })
        } else {
            let types:UIUserNotificationType = ([.alert, .badge, .sound])
            let settings:UIUserNotificationSettings = UIUserNotificationSettings(types: types, categories: nil)
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    //MARK: Application Methods
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        //Enter on touch notification
        let userInfo = response.notification.request.content.userInfo
        
        if let _ = User.activeUser() {
            openNotification(userInfo)
        }
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        if User.activeUser() != nil {
            openNotification(userInfo)
        }
    }
    
    func openNotification(_ userInfo: [AnyHashable: Any]) {
        var notificationType: String? = nil

        if let type = userInfo["type"] as? String {
            notificationType = type
        } else if let type = userInfo["gcm.notification.type"] as? String {
            notificationType = type
        }

        guard let type = notificationType else {
            return
        }

        switch type {
        case "rapidpro":
            let application = UIApplication.shared
            if application.applicationState != .active {
                application.applicationIconBadgeNumber = 1
            }
            NotificationCenter.default.post(name: Notification.Name(rawValue: "newMessageReceived"), object: userInfo)
        default:
            break
        }
    }
}

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token was refreshed: \(fcmToken)")
        FCMChannelManager.saveFCMToken(fcmToken: fcmToken)
    }
}

