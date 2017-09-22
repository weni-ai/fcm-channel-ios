//
//  ISPushSettings.swift
//  Udo
//
//  Created by Daniel Amaral on 26/05/16.
//  Copyright © 2016 ilhasoft. All rights reserved.
//

import UIKit

open class ISPushSettings: NSObject {

    open static var token:String!
    open static var channel:String!
    open static var url:String!
    open static var handlerURL:String!

    static let preferedLanguageKey = "language"
    static let defaultLanguage = "en"
    static let V1 = "v1/"
    static let V2 = "v2/"

    open static var sharedInstance:ISPushSettings!

    required public init(token:String,channel:String,url:String,handlerURL:String) {
        super.init()
        ISPushSettings.sharedInstance = self
    }

    open class func setConfiguration(_ token: String = "",channel:String, url: String = "https://rapidpro.ilhasoft.mobi/api/", handlerURL: String = "https://rapidpro.ilhasoft.mobi/handlers/fcm/") {
        self.token = token
        self.channel = channel
        self.url = url
        self.handlerURL = handlerURL

        self.init(token: token,
                  channel: channel,
                  url: url,
                  handlerURL: handlerURL)
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
