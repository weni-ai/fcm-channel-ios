//
//  LoginViewModel.swift
//  fcm-channel-ios
//
//  Created by Rubens Pessoa on 26/09/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
import FBSDKCoreKit
import FBSDKLoginKit
import FirebaseAuth

class LoginViewModel {
    
    static let shared = LoginViewModel()
    
    func facebookLogin(from: UIViewController, completion: @escaping (_ user: Bool, _ error: Error?) -> Void) {
        let fbLoginManager = FBSDKLoginManager()
        fbLoginManager.logOut()
        fbLoginManager.logIn(withReadPermissions: ["public_profile", "email"], from: from) {
            (result, error) in

            if let error = error {
                print("Failed to login on Facebook: \(error.localizedDescription)")
                completion(false, error)
            }

            guard let accessToken = FBSDKAccessToken.current() else {
                print("Failed to get access token")
                completion(false, nil)
                return
            }

            let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)

            // Perform login by calling Firebase APIs
            Auth.auth().signInAndRetrieveData(with: credential, completion: {
                (user, error) in

                guard error == nil else {
                    completion(false, error)
                    return
                }

                if let uid = user?.user.uid {
                    User.getUser(by: uid, completion: { success in
                        if success {
                            completion(success, nil)
                        } else {
                            if let email = user?.user.email, let displayName = user?.user.displayName {
                                User.current.email = email
                                User.current.name = displayName
                                User.current.key = uid
                                User.current.fcmToken = FCMChannelManager.getFCMToken()
                                completion(success, nil)
                            } else {
                                completion(false, nil)
                            }
                        }
                    })
                }
            })
        }
    }
}
