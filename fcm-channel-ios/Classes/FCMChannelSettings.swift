//
//  FCMChannelSettings.swift
//  Udo
//
//  Created by Daniel Amaral on 26/05/16.
//  Copyright © 2016 ilhasoft. All rights reserved.
//

import UIKit

open class FCMChannelSettings: NSObject {

    open static var token:String!
    open static var channel:String!
    open static var url:String!
    open static var handlerURL:String!

    static let preferedLanguageKey = "language"
    static let defaultLanguage = "en"
    static let V1 = "v1/"
    static let V2 = "v2/"

//    open static var sharedInstance:FCMChannelSettings!

//    required public init(token:String,channel:String,url:String,handlerURL:String) {
//        super.init()
//        FCMChannelSettings.sharedInstance = self
//    }

    open class func setConfiguration(_ token:String, channel:String) {
        self.token = token
        self.channel = channel
        self.url = "https://push.ilhasoft.mobi/api/"
        self.handlerURL = "https://push.ilhasoft.mobi/handlers/fcm/"
    }

    open class func savePreferedLanguage(_ language:String) {
        let defaults = UserDefaults.standard
        defaults.set(language, forKey: preferedLanguageKey)
        defaults.synchronize()
    }

    open class func getPreferedLanguage() -> String {
        let defaults = UserDefaults.standard
        if let preferedLanguage = defaults.object(forKey: preferedLanguageKey) {
            return preferedLanguage as! String
        }else {
            return defaultLanguage
        }
    }
}
