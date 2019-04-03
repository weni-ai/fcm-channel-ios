//
//  URFlowActionSet.swift
//  ureport
//
//  Created by John Dalton Costa Cordeiro on 17/11/15.
//  Copyright © 2015 ilhasoft. All rights reserved.
//

import UIKit
import ObjectMapper

open class FCMChannelFlowActionSet: NSObject, Mappable {

    open var positionX: Int?
    open var positionY: Int?
    open var destination: String?
    open var uuid: String?
    open var actions: [FCMChannelFlowAction]?

    required public init?(map: Map) {}

    open func mapping(map: Map) {
        self.positionX    <- map["x"]
        self.positionY    <- map["y"]
        self.destination  <- map["destination"]
        self.uuid         <- map["uuid"]
        self.actions      <- map["actions"]
    }
}
