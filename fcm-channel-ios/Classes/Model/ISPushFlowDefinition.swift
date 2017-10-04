//
//  URFlowDefinition.swift
//  ureport
//
//  Created by John Dalton Costa Cordeiro on 17/11/15.
//  Copyright © 2015 ilhasoft. All rights reserved.
//

import UIKit
import ObjectMapper

open class ISPushFlowDefinition: NSObject/*, Mappable*/ {

    open var version: Int?
    open var site: String?
    open var flows: [ISPushFlow]?
    open var contact: ISPushContact?
    open var flowRun: ISPushFlowRun?

//    required public init?(map: Map){}
//
//    open func mapping(map: Map) {
//        self.baseLanguage    <- map["base_language"]
//        self.actionSets      <- map["action_sets"]
//        self.version         <- map["version"]
//        self.lastSaved       <- (map["last_saved"], ISPushRapidPRODateTransform())
//        self.type            <- map["flow_type"]
//        self.entry           <- map["entry"]
//        self.ruleSets        <- map["rule_sets"]
//        self.metadata        <- map["metadata"]
//    }
}
