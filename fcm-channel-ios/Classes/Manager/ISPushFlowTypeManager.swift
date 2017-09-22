//
//  ISPushFlowTypeManager.swift
//  ureport
//
//  Created by John Dalton Costa Cordeiro on 19/11/15.
//  Copyright © 2015 ilhasoft. All rights reserved.
//

import UIKit

class ISPushFlowTypeManager: NSObject {
    
    let OpenField: ISPushFlowTypeValidation = ISPushFlowTypeValidation(type: ISPushFlowType.openField, validation: "true", message: "Please, fill all the fields")
    let Choice: ISPushFlowTypeValidation = ISPushFlowTypeValidation(type: ISPushFlowType.choice, validation: "contains_any", message: "Please, fill all the fields")
    let OpenFieldContains: ISPushFlowTypeValidation = ISPushFlowTypeValidation(type: ISPushFlowType.openField, validation: "contains", message: "Please, fill all the fields")
    let OpenFieldNotEmpty: ISPushFlowTypeValidation = ISPushFlowTypeValidation(type: ISPushFlowType.openField, validation: "not_empty", message: "Please, fill all the fields")
    let OpenFieldStarts: ISPushFlowTypeValidation = ISPushFlowTypeValidation(type: ISPushFlowType.openField, validation: "starts", message: "Please, fill all the fields")
    let OpenFieldRegex: ISPushFlowTypeValidation = ISPushFlowTypeValidation(type: ISPushFlowType.openField, validation: "regex", message: "Field invalid, check the instructions")
    let Number: ISPushFlowTypeValidation = ISPushFlowTypeValidation(type: ISPushFlowType.number, validation: "number", message: "Numeric field with invalid value")
    let NumberLessThan: ISPushFlowTypeValidation = ISPushFlowTypeValidation(type: ISPushFlowType.number, validation: "lt", message: "Numeric field with invalid value, check the instructions")
    let NumberGreaterThan: ISPushFlowTypeValidation = ISPushFlowTypeValidation(type: ISPushFlowType.number, validation: "gt", message: "Numeric field with invalid value, check the instructions")
    let NumberBetween: ISPushFlowTypeValidation = ISPushFlowTypeValidation(type: ISPushFlowType.number, validation: "between", message: "Numeric field with invalid value, check the instructions")
    let NumberEqual: ISPushFlowTypeValidation = ISPushFlowTypeValidation(type: ISPushFlowType.number, validation: "eq", message: "Numeric field with invalid value, check the instructions")
    let Date: ISPushFlowTypeValidation = ISPushFlowTypeValidation(type: ISPushFlowType.date, validation: "date", message: "Date field with invalid value, check the instructions")
    let DateBefore: ISPushFlowTypeValidation = ISPushFlowTypeValidation(type: ISPushFlowType.date, validation: "date_before", message: "Date field with invalid value, check the instructions")
    let DateAfter: ISPushFlowTypeValidation = ISPushFlowTypeValidation(type: ISPushFlowType.date, validation: "date_after", message: "Date field with invalid value, check the instructions")
    let DateEqual: ISPushFlowTypeValidation = ISPushFlowTypeValidation(type: ISPushFlowType.date, validation: "date_equal", message: "Date field with invalid value, check the instructions")
    let Phone: ISPushFlowTypeValidation = ISPushFlowTypeValidation(type: ISPushFlowType.phone, validation: "phone", message: "Phone with invalid value, check the instructions")
    let State: ISPushFlowTypeValidation = ISPushFlowTypeValidation(type: ISPushFlowType.state, validation: "state", message: "State with invalid value, check the instructions")
    let District: ISPushFlowTypeValidation = ISPushFlowTypeValidation(type: ISPushFlowType.district, validation: "district", message: "District with invalid value, check the instructions")
    
    let typeValidations: [ISPushFlowTypeValidation]
    
    override init() {
        typeValidations = [OpenField, Choice, OpenFieldContains, OpenFieldNotEmpty, OpenFieldStarts, OpenFieldRegex, Number, NumberLessThan, NumberGreaterThan, NumberBetween, NumberEqual, Date, DateBefore, DateAfter, DateEqual, Phone, State, District]
    }
    
    func getTypeValidationForRule(_ flowRule:ISPushFlowRule) -> ISPushFlowTypeValidation {
        return getTypeValidation((flowRule.test?.type)!)
    }
    
    func getTypeValidation(_ validation:String) -> ISPushFlowTypeValidation {
        for typeValidation in self.typeValidations {
            if typeValidation.validation == validation {
                return typeValidation
            }
        }
        return OpenField
    }
    
}
