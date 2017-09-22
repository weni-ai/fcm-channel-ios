//
//  URFlowAction.swift
//  ureport
//
//  Created by John Dalton Costa Cordeiro on 17/11/15.
//  Copyright © 2015 ilhasoft. All rights reserved.
//

import UIKit
import ObjectMapper

open class ISPushFlowAction: NSObject, Mappable {

    open var message: [String : String] = [:]
    open var type:String?

    required public init?(map: Map){}

    open func mapping(map: Map) {
        self.message    <- map["msg"]
        self.type       <- map["type"]
    }
}
