//
//  URResponseView.swift
//  ureport
//
//  Created by John Dalton Costa Cordeiro on 20/11/15.
//  Copyright © 2015 ilhasoft. All rights reserved.
//

import UIKit

open class FCMChannelResponseView: UIView {
    
    open var flowDefinition:FCMChannelFlowDefinition!
    open var flowRule:FCMChannelFlowRule!
    open var selectedLanguage:String? {
        didSet {
            selectLanguage(selectedLanguage)
        }
    }
    
    func setFlowRule(_ flowDefinition:FCMChannelFlowDefinition, flowRule:FCMChannelFlowRule) {
        self.flowDefinition = flowDefinition
        self.flowRule = flowRule
    }
    
    func unselectResponse() {}
    
    func selectLanguage(_ language:String?){}

}
