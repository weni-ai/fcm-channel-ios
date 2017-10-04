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

protocol ISPushManagerDelegate {
    func newMessageReceived(_ message:String)
}

open class ISPushManager: NSObject {
    
    var delegate:ISPushManagerDelegate?
    static var sendingAnswers:Bool = false
    
    static let headers = [
        "Authorization": ISPushSettings.token!
    ]
    
    class func getFlowDefinition(_ flowUuid: String, completion:@escaping (ISPushFlowDefinition) -> Void) {
        
        let url = "\(ISPushSettings.url!)\(ISPushSettings.V1)flow_definition.json?uuid=\(flowUuid)"
        
        Alamofire.request(url, method: .get ,parameters: nil, encoding: JSONEncoding.default, headers: headers).responseObject { (response: DataResponse<ISPushFlowDefinition>) in
            if let flowDefinition = response.result.value , flowDefinition.entry != nil{
                completion(flowDefinition)
            } else {
                print("Flow definition com estrutura incorreta")
            }
        }
    }
    
    class func getFlowRuns(_ contact: ISPushContact, completion:@escaping ([ISPushFlowRun]?) -> Void) {
        
        let afterDate = ISPushDateUtil.dateFormatterRapidPro(getMinimumDate())
        let url = "\(ISPushSettings.url!)\(ISPushSettings.V2)runs.json?contact=\(contact.uuid!)&after=\(afterDate)"
        
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseObject {
            
            (response: DataResponse<ISPushFlowRunResponse>) in
            
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
    
    class func sendMessage(_ contact: ISPushContact, message: String, completion:@escaping (_ success: Bool) -> Void) {
        if let token = ISPushSettings.token, let channel = ISPushSettings.channel, let urn = contact.urn, let handlerUrl = ISPushSettings.handlerURL {
            let params = [
                "from": urn,
                "msg": message,
                "fcm_token": token
            ]
            
            let url = "\(handlerUrl)receive/\(channel)"
            
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
    
    class func sendRulesetResponses(_ contact:ISPushContact, responses:[ISPushRulesetResponse], completion:@escaping () -> Void) {
        let token = ISPushSettings.token
        let channel = ISPushSettings.channel
        
        let url = "\(ISPushSettings.handlerURL!)receive/\(ISPushSettings.channel!)"
        
        let group = DispatchGroup();
        let queue = DispatchQueue(label: "in.ureport-poll-responses", attributes: []);
        
        self.sendingAnswers = true
        
        for response in responses {
            queue.async(group: group, execute: { () -> Void in
                let request = NSMutableURLRequest(url: URL(string: url)!)
                request.httpMethod = "POST"
                request.setValue(token!, forHTTPHeaderField: "Authorization")
                request.timeoutInterval = 15
                
                let postString = "from=\(contact.pushIdentity!)&msg=\(response.response!)"
                request.httpBody = postString.data(using: String.Encoding.utf8)
                var httpResponse: URLResponse?
                
                do {
                    try NSURLConnection.sendSynchronousRequest(request as URLRequest, returning: &httpResponse)
                    print("Sent: \(response.response!)")
                } catch {
                    print("Error on sending poll response")
                }
                Thread.sleep(forTimeInterval: 1.2)
            })
        }
        group.notify(queue: queue) { () -> Void in
            self.sendingAnswers = false
            completion()
        }
    }
    
    class func sendReceivedMessage(_ contactKey:String, text:String) {
        let url = ISPushSettings.url!
        let parameters = [
            "from": contactKey,
            "text": text
        ]
        Alamofire.request(url, method: .post, parameters: parameters)
    }
    
    class func getContactFields(_ completion:@escaping ([String]?) -> Void) {
        Alamofire.request("\(ISPushSettings.url!)\(ISPushSettings.V1)fields.json", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response: DataResponse<Any>) in
            if let response = response.result.value as? NSDictionary {
                var arrayFields:[String] = []
                if let results = response.object(forKey: "results") as? [NSDictionary] {
                    
                    for dictionary in results {
                        arrayFields.append(dictionary.object(forKey: "key") as! String)
                    }
                    completion(arrayFields)
                }else {
                    completion(arrayFields)
                }
            }
        }
    }
    
    open class func getMessagesFromContact(_ contact: ISPushContact, completion: @escaping (_ messages:[ISPushMessage]?) -> Void ) {
        
        let url = "\(ISPushSettings.url!)\(ISPushSettings.V2)messages.json?contact=\(contact.uuid!)"
        
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseObject { (response: DataResponse<ISPushMessagesResponse>) in
            if let response = response.result.value {
                if response.results != nil && !response.results.isEmpty {
                    completion(response.results)
                }else{
                    completion(nil)
                }
            } else {
                print(response.result.error)
            }
        }
    }
    
    open class func getMessageByID(_ messageID: Int, completion: @escaping (_ message: ISPushMessage?) -> Void ) {
        
        let url = "\(ISPushSettings.url!)\(ISPushSettings.V2)messages.json?id=\(messageID)"
        
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseObject { (response: DataResponse<ISPushMessagesResponse>) in
            if let response = response.result.value {
                if !response.results.isEmpty {
                    completion(response.results[0])
                } else {
                    completion(nil)
                }
            }else{
                print(response.result.error)
            }
        }
    }
    
    open class func saveContact(_ contact:ISPushContact,groups:[String],includeCustomFieldsAndValues:[[String:AnyObject]]?,completion:@escaping (_ response:NSDictionary) -> Void) {
        ISPushRapidProContactUtil.buildRapidProContactRootDictionary(contact, groups: groups, includeCustomFieldsAndValues: includeCustomFieldsAndValues) { (rootDicionary) in
            Alamofire.request("\(ISPushSettings.url!)\(ISPushSettings.V1)contacts.json", method: .post, parameters: rootDicionary.copy() as! [String : AnyObject] , encoding: JSONEncoding.default, headers: headers).responseJSON(completionHandler: { (response:DataResponse<Any>) in
                if let response = response.result.value {
                    completion(response as! NSDictionary)
                }
            })
        }
    }
    
    open class func loadContact(fromUrn urn: String, completion: @escaping (_ contact: ISPushContact?) -> Void) {
        let url = "\(ISPushSettings.url!)\(ISPushSettings.V1)contacts.json?urns=\(urn)"
        let headers = [
            "Authorization": ISPushSettings.token!
        ]
        Alamofire.request(url, method: .get, headers: headers).responseJSON { (response: DataResponse<Any>) in
            if let response = response.result.value as? [String: Any] {
                guard let results = response["results"] as? [[String: Any]], results.count > 0 else {
                    completion(nil)
                    return
                }
                let firstResult = results.first!
                let uuid = firstResult["uuid"] as! String
                let name = firstResult["name"] as! String
                var pushContact = ISPushContact(urn: urn, name:name, pushIdentity: "")
                pushContact.uuid = uuid
                
                completion(pushContact)
            }
        }
    }
    
    open class func registerContact(_ contact: ISPushContact, completion: @escaping (_ uuid: String?) -> Void) {
        
        var params = ["urn": contact.urn!,
                      "fcm_token": contact.pushIdentity!]
        
        if let name = contact.name {
            params["name"] = name
        }
        
        Alamofire.request("\(ISPushSettings.handlerURL!)/register/\(ISPushSettings.channel!)", method: .post, parameters: params).responseJSON(completionHandler: {
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

