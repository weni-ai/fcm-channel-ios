//
//  URFlowMetadata.swift
//  ureport
//
//  Created by John Dalton Costa Cordeiro on 17/11/15.
//  Copyright © 2015 ilhasoft. All rights reserved.
//


import UIKit
import ObjectMapper

open class ISPushFlowMetadata: NSObject, Mappable {

    open var uuid:String?
    open var expires:Int?
    open var name:String?
    open var revision:Int?
    open var id:Int?
    open var savedOn:Date?

    required public init?(map: Map){}

    open func mapping(map: Map) {
        self.uuid           <- map["uuid"]
        self.expires        <- map["expires"]
        self.name           <- map["name"]
        self.revision       <- map["revision"]
        self.id             <- map["id"]
        self.savedOn        <- (map["save_on"], ISPushRapidPRODateTransform())
    }
}
