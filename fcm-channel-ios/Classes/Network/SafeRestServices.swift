//
//  SafeRestServices.swift
//  fcm-channel-ios
//
//  Created by Alexandre Azevedo on 13/02/20.
//

import Foundation
import Alamofire
import AlamofireObjectMapper
import ObjectMapper

class SafeRestServices: RestServicesProtocol {

    static var shared = SafeRestServices()

    private init() {}

     // MARK: - Flow
    func getFlowDefinition(flowUuid: String, completion: @escaping (FCMChannelFlowDefinition?, _ error: Error?) -> Void) {
        completion(nil, FCMChannelError.safeModeError)
     }

     func getFlowRuns(contactId: String, completion: @escaping ([FCMChannelFlowRun]?, _ error: Error?) -> Void) {
        completion(nil, FCMChannelError.safeModeError)
     }

     // MARK: - Messages
     func sendReceivedMessage(urn: String, token: String, message: String, completion:@escaping (_ error: Error?) -> Void) {
         let handlerUrl = FCMChannelSettings.shared.handlerURL
         let channel = FCMChannelSettings.shared.channel

         var formattedUrn = urn
         if urn.starts(with: "fcm:") {
             formattedUrn = String(formattedUrn.dropFirst(4))
         }

         let params = [
             "from": formattedUrn,
             "msg": message,
             "fcm_token": token
         ]

         let url = "\(handlerUrl)\(channel)/receive/"
         Alamofire.request(url, method: .post, parameters: params).responseString { (response) in

             switch response.result {

             case .failure(let error):
                 print("error \(String(describing: error.localizedDescription))")
                 completion(error)

             case .success(let value):
                 print(value)
                 completion(nil)
             }
         }
     }

     func loadMessages(contactId: String, completion: @escaping (APIResponse<FCMChannelMessage>?, Error?) -> Void) {
         completion(nil, FCMChannelError.safeModeError)
     }

     func loadMessages(contactId: String, pageToken: String?, completion: @escaping (_ messages: APIResponse<FCMChannelMessage>?, _ error: Error?) -> Void ) {
         completion(nil, FCMChannelError.safeModeError)
     }

     func loadMessageByID(_ messageID: Int, completion: @escaping (_ message: FCMChannelMessage?, _ error: Error?) -> Void ) {
        completion(nil, FCMChannelError.safeModeError)
     }

     // MARK: - Contact

     private func loadContact(fromURL url: URL, completion: @escaping (_ contact: FCMChannelContact?, _ error: Error?) -> Void) {
        completion(nil, FCMChannelError.safeModeError)
     }

     func loadContact(fromUUID uuid: String, completion: @escaping (_ contact: FCMChannelContact?, _ error: Error?) -> Void) {
        completion(nil, FCMChannelError.safeModeError)
     }

     func loadContact(fromUrn urn: String, completion: @escaping (_ contact: FCMChannelContact?, _ error: Error?) -> Void) {
        completion(nil, FCMChannelError.safeModeError)
     }

     func fetchContact(completion: @escaping (_ error: Error?) -> Void) {
        completion(FCMChannelError.safeModeError)
     }

     func registerFCMContact(urn: String, name: String, fcmToken: String, completion: @escaping (String?, Error?) -> Void) {
         registerFCMContact(urn: urn, name: name, fcmToken: fcmToken, contactUuid: nil, completion: completion)
     }

     func registerFCMContact(urn: String, name: String, fcmToken: String, contactUuid: String?, completion: @escaping (_ uuid: String?, _ error: Error?) -> Void) {

         let url = "\(FCMChannelSettings.shared.handlerURL)\(FCMChannelSettings.shared.channel)/register/"

         var filteredUrn = urn

         if filteredUrn.hasPrefix("fcm:") {
             filteredUrn = String(filteredUrn.dropFirst(4))
         }

         var params = ["urn": filteredUrn,
                       "name": name,
                       "fcm_token": fcmToken] as [String: Any]

         if let contactUuid = contactUuid {
             params["contact_uuid"] = contactUuid
         }

         Alamofire.request(url, method: .post, parameters: params).responseJSON( completionHandler: { response in

             switch response.result {

             case .failure(let error):
                 print("error \(String(describing: error.localizedDescription))")
                 completion(nil, error)

             case .success(let value):
                 if let response = value as? [String: String], let uuid = response["contact_uuid"] {
                     completion(uuid, nil)
                 } else {
                     completion(nil, nil)
                 }
             }
         })
     }
}
