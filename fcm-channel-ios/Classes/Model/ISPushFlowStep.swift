//
//  ISPushFlowStep.swift
//  Alamofire
//
//  Created by Rubens Pessoa on 04/10/17.
//

import Foundation
import ObjectMapper

class ISPushFlowStep: NSObject, Mappable {
    var node: String!
    var arrivedOn: Date!
    var time: Date!
    var actions: [ISPushFlowAction]!
}
