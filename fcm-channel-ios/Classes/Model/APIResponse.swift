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

class APIResponse<T: Mappable>: Mappable {
    var previous: String?
    var next: String?
    var results: [T]?

    required init?(map: Map){}

    func mapping(map: Map) {
        self.previous <- map["previous"]
        self.next <- map["next"]
        self.results  <- map["results"]
    }
}
