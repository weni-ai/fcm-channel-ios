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
    
    static var headers: HTTPHeaders {

        let token = FCMChannelSettings.shared.token

        return ["authorization": "token \(token)",
                "Accept": "application/json"]
    }

    // TODO: check groups encoding
    class func saveContact(_ contact: FCMChannelContact, completion:@escaping (FCMChannelContact?, Error?) -> Void) {
        let url = "\(FCMChannelSettings.shared.url)\(FCMChannelSettings.V2)contacts.json?uuid=\(contact.uuid ?? "")"

        let parameters = contact.toDict() as Parameters

        AF.request(url, method: .post,
                   parameters: parameters,
                   encoding: JSONEncoding.default,
                   headers: headers)
            .responseObject { (response: DataResponse<FCMChannelContact>) in

                completion(response.value, response.error)
        }
    }

    class func getFlowDefinition(_ flowUuid: String, completion:@escaping (FCMChannelFlowDefinition?) -> Void) {
        
        let url = "\(FCMChannelSettings.shared.url)\(FCMChannelSettings.V2)definitions.json?flow=\(flowUuid)"
        
        AF.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseObject {
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
        let url = "\(FCMChannelSettings.shared.url)\(FCMChannelSettings.V2)runs.json?contact=\(contact.uuid!)&after=\(afterDate)"
        
        AF.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseObject {
            
            (response: DataResponse<APIResponse<FCMChannelFlowRun>>) in

            switch response.result {
                
            case .failure(let error):
                print(error.localizedDescription)
                completion(nil)
                
            case .success(let value):
                if let results = value.results, !results.isEmpty {
                    completion(value.results)
                } else {
                    completion(nil)
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
    
    class func sendReceivedMessage(_ contact: FCMChannelContact, message: String, completion:@escaping (_ success: Bool) -> Void) {
        if let token = contact.fcmToken, let urn = contact.urn {
            let handlerUrl = FCMChannelSettings.shared.handlerURL
            let channel = FCMChannelSettings.shared.channel

            let params = [
                "from": urn,
                "msg": message,
                "fcm_token": token
            ]
            
            let url = "\(handlerUrl)/receive/\(channel)/"
            
            AF.request(url, method: .post, parameters: params).responseString {
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
    
    open class func loadMessages(contact: FCMChannelContact, completion: @escaping (_ messages:[FCMChannelMessage]?) -> Void ) {
        
        let url = "\(FCMChannelSettings.shared.url)\(FCMChannelSettings.V2)messages.json?contact=\(contact.uuid!)"
        
        AF.request(url, method: .get,
                   encoding: JSONEncoding.default,
                   headers: headers).responseObject { (response: DataResponse<APIResponse<FCMChannelMessage>>) in
            
            switch response.result {
                
            case .failure(let error):
                print(error.localizedDescription)
                completion(nil)
                
            case .success(let value):
                if let results = value.results, !results.isEmpty {
                    completion(value.results)
                } else {
                    completion(nil)
                }
            }
        }
    }
    
    open class func loadMessageByID(_ messageID: Int, completion: @escaping (_ message: FCMChannelMessage?) -> Void ) {

        let url = "\(FCMChannelSettings.shared.url)\(FCMChannelSettings.V2)messages.json?id=\(messageID)"
        
        AF.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseObject { (response: DataResponse<APIResponse<FCMChannelMessage>>) in
            
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

    open class func loadContact(fromUrn urn: String, completion: @escaping (_ contact: FCMChannelContact?) -> Void) {

        let url: URL! = URL(string: "\(FCMChannelSettings.shared.url)\(FCMChannelSettings.V2)contacts.json?urns=\(urn)")

        let request = AF.request(url,
                                 method: .get,
                                 encoding: URLEncoding.default,
                                 headers: headers)
                .responseJSON { (response: DataResponse<Any>) in

            if let response = response.result.value as? [String: Any] {
                guard let results = response["results"] as? [[String: Any]], results.count > 0 else {
                    completion(nil)
                    return
                }

                let firstResult = results.first!
                let uuid = firstResult["uuid"] as! String
                let name = firstResult["name"] as! String
                let contact = FCMChannelContact(urn: urn, name: name, fcmToken: "")
                contact.uuid = uuid
                completion(contact)
            }
        }

        debugPrint(request)
    }
    
    open class func fetchContact(completion: @escaping (_ success:Bool, _ error:Error?) -> Void) {
        guard let contact = FCMChannelContact.current() else {
            completion(false, nil)
            return
        }
        
        let url = "\(FCMChannelSettings.shared.url)\(FCMChannelSettings.V2)contacts.json?urn=fcm:\(contact.urn!)"
        
        AF.request(url, method: .get, headers: headers).responseJSON {
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
                contact.urn = fcmToken
                
                FCMChannelContact.setActive(contact: contact)
                completion(true,nil)
            }else if let error = response.result.error {
                completion(false,error)
            }
        }
    }
    
    open class func registerFCMContact(_ contact: FCMChannelContact, completion: @escaping (_ uuid: String?, _ error: Error?) -> Void) {
        
        let name = contact.name ?? ""
        let params = ["contact_uuid": contact.uuid!,
                      "urn": contact.urn!,
                      "name": name,
                      "fcm_token": contact.fcmToken!] as [String:Any]
        
        AF.request("\(FCMChannelSettings.shared.handlerURL)/register/\(FCMChannelSettings.shared.channel)/", method: .post, parameters: params).responseJSON( completionHandler: { response in
            
            switch response.result {
                
            case .failure(let error):
                print("error \(String(describing: error.localizedDescription))")
                completion(nil, error)
                
            case .success(let value):
                if let response = value as? [String: String], let uuid = response["contact_uuid"]  {
                    completion(uuid, nil)
                } else {
                    completion(nil, nil)
                }
            }
        })
    }
}

