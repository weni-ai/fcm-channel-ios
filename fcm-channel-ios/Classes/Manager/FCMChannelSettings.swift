//
//  FCMChannelSettings.swift
//  Udo
//
//  Created by Daniel Amaral on 26/05/16.
//  Copyright © 2016 ilhasoft. All rights reserved.
//

import UIKit

class FCMChannelSettings: NSObject {

    var token: String = ""
    var channel: String = ""
    var url: String = ""
    var handlerURL: String = "https://push.ilhasoft.mobi/c/fcm/"

    let preferedLanguageKey = "language"
    let defaultLanguage = "en"
    let V2 = "v2/"

    static var shared = FCMChannelSettings()

    private override init() {}

    static func setup(_ token: String,
                      channel: String,
                      url: String = "https://push.ilhasoft.mobi/api/") {
        shared.token = token
        shared.channel = channel
        shared.url = url
    }

    func savePreferedLanguage(_ language: String) {
        let defaults = UserDefaults.standard
        defaults.set(language, forKey: preferedLanguageKey)
        defaults.synchronize()
    }

   func getPreferedLanguage() -> String {
        let defaults = UserDefaults.standard
        if let preferedLanguage = defaults.object(forKey: preferedLanguageKey) {
            return preferedLanguage as? String ?? ""
        } else {
            return defaultLanguage
        }
    }
}
