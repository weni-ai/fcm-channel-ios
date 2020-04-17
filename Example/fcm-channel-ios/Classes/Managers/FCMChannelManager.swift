//
//  Manager.swift
//  fcm-channel-ios
//
//  Created by Rubens Pessoa on 25/09/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit
import fcm_channel_ios

class FCMChannelManager {
    
    static let keyFCMToken = "KEY_FCM_TOKEN"
    
    static var apiPrefix = "https://new.push.al/api/"
    static var token = "b46da7e68e448631391352e8f447557cdc3c910a"
    static var channel = "749046f1-41f0-4ce7-bc93-2ca3fdbbffa9"
    static var handlerUrl = "https://new.push.al/c/fcm/"
    
    static func setup() {
        var rootDictionary: NSDictionary?
        
        if let path = Bundle.main.path(forResource: "Key-debug", ofType: "plist") {
            rootDictionary = NSDictionary(contentsOfFile: path)
        }
        
        if let dict = rootDictionary {
            if dict["COUNTRY_PROGRAM_TOKEN_SANDBOX"] != nil {
                token = dict["COUNTRY_PROGRAM_TOKEN_SANDBOX"] as? String ?? ""
            }
            
            if dict["COUNTRY_PROGRAM_CHANNEL_SANDBOX"] != nil {
                channel = dict["COUNTRY_PROGRAM_CHANNEL_SANDBOX"] as? String ?? ""
            }
            
            if dict["API_PREFIX"] != nil {
                apiPrefix = dict["API_PREFIX"] as? String ?? ""
            }            
            
            if dict["HANDLER_URL"] != nil {
                handlerUrl = dict["HANDLER_URL"] as? String ?? ""
            }
        }

        FCMClient.setup(token, channel: channel, url: apiPrefix, handler: handlerUrl, safeMode: false)
    }
    
    class func loadContact(urn: String, completion: @escaping (FCMChannelContact?) -> Void) {
        FCMClient.loadContact(fromUrn: urn) { contact, error in
            completion(contact)
        }
    }
    
    static func saveFCMToken(fcmToken: String) {
        UserDefaults.standard.set(fcmToken, forKey: self.keyFCMToken)
    }
    
    static func getFCMToken() -> String? {
        return  UserDefaults.standard.value(forKey: self.keyFCMToken) as? String
    }
}
