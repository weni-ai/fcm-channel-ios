//
//  URRulesetResponse.swift
//  ureport
//
//  Created by John Dalton Costa Cordeiro on 23/11/15.
//  Copyright © 2015 ilhasoft. All rights reserved.
//

import UIKit

class ISPushRulesetResponse: NSObject {

    var rule:ISPushFlowRule!
    var response:String!

    public init (rule:ISPushFlowRule?, response:String) {
        self.rule = rule
        self.response = response
    }
}
