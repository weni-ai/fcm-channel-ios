//
//  URServerDateTime.swift
//  ureport
//
//  Created by Daniel Amaral on 30/03/16.
//  Copyright © 2016 ilhasoft. All rights reserved.
//

import UIKit
import ObjectMapper

class FCMChannelServerDateTime: NSObject, Mappable {

    var status:String!
    var timestamp:Int!

    required init?(map: Map){}

    func mapping(map: Map) {
        self.status    <- map["status"]
        self.timestamp      <- map["timestamp"]
    }
}
