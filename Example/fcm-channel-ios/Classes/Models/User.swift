//
//  User.swift
//  fcm-channel-ios
//
//  Created by Rubens Pessoa on 25/09/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit
import ObjectMapper

class User: Serializable {
    
    var key: String!
    var nickname: String?
    var email: String?
    var state: String?
    var birthday: NSNumber?
    var country: String?
    var picture: String?
    var gender: String?
    var type: String?
    var countryProgram: String?
    var chatRooms:NSDictionary?
    var contributions:NSNumber?
    var points:NSNumber?
    var stories:NSNumber?
    var polls:NSNumber?
    var pushIdentity:String?
    var publicProfile:NSNumber?
    var born:String?
    var district:String?
    var moderator:NSNumber?
    var masterModerator:NSNumber?
    var socialUid:String?
    
    override init() {
        super.init()
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
