//
//  URContact.swift
//  ureport
//
//  Created by Daniel Amaral on 13/08/15.
//  Copyright (c) 2015 ilhasoft. All rights reserved.
//

import UIKit
import ObjectMapper

open class FCMChannelContact: NSObject, Mappable {
   
    open var uuid: String?
    open var urn: String?
    open var urns: String?
    open var name: String?
    open var phoneNumber: String?
    open var email: String?
    open var state: String?
    open var birthday: NSNumber?
    open var country: String?
    open var picture: String?
    open var gender: String?
    open var fcmToken: String?
    open var born: String?
    open var fields: [String: Any]?
    
    public init(uuid: String? = nil, urn: String, name: String?, fcmToken: String) {
        self.uuid = uuid
        self.urn = urn
        self.name = name
        self.fcmToken = fcmToken
    }
    
    required public init?(map: Map){}
    
    open func mapping(map: Map) {
        self.urns           <- map["urns"]
        self.uuid           <- map["uuid"]
        self.name           <- map["name"]
        self.phoneNumber    <- map["phoneNumber"]
        self.email          <- map["email"]
        self.state          <- map["state"]
        self.birthday       <- map["birthday"]
        self.country        <- map["country"]
        self.picture        <- map["picture"]
        self.gender         <- map["gender"]
        self.fcmToken       <- map["fcmToken"]
        self.born           <- map["born"]
        self.fields         <- map["fields"]
    }
    
    open class func formatExtContactId(_ key: String) -> String {
        return key.replacingOccurrences(of: "+", with: "%2B")
    }
    
    public static func current() -> FCMChannelContact? {
        let defaults: UserDefaults = UserDefaults.standard
        
        var contact: FCMChannelContact?
        if let encodedData = defaults.object(forKey: "fcmchannelcontact") as? Data,
            let jsonString =  NSKeyedUnarchiver.unarchiveObject(with: encodedData) as? String {
            contact = FCMChannelContact(JSONString: jsonString)
        }
        return contact
    }
    
    public static func deactivateChannelContact() {
        let defaults: UserDefaults = UserDefaults.standard
        defaults.removeObject(forKey: "fcmchannelcontact")
        defaults.synchronize()
    }
    
    public static func setActive(contact: FCMChannelContact) {
        let defaults: UserDefaults = UserDefaults.standard
        let encodedObject: Data = NSKeyedArchiver.archivedData(withRootObject: contact.toJSONString() as Any)
        defaults.set(encodedObject, forKey: "fcmchannelcontact")
        defaults.synchronize()
    }
    
    public static func createContactAndSave(name: String,
                                            uuid: String?,
                                            urn: String,
                                            fcmToken: String,
                                            completion: @escaping (_ contact: FCMChannelContact?, _ error: Error?) -> Void) {
        
        let contact = FCMChannelContact(uuid: uuid, urn: urn, name: name, fcmToken: fcmToken)
        FCMClient.registerFCMContact(contact) { uuid, error in
            if let uuid = uuid {
                contact.uuid = uuid
                setActive(contact: contact)
            }

            completion(contact, error)
        }
    }
}
