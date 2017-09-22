//
//  URFlowRuleTest.swift
//  ureport
//
//  Created by John Dalton Costa Cordeiro on 17/11/15.
//  Copyright © 2015 ilhasoft. All rights reserved.
//

import UIKit
import ObjectMapper

open class ISPushFlowRuleTest: NSObject, Mappable {

    open var test:[String : String] = [:]
    open var base:String?
    open var type:String?
    open var min:String?
    open var max:String?

    required public init?(map: Map){}

    open func mapping(map: Map) {
        self.test        <- map["test"]
        self.base        <- map["base"]
        self.type        <- map["type"]
        self.min         <- map["min"]
        self.max         <- map["max"]
    }
}
