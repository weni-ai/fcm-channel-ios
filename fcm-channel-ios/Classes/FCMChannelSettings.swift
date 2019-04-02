//
//  FCMChannelSettings.swift
//  Udo
//
//  Created by Daniel Amaral on 26/05/16.
//  Copyright © 2016 ilhasoft. All rights reserved.
//

import UIKit

open class FCMChannelSettings: NSObject {

    open var token: String = ""
    open var channel: String = ""
    open var url: String = ""
    open var handlerURL: String = ""

    static let preferedLanguageKey = "language"
    static let defaultLanguage = "en"
    static let V1 = "v1/"
    static let V2 = "v2/"

    static var shared = FCMChannelSettings()

    private override init() {}

    open class func setup(_ token:String,
                channel:String,
                url: String = "https://push.ilhasoft.mobi/api/",
                handlerURL: String = "https://push.ilhasoft.mobi/handlers/fcm") {
        shared.token = token
        shared.channel = channel
        shared.url = url
        shared.handlerURL = handlerURL
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
