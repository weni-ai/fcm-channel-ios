//
//  RestServicesProtocol.swift
//  Alamofire
//
//  Created by Alexandre Azevedo on 13/02/20.
//

import Foundation

protocol RestServicesProtocol {
    // MARK: - Flow
    func getFlowDefinition(flowUuid: String, completion: @escaping (FCMChannelFlowDefinition?, _ error: Error?) -> Void)
     func getFlowRuns(contactId: String, completion: @escaping ([FCMChannelFlowRun]?, _ error: Error?) -> Void)

     // MARK: - Messages
     func sendReceivedMessage(urn: String, token: String, message: String, completion:@escaping (_ error: Error?) -> Void)

     func loadMessages(contactId: String, pageToken: String?, completion: @escaping (_ messages: APIResponse<FCMChannelMessage>?, _ error: Error?) -> Void )

    func loadMessages(contactId: String, completion: @escaping (_ messages: APIResponse<FCMChannelMessage>?, _ error: Error?) -> Void )

     func loadMessageByID(_ messageID: Int, completion: @escaping (_ message: FCMChannelMessage?, _ error: Error?) -> Void )

     // MARK: - Contact

     func loadContact(fromUUID uuid: String, completion: @escaping (_ contact: FCMChannelContact?, _ error: Error?) -> Void)

     func loadContact(fromUrn urn: String, completion: @escaping (_ contact: FCMChannelContact?, _ error: Error?) -> Void)

     func fetchContact(completion: @escaping (_ error: Error?) -> Void)

     func registerFCMContact(urn: String, name: String, fcmToken: String, completion: @escaping (_ uuid: String?, _ error: Error?) -> Void)

    func registerFCMContact(urn: String, name: String, fcmToken: String, contactUuid: String?, completion: @escaping (_ uuid: String?, _ error: Error?) -> Void)
}
