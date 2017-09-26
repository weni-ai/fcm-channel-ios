//
//  PushManager.swift
//  fcm-channel-ios
//
//  Created by Rubens Pessoa on 25/09/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit
import fcm_channel_ios

class PushManager {
    
    static let keyFCMToken = "KEY_FCM_TOKEN"
    
    static var apiPrefix = ""
    static var token = ""
    static var channel = ""
    static var handlerUrl = ""
    
    static func setupPush() {
        var rootDictionary: NSDictionary?
        
        if let path = Bundle.main.path(forResource: "Key-debug", ofType: "plist") {
            rootDictionary = NSDictionary(contentsOfFile: path)
        }
        
        if let dict = rootDictionary {
            if dict["COUNTRY_PROGRAM_TOKEN_SANDBOX"] != nil {
                token = dict["COUNTRY_PROGRAM_TOKEN_SANDBOX"] as! String
            }
            
            if dict["COUNTRY_PROGRAM_CHANNEL_SANDBOX"] != nil {
                channel = dict["COUNTRY_PROGRAM_CHANNEL_SANDBOX"] as! String
            }
            
            if dict["API_PREFIX"] != nil {
                apiPrefix = dict["API_PREFIX"] as! String
            }            
            
            if dict["HANDLER_URL"] != nil {
                handlerUrl = dict["HANDLER_URL"] as! String
            }
        }
        
        ISPushSettings.setConfiguration(token, channel: channel, url: apiPrefix, handlerURL: handlerUrl)
    }
    
    static func createPushContact(completion: @escaping (_ success: Bool) -> ()) {
        if let key = User.current.key, let name = User.current.nickname, let pushIdentity = User.current.pushIdentity {
            
            User.current.pushContact = ISPushContact(uuid: key, name: name, pushIdentity: pushIdentity)
            
            ISPushManager.registerContact(User.current.pushContact!) {
                uuid in
                
                if let uuid = uuid {
                    print(uuid)
                    completion(true)
                } else {
                    print("Error: User couldn't register to channel.")
                    completion(false)
                }
            }
        }
    }
    
    static func saveFCMToken(fcmToken: String) {
        UserDefaults.standard.set(fcmToken, forKey: self.keyFCMToken)
    }
    
    static func getFCMToken() -> String? {
        return  UserDefaults.standard.value(forKey: self.keyFCMToken) as? String
    }
}
