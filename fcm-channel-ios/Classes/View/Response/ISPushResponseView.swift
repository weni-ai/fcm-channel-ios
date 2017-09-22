//
//  URResponseView.swift
//  ureport
//
//  Created by John Dalton Costa Cordeiro on 20/11/15.
//  Copyright © 2015 ilhasoft. All rights reserved.
//

import UIKit

open class ISPushResponseView: UIView {
    
    open var flowDefinition:ISPushFlowDefinition!
    open var flowRule:ISPushFlowRule!
    open var selectedLanguage:String? {
        didSet {
            selectLanguage(selectedLanguage)
        }
    }
    
    func setFlowRule(_ flowDefinition:ISPushFlowDefinition, flowRule:ISPushFlowRule) {
        self.flowDefinition = flowDefinition
        self.flowRule = flowRule
    }
    
    func unselectResponse() {}
    
    func selectLanguage(_ language:String?){}

}
