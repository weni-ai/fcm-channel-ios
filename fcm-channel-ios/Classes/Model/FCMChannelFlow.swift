//
//  FCMChannelFlow.swift
//  Alamofire
//
//  Created by Rubens Pessoa on 04/10/17.
//

import Foundation
import UIKit
import ObjectMapper

open class FCMChannelFlow: NSObject, Mappable {
    
    open var uuid: String?
    open var name: String?
    open var baseLanguage: String?
    open var actionSets: [FCMChannelFlowActionSet]?
    open var version: Int?
    open var type: String?
    open var entry: String?
    open var ruleSets: [FCMChannelFlowRuleset]?
    open var metadata: FCMChannelFlowMetadata?
    
    required public init?(map: Map){}
    
    open func mapping(map: Map) {
        self.uuid            <- map["uuid"]
        self.name            <- map["name"]
        self.baseLanguage    <- map["base_language"]
        self.actionSets      <- map["action_sets"]
        self.version         <- map["version"]
        self.type            <- map["flow_type"]
        self.entry           <- map["entry"]
        self.ruleSets        <- map["rule_sets"]
        self.metadata        <- map["metadata"]
    }
}
