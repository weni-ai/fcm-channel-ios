//
//  FCMChannelLabel.swift
//  Alamofire
//
//  Created by Rubens Pessoa on 04/10/17.
//

import Foundation
import ObjectMapper

open class FCMChannelLabel: NSObject, Mappable {
    open var uuid: String!
    open var name: String!
    
    required public init?(map: Map){}
    
    open func mapping(map: Map) {
        self.uuid              <- map["uuid"]
        self.name              <- map["name"]
    }
}
