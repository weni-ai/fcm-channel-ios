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
    
    static let ref = Database.database().reference().child("users")
    static var current = User()
    
    var key: String!
    var nickname: String?
    var email: String?
    var fcmToken:String?
    var contact_uid: String?
    var contact: FCMChannelContact?
    
    override init() {
        super.init()
    }
    
    func save(completion: @escaping (_ success: Bool) -> ()) {
        let userRef = User.ref.child(User.current.key)
        
        FCMChannelManager.createContact() {
            success in
            
            if success {
                userRef.setValue(["nickname": User.current.nickname, "email": User.current.email, "fcmToken": User.current.fcmToken, "contact_uid": User.current.contact_uid]) {
                    error, _ in
                    
                    if error != nil {
                        completion(false)
                    } else {
                        completion(true)
                    }
                }
            }
            
            completion(success)
        }
    }
    
    static func getUser(by key: String, completion: @escaping (_ success: Bool) -> ()) {
        let userRef = User.ref.child(key)
        
        FCMChannelManager.loadContact(urn: key) { (contact) in
            if let contact = contact {
                userRef.observeSingleEvent(of: .value, with: {

                    (snapshot) in
                    if let value = snapshot.value as? NSDictionary {
                        if let email = value["email"] as? String, let nickname = value["nickname"] as? String, let fcmToken = value["fcmToken"] as? String, let contact_uid = value["contact_uid"] as? String {

                            User.current.key = key
                            User.current.email = email
                            User.current.nickname = nickname
                            User.current.fcmToken = fcmToken
                            User.current.contact_uid = contact_uid
                            User.current.contact = contact

//                    User.current.key = key
//                    User.current.email = "email"
//                    User.current.nickname = "nickname"
//                    User.current.fcmToken = "token"
//                    User.current.contact_uid = contact.uuid ?? ""
//                    User.current.contact = contact

                            completion(true)
                        } else {
                            completion(false)
                        }
                    } else {
                        completion(false)
                    }
                })
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
