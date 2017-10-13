//
//  URChoiceResponseView.swift
//  ureport
//
//  Created by John Dalton Costa Cordeiro on 19/11/15.
//  Copyright © 2015 ilhasoft. All rights reserved.
//

import UIKit

protocol FCMChannelChoiceResponseDelegate {
    func onChoiceSelected(_ flowRule:FCMChannelFlowRule)
}

open class FCMChannelChoiceResponseView: FCMChannelResponseView {
    
    var delegate:FCMChannelChoiceResponseDelegate?

    @IBOutlet weak var lbResponse: UILabel!
    @IBOutlet weak var btCheck: UIButton!
    @IBOutlet weak var imgCheck: UIImageView!
    
    //MARK: Superclass methods
    
    override func setFlowRule(_ flowDefinition:FCMChannelFlowDefinition, flowRule:FCMChannelFlowRule) {
        super.setFlowRule(flowDefinition, flowRule: flowRule)
        lbResponse.text = flowRule.ruleCategory[getLanguage()]
    }
    
    override func unselectResponse() {
        btCheck.isSelected = false
        let image = UIImage(named: "radio_button_Inactive", in: Bundle(for: FCMChannelChoiceResponseView.self), compatibleWith: nil)
        imgCheck.image = image
    }
    
    override func selectLanguage(_ language: String?) {
        lbResponse.text = flowRule.ruleCategory[getLanguage()]
    }
    
    //MARK: Actions
    
    @IBAction func toggleCheckButton(_ sender:AnyObject?) {
        if !btCheck.isSelected {
            btCheck.isSelected = true
            let image = UIImage(named: "radio_button_active", in: Bundle(for: FCMChannelChoiceResponseView.self), compatibleWith: nil)
            imgCheck.image = image
            
            if delegate != nil {
                delegate?.onChoiceSelected(flowRule)
            }
        } else {
            unselectResponse()
        }
    }

    //MARK: Class methods
    
    func getLanguage() -> String {
        if let language = flowDefinition.flows?.first?.baseLanguage {
            return selectedLanguage != nil && flowRule.ruleCategory.keys.contains(selectedLanguage!) ? selectedLanguage! : language
        }
        
        return ""
        
    }
}

