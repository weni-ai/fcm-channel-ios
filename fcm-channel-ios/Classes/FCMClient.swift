//
//  FCMClient.swift
//  ureport
//
//  Created by Daniel Amaral on 10/09/15.
//  Copyright (c) 2015 ilhasoft. All rights reserved.
//

import UIKit

public class FCMClient: NSObject {

    static var sendingAnswers: Bool = false

    open class func setup(_ token: String,
                          channel: String,
                          url: String = "https://push.ilhasoft.mobi/api/") {
        FCMChannelSettings.setup(token, channel: channel, url: url)
    }

    // MARK: - Flow
    open class func getFlowDefinition(flowUuid: String, completion: @escaping (FCMChannelFlowDefinition?, _ error: Error?) -> Void) {
        RestServices.shared.getFlowDefinition(flowUuid: flowUuid, completion: completion)
    }

    open class func getFlowRuns(contactId: String, completion: @escaping ([FCMChannelFlowRun]?, _ error: Error?) -> Void) {
        RestServices.shared.getFlowRuns(contactId: contactId, completion: completion)
    }

    // MARK: - Messages
    open class func sendReceivedMessage(urn: String, token: String, message: String, completion: @escaping (_ error: Error?) -> Void) {
        RestServices.shared.sendReceivedMessage(urn: urn, token: token, message: message, completion: completion)
    }

    open class func loadMessages(contactId: String, completion: @escaping (_ messages: [FCMChannelMessage]?, _ error: Error?) -> Void ) {
        RestServices.shared.loadMessages(contactId: contactId, completion: completion)
    }

    open class func loadMessageByID(_ messageID: Int, completion: @escaping (_ message: FCMChannelMessage?, _ error: Error?) -> Void) {
        RestServices.shared.loadMessageByID(messageID, completion: completion)
    }

    // MARK: - Contact
    open class func loadContact(fromUrn urn: String, completion: @escaping (_ contact: FCMChannelContact?, _ error: Error?) -> Void) {
        RestServices.shared.loadContact(fromUrn: urn, completion: completion)
    }

    open class func loadContact(fromUUID uuid: String, completion: @escaping (_ contact: FCMChannelContact?, _ error: Error?) -> Void) {
        RestServices.shared.loadContact(fromUUID: uuid, completion: completion)
    }

    open class func fetchContact(completion: @escaping (_ error: Error?) -> Void) {
       RestServices.shared.fetchContact(completion: completion)
    }

    open class func registerFCMContact(urn: String, name: String, fcmToken: String, contactUuid: String? = nil, completion: @escaping (_ uuid: String?, _ error: Error?) -> Void) {
        RestServices.shared.registerFCMContact(urn: urn, name: name, fcmToken: fcmToken, contactUuid: contactUuid, completion: completion)
    }

    // MARK: - Language
    open class func savePreferedLanguage(_ language: String) {
        FCMChannelSettings.shared.savePreferedLanguage(language)
    }

    open class func getPreferedLanguage() -> String {
        return FCMChannelSettings.shared.getPreferedLanguage()
    }
}

