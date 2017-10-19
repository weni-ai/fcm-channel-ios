//
//  URRulesetResponse.swift
//  ureport
//
//  Created by John Dalton Costa Cordeiro on 23/11/15.
//  Copyright © 2015 ilhasoft. All rights reserved.
//

import UIKit

open class FCMChannelRulesetResponse: NSObject {

    open var rule: FCMChannelFlowRule!
    open var response:String!

    public init (rule: FCMChannelFlowRule?, response:String) {
        self.rule = rule
        self.response = response
    }
}

