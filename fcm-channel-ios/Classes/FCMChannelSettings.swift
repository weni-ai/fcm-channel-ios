//
//  FCMChannelSettings.swift
//  Udo
//
//  Created by Daniel Amaral on 26/05/16.
//  Copyright © 2016 ilhasoft. All rights reserved.
//

import UIKit

@objc open class FCMChannelSettings: NSObject {

    open var token:String!
    open var channel:String!
    open var url:String!
    open var handlerURL:String!

    static let preferedLanguageKey = "language"
    static let defaultLanguage = "en"
    static let V1 = "v1/"
    static let V2 = "v2/"

    static weak var shared: FCMChannelSettings!

    private override init() {}
    
    @objc public init(_ token:String,
                channel:String,
                url: String = "https://push.ilhasoft.mobi/api/",
                handlerURL: String = "https://push.ilhasoft.mobi/handlers/fcm") {
        super.init()
        self.token = token
        self.channel = channel
        self.url = url
        self.handlerURL = handlerURL
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
