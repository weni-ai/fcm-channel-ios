//
//  URFlowRun.swift
//  ureport
//
//  Created by John Dalton Costa Cordeiro on 17/11/15.
//  Copyright © 2015 ilhasoft. All rights reserved.
//

import UIKit
import ObjectMapper

class ISPushFlowRunResponse: NSObject, Mappable {

    var results:[ISPushFlowRun]!

    required init?(map: Map){}

    func mapping(map: Map) {
        self.results  <- map["results"]
    }
}
