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
    var pushIdentity:String?
    var contact_uid: String?
    var pushContact: ISPushContact?
    
    override init() {
        super.init()
    }
    
    func save(completion: @escaping (_ success: Bool) -> ()) {
        let userRef = User.ref.child(User.current.key)
        
        PushManager.createPushContact() {
            success in
            
            if success {
                userRef.setValue(["nickname": User.current.nickname, "email": User.current.email, "pushIdentity": User.current.pushIdentity, "contact_uid": User.current.contact_uid]) {
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
        
        PushManager.loadPushContact(urn: key) { (pushContact) in
            if let pushContact = pushContact {
                userRef.observeSingleEvent(of: .value, with: {
                    (snapshot) in
                    
                    if let value = snapshot.value as? NSDictionary {
                        if let email = value["email"] as? String, let nickname = value["nickname"] as? String, let pushIdentity = value["pushIdentity"] as? String, let contact_uid = value["contact_uid"] as? String {
                            
                            User.current.key = key
                            User.current.email = email
                            User.current.nickname = nickname
                            User.current.pushIdentity = pushIdentity
                            User.current.contact_uid = contact_uid
                            User.current.pushContact = pushContact
                            
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
        
        if encodedData != nil {
            let user: User = User(jsonDict: NSKeyedUnarchiver.unarchiveObject(with: encodedData!) as? NSDictionary)
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
