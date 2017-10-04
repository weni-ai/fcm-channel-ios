//
//  URFlowRule.swift
//  ureport
//
//  Created by John Dalton Costa Cordeiro on 17/11/15.
//  Copyright © 2015 ilhasoft. All rights reserved.
//

import UIKit
import ObjectMapper

open class ISPushFlowRule: NSObject, Mappable {

    open var ruleCategory: [String : String] = [:]
    open var test: ISPushFlowRuleTest?
    open var destination: String?
    open var uuid: NSString?
    open var destinationType: NSString?

    required public init?(map: Map){}

    open func mapping(map: Map) {
        self.ruleCategory       <- map["category"]
        self.test               <- map["test"]
        self.destination        <- map["destination"]
        self.uuid               <- map["uuid"]
        self.destinationType    <- map["destination_type"]
    }
}
