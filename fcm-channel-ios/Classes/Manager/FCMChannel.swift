//
//  Manager.swift
//  fcm-channel-ios
//
//  Created by Rubens Pessoa on 25/09/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit

public class FCMChannel {
    
//    static let keyFCMToken = "KEY_FCM_TOKEN"
    
    public init(token:String, channel:String, fcmToken:String) {
        FCMChannelSettings.setConfiguration(token, channel: channel)
        FCMChannelContact.createContactAndSave(fcmToken: fcmToken) { (channelContact) in }
    }
    
//    static func saveFCMToken(fcmToken: String) {
//        UserDefaults.standard.set(fcmToken, forKey: self.keyFCMToken)
//    }
//
//    static func getFCMToken() -> String? {
//        return  UserDefaults.standard.value(forKey: self.keyFCMToken) as? String
//    }
}
