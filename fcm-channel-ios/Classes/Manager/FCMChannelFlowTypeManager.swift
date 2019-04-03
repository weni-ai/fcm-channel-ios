//
//  FCMChannelFlowTypeManager.swift
//  ureport
//
//  Created by John Dalton Costa Cordeiro on 19/11/15.
//  Copyright © 2015 ilhasoft. All rights reserved.
//

import UIKit

class FCMChannelFlowTypeManager: NSObject {
    
    let OpenField: FCMChannelFlowTypeValidation = FCMChannelFlowTypeValidation(type: FCMChannelFlowType.openField, validation: "true", message: "Please, fill all the fields")
    let Choice: FCMChannelFlowTypeValidation = FCMChannelFlowTypeValidation(type: FCMChannelFlowType.choice, validation: "contains_any", message: "Please, fill all the fields")
    let OpenFieldContains: FCMChannelFlowTypeValidation = FCMChannelFlowTypeValidation(type: FCMChannelFlowType.openField, validation: "contains", message: "Please, fill all the fields")
    let OpenFieldNotEmpty: FCMChannelFlowTypeValidation = FCMChannelFlowTypeValidation(type: FCMChannelFlowType.openField, validation: "not_empty", message: "Please, fill all the fields")
    let OpenFieldStarts: FCMChannelFlowTypeValidation = FCMChannelFlowTypeValidation(type: FCMChannelFlowType.openField, validation: "starts", message: "Please, fill all the fields")
    let OpenFieldRegex: FCMChannelFlowTypeValidation = FCMChannelFlowTypeValidation(type: FCMChannelFlowType.openField, validation: "regex", message: "Field invalid, check the instructions")
    let Number: FCMChannelFlowTypeValidation = FCMChannelFlowTypeValidation(type: FCMChannelFlowType.number, validation: "number", message: "Numeric field with invalid value")
    let NumberLessThan: FCMChannelFlowTypeValidation = FCMChannelFlowTypeValidation(type: FCMChannelFlowType.number, validation: "lt", message: "Numeric field with invalid value, check the instructions")
    let NumberGreaterThan: FCMChannelFlowTypeValidation = FCMChannelFlowTypeValidation(type: FCMChannelFlowType.number, validation: "gt", message: "Numeric field with invalid value, check the instructions")
    let NumberBetween: FCMChannelFlowTypeValidation = FCMChannelFlowTypeValidation(type: FCMChannelFlowType.number, validation: "between", message: "Numeric field with invalid value, check the instructions")
    let NumberEqual: FCMChannelFlowTypeValidation = FCMChannelFlowTypeValidation(type: FCMChannelFlowType.number, validation: "eq", message: "Numeric field with invalid value, check the instructions")
    let Date: FCMChannelFlowTypeValidation = FCMChannelFlowTypeValidation(type: FCMChannelFlowType.date, validation: "date", message: "Date field with invalid value, check the instructions")
    let DateBefore: FCMChannelFlowTypeValidation = FCMChannelFlowTypeValidation(type: FCMChannelFlowType.date, validation: "date_before", message: "Date field with invalid value, check the instructions")
    let DateAfter: FCMChannelFlowTypeValidation = FCMChannelFlowTypeValidation(type: FCMChannelFlowType.date, validation: "date_after", message: "Date field with invalid value, check the instructions")
    let DateEqual: FCMChannelFlowTypeValidation = FCMChannelFlowTypeValidation(type: FCMChannelFlowType.date, validation: "date_equal", message: "Date field with invalid value, check the instructions")
    let Phone: FCMChannelFlowTypeValidation = FCMChannelFlowTypeValidation(type: FCMChannelFlowType.phone, validation: "phone", message: "Phone with invalid value, check the instructions")
    let State: FCMChannelFlowTypeValidation = FCMChannelFlowTypeValidation(type: FCMChannelFlowType.state, validation: "state", message: "State with invalid value, check the instructions")
    let District: FCMChannelFlowTypeValidation = FCMChannelFlowTypeValidation(type: FCMChannelFlowType.district, validation: "district", message: "District with invalid value, check the instructions")
    
    let typeValidations: [FCMChannelFlowTypeValidation]
    
    override init() {
        typeValidations = [OpenField, Choice, OpenFieldContains, OpenFieldNotEmpty, OpenFieldStarts, OpenFieldRegex, Number, NumberLessThan, NumberGreaterThan, NumberBetween, NumberEqual, Date, DateBefore, DateAfter, DateEqual, Phone, State, District]
    }
    
    func getTypeValidationForRule(_ flowRule:FCMChannelFlowRule) -> FCMChannelFlowTypeValidation? {
        return getTypeValidation((flowRule.test?.type ?? ""))
    }
    
    func getTypeValidation(_ validation:String) -> FCMChannelFlowTypeValidation {
        for typeValidation in self.typeValidations {
            if typeValidation.validation == validation {
                return typeValidation
            }
        }
        return OpenField
    }
    
}
