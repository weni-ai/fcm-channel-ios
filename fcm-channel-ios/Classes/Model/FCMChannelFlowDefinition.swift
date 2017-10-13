//
//  URFlowDefinition.swift
//  ureport
//
//  Created by John Dalton Costa Cordeiro on 17/11/15.
//  Copyright © 2015 ilhasoft. All rights reserved.
//

import UIKit
import ObjectMapper

open class FCMChannelFlowDefinition: NSObject, Mappable {

    open var version: Int?
    open var site: String?
    open var flows: [FCMChannelFlow]?
    open var contact: FCMChannelContact?
    open var flowRun: FCMChannelFlowRun?

    required public init?(map: Map){}

    open func mapping(map: Map) {
        self.version           <- map["version"]
        self.site              <- map["site"]
        self.flows             <- map["flows"]
    }
}
