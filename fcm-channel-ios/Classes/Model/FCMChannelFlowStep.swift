//
//  FCMChannelFlowStep.swift
//  Alamofire
//
//  Created by Rubens Pessoa on 04/10/17.
//

import Foundation
import ObjectMapper

open class FCMChannelFlowStep: NSObject, Mappable {

    open var node: String?
    open var arrivedOn: Date?
    open var time: Date?
    open var actions: [FCMChannelFlowAction]?
    
    public required init?(map: Map) {}
    
    open func mapping(map: Map) {
        self.node           <- map["node"]
        self.time           <- map["time"]
    }
}

