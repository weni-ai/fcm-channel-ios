//
//  FCMChannelGroup.swift
//  fcm-channel-ios
//
//  Created by Rubens Pessoa on 04/10/17.
//

import Foundation
import ObjectMapper

open class FCMChannelGroup: NSObject, Mappable {

    public required init?(map: Map) {}

    var uuid: String?
    var name: String?

    open func mapping(map: Map) {
        self.uuid           <- map["uuid"]
        self.name           <- map["name"]
    }
}
