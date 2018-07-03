//
//  FCMChannelSettings.swift
//  Udo
//
//  Created by Daniel Amaral on 26/05/16.
//  Copyright © 2016 ilhasoft. All rights reserved.
//

import UIKit

open class FCMChannelSettings: NSObject {

    open var token:String!
    open var channel:String!
    open var url:String!
    open var handlerURL:String!

    static let preferedLanguageKey = "language"
    static let defaultLanguage = "en"
    static let V1 = "v1/"
    static let V2 = "v2/"

    static var shared:FCMChannelSettings!
    
    public init(_ token:String, channel:String) {
        super.init()
        self.token = token
        self.channel = channel
        self.url = "https://push.ilhasoft.mobi/api/"
        self.handlerURL = "https://push.ilhasoft.mobi/handlers/fcm/"
        FCMChannelSettings.shared = self
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
