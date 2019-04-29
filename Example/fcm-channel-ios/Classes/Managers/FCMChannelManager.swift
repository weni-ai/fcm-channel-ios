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
    
    static var apiPrefix = "https://push.ilhasoft.mobi/api/"
    static var token = "a1a1428ce1a6bd748a70d6c888c17e5840939299"
    static var channel = "303bb2f6-8819-42a2-879c-cf659665f978" //7e464e15-1a20-4668-8792-7c785118bb71"
    static var handlerUrl = "https://push.ilhasoft.mobi/handlers/fcm/"
    
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
        
        FCMClient.setup(token, channel: channel, url: apiPrefix)
    }
    
    static func createContact(completion: @escaping (_ success: Bool) -> Void) {
//        guard let key = User.current.key,
//            let fcmToken = User.current.fcmToken else { return }
//
//        let contact = FCMChannelContact(urn: key, name: User.current.name, fcmToken: fcmToken)
//        FCMClient.registerFCMContact(contact) { uuid, error  in
//
//            if let uuid = uuid, error == nil {
//                User.current.contact_uid = uuid
//                contact.uuid = uuid
//                contact.fcmToken = User.current.fcmToken
//                contact.urn = key
//                User.current.contact = contact
//                completion(true)
//            } else {
//                print("Error: User couldn't register to channel.")
//                completion(false)
//            }
//        }
    }
    
    class func loadContact(urn: String, completion: @escaping (FCMChannelContact?) -> Void) {
        FCMClient.loadContact(fromUrn: urn) { contact in
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
