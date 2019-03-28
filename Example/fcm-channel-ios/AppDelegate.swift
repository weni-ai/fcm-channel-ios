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

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
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
        var debugMode = true
        
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
        if let _ = User.activeUser() {
            openNotification(userInfo)
        }
    }
    
    func openNotification(_ userInfo:[AnyHashable:Any]) {
        
        var notificationType:String? = nil

        if let type = userInfo["type"] as? String {
            notificationType = type
        } else if let type = userInfo["gcm.notification.type"] as? String {
            notificationType = type
        }
//
//        if let notificationType = notificationType {
//            switch notificationType {
//            case URConstant.NotificationType.CHAT:
//                
//                if let chatRoomKey = getChatRoomKey(userInfo) {
//                    if UIApplication.shared.applicationState != UIApplicationState.active {
//                        URNavigationManager.setupNavigationControllerWithMainViewController(URMainViewController(chatRoomKey: chatRoomKey))
//                    }else{
//                        
//                        NotificationCenter.default.post(name: Notification.Name(rawValue: "newChatReceived"), object: userInfo)
//                        
//                        if let visibleViewController = URNavigationManager.navigation.visibleViewController {
//                            if !(visibleViewController is URMessagesViewController) {
//                                //                                AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
//                            }
//                        }
//                    }
//                }
//                
//                break
//            case URConstant.NotificationType.RAPIDPRO:
//                
//                if URRapidProManager.sendingAnswers {
//                    break
//                }
//                
//                URNavigationManager.setupNavigationControllerWithMainViewController(URMainViewController(viewControllerToShow: URClosedPollTableViewController()))
//                break
//            default:
//                break
//            }
//        }
    }
}

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        print("Firebase registration token was refreshed: \(fcmToken)")
        FCMChannelManager.saveFCMToken(fcmToken: fcmToken)
    }
}

