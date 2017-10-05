//
//  ISPushFlowStep.swift
//  Alamofire
//
//  Created by Rubens Pessoa on 04/10/17.
//

import Foundation
import ObjectMapper

open class ISPushFlowStep: NSObject, Mappable {

    open var node: String?
    open var arrivedOn: Date?
    open var time: Date?
    open var actions: [ISPushFlowAction]?
    
    public required init?(map: Map) {}
    
    open func mapping(map: Map) {
        self.node           <- map["node"]
        self.time           <- map["time"]
    }
}

