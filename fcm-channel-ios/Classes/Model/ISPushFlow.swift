//
//  ISPushFlow.swift
//  Alamofire
//
//  Created by Rubens Pessoa on 04/10/17.
//

import Foundation
import UIKit
import ObjectMapper

class ISPushFlow: NSObject, Mappable {
    open var baseLanguage:String?
    open var actionSets:[ISPushFlowActionSet]?
    open var version:Int?
    open var lastSaved:Date?
    open var type:String?
    open var entry:String?
    open var ruleSets:[ISPushFlowRuleset]?
    open var metadata:ISPushFlowMetadata?
    
    required public init?(map: Map){}
    
    open func mapping(map: Map) {
        self.baseLanguage    <- map["base_language"]
        self.actionSets      <- map["action_sets"]
        self.version         <- map["version"]
        self.lastSaved       <- (map["last_saved"], ISPushRapidPRODateTransform())
        self.type            <- map["flow_type"]
        self.entry           <- map["entry"]
        self.ruleSets        <- map["rule_sets"]
        self.metadata        <- map["metadata"]
    }
}


