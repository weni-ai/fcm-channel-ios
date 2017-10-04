//
//  ISPushFlowStepSet.swift
//  Alamofire
//
//  Created by Rubens Pessoa on 04/10/17.
//

import Foundation

class ISPushFlowStepSet: NSObject {
    var flow: String!
    var contact: String!
    var completed: Bool!
    var started: Date!
    var revision: Int!
    var steps: [ISPushFlowStep]!
}
