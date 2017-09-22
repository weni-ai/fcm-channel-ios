//
//  URFlowRun.swift
//  ureport
//
//  Created by John Dalton Costa Cordeiro on 17/11/15.
//  Copyright © 2015 ilhasoft. All rights reserved.
//

import UIKit
import ObjectMapper

class ISPushFlowRun: NSObject, Mappable {

    var flow_uuid:String!
    var flow:Int!
    var completed:Bool!
    var expires_on:Date!
    var expired_on:Date!

    required init?(map: Map){}

    func mapping(map: Map) {
        self.flow_uuid  <- map["flow_uuid"]
        self.flow       <- map["flow"]
        self.completed  <- map["completed"]
        self.expires_on <- (map["expires_on"], ISPushRapidPRODateTransform())
        self.expired_on <- (map["expired_on"], ISPushRapidPRODateTransform())
    }
}
