//
//  APIResponse.swift
//  fcm-channel-ios
//
//  Created by Alexandre Azevedo on 03/04/19.
//

import Foundation
import Alamofire
import AlamofireObjectMapper
import ObjectMapper

open class APIResponse<T: Mappable>: Mappable {
    open var previous: String?
    open var next: String?
    open var results: [T]?

    required public init?(map: Map) {}

    public init(results: [T]) {
        self.results = results
    }

    public func mapping(map: Map) {
        self.previous <- map["previous"]
        self.next <- map["next"]
        self.results  <- map["results"]
    }
}
