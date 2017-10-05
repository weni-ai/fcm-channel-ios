//
//  URFlowRuleset.swift
//  ureport
//
//  Created by John Dalton Costa Cordeiro on 17/11/15.
//  Copyright © 2015 ilhasoft. All rights reserved.
//

import UIKit
import ObjectMapper

open class ISPushFlowRuleset: NSObject, Mappable {

    open var uuid:String?
    open var webhookAction:String?
    open var rules:[ISPushFlowRule]?
    open var webhook:String?
    open var rulesetType:String?
    open var label:String?
    open var operand:String?
    open var labelKey:String?
    open var responseType:String?
    open var positionX:Int?
    open var positionY:Int?

    open init(uuid: String) {
        self.uuid = uuid
    }
    required public init?(map: Map){}

    open func mapping(map: Map) {
        self.uuid          <- map["uuid"]
        self.webhookAction <- map["webhook_action"]
        self.rules         <- map["rules"]
        self.webhook       <- map["webhook"]
        self.rulesetType   <- map["ruleset_type"]
        self.label         <- map["label"]
        self.operand       <- map["operand"]
        self.labelKey      <- map["label_key"]
        self.responseType  <- map["response_type"]
        self.positionX     <- map["x"]
        self.positionY     <- map["y"]
    }
}
