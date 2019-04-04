//
//  User.swift
//  fcm-channel-ios
//
//  Created by Rubens Pessoa on 25/09/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit
import FirebaseDatabase
import fcm_channel_ios

class User: Serializable {

    static var current = User()
    
    var key: String!
    var name: String = "FCM Channel Sample User"
    var email: String = "sample@gmail.com"
    var fcmToken: String?
    var contact_uid: String?
    var contact: FCMChannelContact?
    
    override init() {
        super.init()
    }
    
    func save(completion: @escaping (_ success: Bool) -> ()) {
        FCMChannelManager.createContact() {
            success in
            completion(success)
        }
    }
    
    static func getUser(by key: String, completion: @escaping (_ success: Bool) -> ()) {

        FCMChannelManager.loadContact(urn: key) { (contact) in
            if let contact = contact {

                User.current.key = key
                User.current.fcmToken = contact.fcmToken
                User.current.contact_uid = contact.uuid
                User.current.contact = contact
                User.current.fcmToken = FCMChannelManager.getFCMToken()

                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    class func formatExtUserId(_ key: String) -> String {
        return key.replacingOccurrences(of: ":", with: "") .replacingOccurrences(of: "-", with: "")
    }
    
    //MARK: User Account Manager
    
    static func activeUser() -> User? {
        let defaults: UserDefaults = UserDefaults.standard
        var encodedData: Data?
        
        encodedData = defaults.object(forKey: "user") as? Data
        
        if let encodedData = encodedData {
            let user: User = User(jsonDict: NSKeyedUnarchiver.unarchiveObject(with: encodedData) as? NSDictionary)
            return user
        } else {
            return nil
        }
    }
    
    static func setActiveUser(_ user: User!) {
        self.deactivateUser()
        let defaults: UserDefaults = UserDefaults.standard
        let encodedObject: Data = NSKeyedArchiver.archivedData(withRootObject: user.toDictionary())
        defaults.set(encodedObject, forKey: "user")
        defaults.synchronize()
    }
    
    static func deactivateUser() {
        let defaults: UserDefaults = UserDefaults.standard
        defaults.removeObject(forKey: "user")
        defaults.synchronize()
    }
    
}
