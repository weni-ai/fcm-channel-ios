//
//  URFlowRun.swift
//  ureport
//
//  Created by John Dalton Costa Cordeiro on 17/11/15.
//  Copyright © 2015 ilhasoft. All rights reserved.
//

import UIKit
import ObjectMapper

class FCMChannelMessagesResponse: NSObject, Mappable {

    var results:[FCMChannelMessage]!

    required init?(map: Map){}

    func mapping(map: Map) {
        self.results  <- map["results"]
    }
}
