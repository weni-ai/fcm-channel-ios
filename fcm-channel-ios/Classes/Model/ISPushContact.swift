//
//  URContact.swift
//  ureport
//
//  Created by Daniel Amaral on 13/08/15.
//  Copyright (c) 2015 ilhasoft. All rights reserved.
//

import UIKit
import ObjectMapper

open class ISPushContact: NSObject, Mappable {
   
    open var uuid:String?
    open var urn: String?
    open var name:String?
    open var phoneNumber:String?
    open var email: String?
    open var state: String?
    open var birthday: NSNumber?
    open var country: String?
    open var picture: String?
    open var gender: String?
    open var pushIdentity:String?
    open var born:String?
    
    public init(urn: String, name: String, pushIdentity: String) {
        self.urn = urn
        self.name = name
        self.pushIdentity = pushIdentity
    }
    
    required public init?(map: Map){}
    
    open func mapping(map: Map) {
        self.urn            <- map["urn"]
        self.uuid           <- map["uuid"]
        self.name           <- map["name"]
        self.phoneNumber    <- map["phoneNumber"]
        self.email          <- map["email"]
        self.state          <- map["state"]
        self.birthday       <- map["birthday"]
        self.country        <- map["country"]
        self.picture        <- map["picture"]
        self.gender         <- map["gender"]
        self.pushIdentity        <- map["pushIdentity"]
        self.born           <- map["born"]
    }
    
    open class func formatExtContactId(_ key:String) -> String {
        return key.replacingOccurrences(of: "+", with: "%2B")
    }
    
}
