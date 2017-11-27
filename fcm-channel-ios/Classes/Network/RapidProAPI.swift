//
//  URRapidProManager.swift
//  ureport
//
//  Created by Daniel Amaral on 10/09/15.
//  Copyright (c) 2015 ilhasoft. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireObjectMapper

protocol RapidProAPIDelegate {
    func newMessageReceived(_ message:String)
}

open class RapidProAPI: NSObject {
    
    var delegate: RapidProAPIDelegate?
    static var sendingAnswers:Bool = false
    
    static let headers = [
        "Authorization": FCMChannelSettings.token!
    ]
    
    class func getFlowDefinition(_ flowUuid: String, completion:@escaping (FCMChannelFlowDefinition?) -> Void) {
        
        let url = "\(FCMChannelSettings.url!)\(FCMChannelSettings.V2)definitions.json?flow=\(flowUuid)"
        
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseObject {
            (response: DataResponse<FCMChannelFlowDefinition>) in
            
            switch response.result {
                
            case .failure(let error):
                print(error.localizedDescription)
                completion(nil)
                
            case .success(let value):
                completion(value)
            }
            
        }
    }
    
    class func getFlowRuns(_ contact: FCMChannelContact, completion: @escaping ([FCMChannelFlowRun]?) -> Void) {
        
        let afterDate = FCMChannelDateUtil.dateFormatterRapidPro(getMinimumDate())
        let url = "\(FCMChannelSettings.url!)\(FCMChannelSettings.V2)runs.json?contact=\(contact.uuid!)&after=\(afterDate)"
        
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseObject {
            
            (response: DataResponse<FCMChannelFlowRunResponse>) in
            
            switch response.result {
                
            case .failure(let error):
                print(error.localizedDescription)
                completion(nil)
                
            case .success(let value):
                if value.results != nil && value.results.count > 0 {
                    completion(value.results)
                }
            }
        }
    }
    
    class func getMinimumDate() -> Date {
        let date = Date()
        let gregorian = Calendar(identifier: Calendar.Identifier.gregorian)
        var offsetComponents = DateComponents();
        offsetComponents.month = -1;
        return (gregorian as NSCalendar).date(byAdding: offsetComponents, to: date, options: [])!;
    }
    
    class func sendMessage(_ contact: FCMChannelContact, message: String, completion:@escaping (_ success: Bool) -> Void) {
        if let token = FCMChannelSettings.token, let channel = FCMChannelSettings.channel, let urn = contact.urn, let handlerUrl = FCMChannelSettings.handlerURL {
            let params = [
                "from": urn,
                "msg": message,
                "fcm_token": token
            ]
            
            let url = "\(handlerUrl)/receive/\(channel)"
            
            Alamofire.request(url, method: .post, parameters: params).responseString {
                (response) in
                
                switch response.result {
                    
                case .failure(let error):
                    print("error \(String(describing: error.localizedDescription))")
                    completion(false)
                    
                case .success(let value):
                    print(value)
                    completion(true)
                }
            }
        }
    }
    
    class func sendReceivedMessage(_ contactKey:String, text:String) {
        let url = FCMChannelSettings.url!
        let parameters = [
            "from": contactKey,
            "text": text
        ]
        Alamofire.request(url, method: .post, parameters: parameters)
    }
    
    class func getContactFields(_ completion: @escaping ([String]?) -> Void) {
        Alamofire.request("\(FCMChannelSettings.url!)\(FCMChannelSettings.V1)fields.json", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response: DataResponse<Any>) in
            if let response = response.result.value as? NSDictionary {
                var arrayFields:[String] = []
                if let results = response.object(forKey: "results") as? [NSDictionary] {
                    
                    for dictionary in results {
                        arrayFields.append(dictionary.object(forKey: "key") as! String)
                    }
                    completion(arrayFields)
                } else {
                    completion(arrayFields)
                }
            }
        }
    }
    
    open class func getMessagesFromContact(_ contact: FCMChannelContact, completion: @escaping (_ messages:[FCMChannelMessage]?) -> Void ) {
        
        let url = "\(FCMChannelSettings.url!)\(FCMChannelSettings.V2)messages.json?contact=\(contact.uuid!)"
        
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseObject { (response: DataResponse<FCMChannelMessagesResponse>) in
            
            switch response.result {
                
            case .failure(let error):
                print(error.localizedDescription)
                completion(nil)
                
            case .success(let value):
                if value.results != nil && !value.results.isEmpty {
                    completion(value.results)
                } else {
                    completion(nil)
                }
                
            }
        }
    }
    
    open class func getMessageByID(_ messageID: Int, completion: @escaping (_ message: FCMChannelMessage?) -> Void ) {
        
        let url = "\(FCMChannelSettings.url!)\(FCMChannelSettings.V2)messages.json?id=\(messageID)"
        
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseObject { (response: DataResponse<FCMChannelMessagesResponse>) in
            
            switch response.result {
                
            case .failure(let error):
                print(error.localizedDescription)
                completion(nil)
                
            case .success(let value):
                if !value.results.isEmpty {
                    completion(value.results.first)
                } else {
                    completion(nil)
                }
                
            }
        }
    }
    
    open class func saveContact(_ contact: FCMChannelContact, groups:[String], includeCustomFieldsAndValues:[[String:AnyObject]]?, completion: @escaping (_ response: NSDictionary) -> Void) {
        
        FCMChannelRapidProContactUtil.buildRapidProContactRootDictionary(contact, groups: groups, includeCustomFieldsAndValues: includeCustomFieldsAndValues) {
            (rootDicionary) in
            
            Alamofire.request("\(FCMChannelSettings.url!)\(FCMChannelSettings.V1)contacts.json", method: .post, parameters: rootDicionary.copy() as! [String : AnyObject] , encoding: JSONEncoding.default, headers: headers).responseJSON(completionHandler: {
                (response:DataResponse<Any>) in
                
                if let response = response.result.value {
                    completion(response as! NSDictionary)
                }
            })
        }
    }
    
    open class func loadContact(fromUrn urn: String, completion: @escaping (_ contact: FCMChannelContact?) -> Void) {
        let url = "\(FCMChannelSettings.url!)\(FCMChannelSettings.V1)contacts.json?urns=\(urn)"
        
        let headers = [
            "Authorization": FCMChannelSettings.token!
        ]
        
        Alamofire.request(url, method: .get, headers: headers).responseJSON {
            (response: DataResponse<Any>) in
            
            if let response = response.result.value as? [String: Any] {
                guard let results = response["results"] as? [[String: Any]], results.count > 0 else {
                    completion(nil)
                    return
                }
                
                let firstResult = results.first!
                let uuid = firstResult["uuid"] as! String
                let name = firstResult["name"] as! String
                var contact = FCMChannelContact(urn: urn, name: name, fcmToken: "")
                contact.uuid = uuid
                
                completion(contact)
            }
        }
    }
    
    open class func registerContact(_ contact: FCMChannelContact, completion: @escaping (_ uuid: String?) -> Void) {
        
        var params = ["urn": contact.urn!,
                      "fcm_token": contact.fcmToken!]
        
        Alamofire.request("\(FCMChannelSettings.handlerURL!)/register/\(FCMChannelSettings.channel!)", method: .post, parameters: params).responseJSON( completionHandler: {
            (response) in
            
            switch response.result {
                
            case .failure(let error):
                print("error \(String(describing: error.localizedDescription))")
                completion(nil)
                
            case .success(let value):
                if let response = value as? [String: String] {
                    if let uuid = response["contact_uuid"] {
                        completion(uuid)
                    }
                } else {
                    completion(nil)
                }
            }
        })
    }
}

