//
//  Manager.swift
//  fcm-channel-ios
//
//  Created by Rubens Pessoa on 25/09/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit

public class FCMChannel {    
    
    public init(token:String, channel:String, fcmToken:String) {
        _ = FCMChannelSettings(token, channel: channel)
        FCMChannelContact.createContactAndSave(fcmToken: fcmToken) { (channelContact) in }
    }
    
}
