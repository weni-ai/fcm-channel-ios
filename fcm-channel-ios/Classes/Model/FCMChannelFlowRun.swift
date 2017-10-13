//
//  URFlowRun.swift
//  ureport
//
//  Created by John Dalton Costa Cordeiro on 17/11/15.
//  Copyright © 2015 ilhasoft. All rights reserved.
//

import UIKit
import ObjectMapper

open class FCMChannelFlowRun: NSObject, Mappable {

    open var flow: FCMChannelFlow!
    open var contact: FCMChannelContact!
    open var path: [FCMChannelFlowStep]!
    open var responded: Bool!
    open var createdOn: Date!
    open var modifiedOn: Date!
    open var exitType: String!

    required public init?(map: Map){}

    open func mapping(map: Map) {
        self.flow       <- map["flow"]
        self.contact    <- map["contact"]
        self.path       <- map["path"]
        self.responded  <- map["responded"]
        self.createdOn  <- (map["created_on"], FCMChannelRapidPRODateTransform())
        self.modifiedOn <- (map["modified_on"], FCMChannelRapidPRODateTransform())
        self.exitType   <- map["exit_type"]
    }
}
