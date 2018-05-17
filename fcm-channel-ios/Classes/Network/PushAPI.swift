//
//  PushAPI.swift
//  ureport
//
//  Created by Daniel Amaral on 10/09/15.
//  Copyright (c) 2015 ilhasoft. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireObjectMapper
import ObjectMapper

protocol PushAPIDelegate {
    func newMessageReceived(_ message:String)
}

open class PushAPI: NSObject {
    
    var delegate: PushAPIDelegate?
    static var sendingAnswers:Bool = false
    
    static let headers = [
        "Authorization": FCMChannelSettings.shared.token!
    ]
    
    class func getFlowDefinition(_ flowUuid: String, completion:@escaping (FCMChannelFlowDefinition?) -> Void) {
        
        let url = "\(FCMChannelSettings.shared.url!)\(FCMChannelSettings.V2)definitions.json?flow=\(flowUuid)"
        
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
        
        let afterDate = FCMChannelDateUtil.dateFormatter(getMinimumDate())
        let url = "\(FCMChannelSettings.shared.url!)\(FCMChannelSettings.V2)runs.json?contact=\(contact.uuid!)&after=\(afterDate)"
        
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
        if let token = contact.fcmToken, let channel = FCMChannelSettings.shared.channel, let urn = contact.urn, let handlerUrl = FCMChannelSettings.shared.handlerURL {
            let params = [
                "from": urn,
                "msg": message,
                "fcm_token": token
            ]
            
            let url = "\(handlerUrl)/receive/\(channel)/"
            
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
    
    open class func getMessagesFromContact(_ contact: FCMChannelContact, completion: @escaping (_ messages:[FCMChannelMessage]?) -> Void ) {
        
        let url = "\(FCMChannelSettings.shared.url!)\(FCMChannelSettings.V2)messages.json?contact=\(contact.uuid!)"
        
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseObject { (response: DataResponse<FCMChannelMessagesResponse>) in
            
            switch response.result {
                
            case .failure(let error):
                print(error.localizedDescription)
                completion(nil)
                
            case .success(let value):
                if value.results != nil && !value.results!.isEmpty {
                    completion(value.results)
                } else {
                    completion(nil)
                }
                
            }
        }
    }
    
    open class func getMessageByID(_ messageID: Int, completion: @escaping (_ message: FCMChannelMessage?) -> Void ) {
        
        let url = "\(FCMChannelSettings.shared.url!)\(FCMChannelSettings.V2)messages.json?id=\(messageID)"
        
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseObject { (response: DataResponse<FCMChannelMessagesResponse>) in
            
            switch response.result {
                
            case .failure(let error):
                print(error.localizedDescription)
                completion(nil)
                
            case .success(let value):
                if !(value.results?.isEmpty ?? true) {
                    completion(value.results!.first)
                } else {
                    completion(nil)
                }
                
            }
        }
    }
    
    open class func fetchContact(completion: @escaping (_ success:Bool, _ error:Error?) -> Void) {
        guard let contact = FCMChannelContact.current() else {
            completion(false, nil)
            return
        }
        
        let url = "\(FCMChannelSettings.shared.url!)\(FCMChannelSettings.V2)contacts.json?urns=\(contact.urn!)"
        
        Alamofire.request(url, method: .get, headers: headers).responseJSON {
            (response: DataResponse<Any>) in
            
            if let response = response.result.value as? [String: Any] {
                guard let results = response["results"] as? [[String: Any]], results.count > 0 else {
                    completion(false,nil)
                    return
                }
                
                let data = results.first!
                var fcmToken = ""
                
                if let urns = data["urns"] as? [String] {
                    let filtered = urns.filter {($0.contains("fcm"))}
                    if !filtered.isEmpty {
                        fcmToken = String(filtered.first!.dropFirst(4))
                    }
                }
                
                let contact = Mapper<FCMChannelContact>().map(JSONObject: data)!
                contact.fcmToken = fcmToken
                contact.urn = fcmToken
                
                FCMChannelContact.setActive(contact: contact)
                completion(true,nil)
            }else if let error = response.result.error {
                completion(false,error)
            }
        }
    }
    
    open class func registerContact(_ contact: FCMChannelContact, completion: @escaping (_ uuid: String?) -> Void) {
        
        let name = contact.name ?? ""
        let params = ["urn": contact.urn!,
                      "name": name,
                      "fcm_token": contact.fcmToken!] as [String:Any]
        
        Alamofire.request("\(FCMChannelSettings.shared.handlerURL!)/register/\(FCMChannelSettings.shared.channel!)/", method: .post, parameters: params).responseJSON( completionHandler: {
            (response) in
            
            switch response.result {
                
            case .failure(let error):
                print("error \(String(describing: error.localizedDescription))")
                completion(nil)
                
            case .success(let value):
                if let response = value as? [String: String], let uuid = response["contact_uuid"]  {
                    completion(uuid)
                } else {
                    completion(nil)
                }
            }
        })
    }
}

