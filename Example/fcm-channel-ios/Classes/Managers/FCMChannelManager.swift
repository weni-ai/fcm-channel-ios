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
    
    static var apiPrefix = "http://push-dev.ilhasoft.mobi/api/v2/"
    static var token = "Token c62651e07199807ca75ae1a618273578b0e3869d"
    static var channel = "59860023-b1d5-4d79-99e9-bcfc54ba3de9"
    static var handlerUrl = "http://push.ilhasoft.mobi/handlers/fcm/"
    
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
        
        _ = FCMChannelSettings(token, channel: channel, url: apiPrefix, handlerURL: handlerUrl)
    }
    
    static func createContact(completion: @escaping (_ success: Bool) -> Void) {
        guard let key = User.current.key,
            let name = User.current.nickname,
            let fcmToken = User.current.fcmToken,
            let contact = User.current.contact else { return }

        User.current.contact = FCMChannelContact(urn: key, name: name, fcmToken: fcmToken)

        PushAPI.registerContact(contact) { uuid, error  in

            if let uuid = uuid, error == nil {
                User.current.contact_uid = uuid
                User.current.contact?.uuid = uuid
                completion(true)
            } else {
                print("Error: User couldn't register to channel.")
                completion(false)
            }
        }

    }
    
    static func loadContact(urn: String, completion: @escaping (FCMChannelContact?) -> Void) {
        PushAPI.loadContact(fromUrn: urn) { contact in
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
