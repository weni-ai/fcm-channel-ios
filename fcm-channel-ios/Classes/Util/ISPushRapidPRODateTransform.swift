//
//  RapidPRODateTransformer.swift
//  ureport
//
//  Created by John Dalton Costa Cordeiro on 17/11/15.
//  Copyright © 2015 ilhasoft. All rights reserved.
//

import ObjectMapper

class ISPushRapidPRODateTransform: DateTransform {

    override func transformFromJSON(_ value: Any?) -> Date? {
        if let timeInt = value as? Double {
            return NSDate(timeIntervalSince1970: TimeInterval(timeInt)) as Date
        } else if let timeString = value as? String {
            return ISPushDateUtil.dateParserRapidPro(timeString)
        }
        return nil
    }
}
