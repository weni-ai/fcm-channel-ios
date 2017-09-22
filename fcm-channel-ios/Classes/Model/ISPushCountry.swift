//
//  URCountry.swift
//  ureport
//
//  Created by Daniel Amaral on 09/07/15.
//  Copyright (c) 2015 ilhasoft. All rights reserved.
//

import UIKit
import Foundation
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


enum ISPushCountryCodeType {
    case iso2
    case iso3
}

class ISPushCountry: NSObject {

    var code:String?
    var name:String?

    init(code:String) {
        self.code = code
        super.init()
    }

    override init() {
        
    }

    class func getISO2CountryCodeByISO3Code(_ code:String) -> String{
        if let path = Bundle.main.path(forResource: "iso3-country-code", ofType: "json") {
            do {
                let jsonData = try Data(contentsOf: URL(fileURLWithPath: path), options: NSData.ReadingOptions.mappedIfSafe)
                do {
                    let jsonResult = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.mutableContainers)
                    
                    let filtered = (jsonResult as! NSDictionary).filter({ $0.1 as! String == code })
                    
                    if !filtered.isEmpty {
                        return filtered[0].key as! String
                    }
                    
                } catch let error as NSError {
                    print("error2 \(error.localizedDescription)")
                }
            }catch let error as NSError {
                print("error1 \(error.localizedDescription)")
            }
            
        }
        return ""
    }
}
