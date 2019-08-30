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

    // Fetches and returns asynchronously the detailed definition of the Push flow with id flowUuid
    open class func getFlowDefinition(flowUuid: String, completion: @escaping (FCMChannelFlowDefinition?, _ error: Error?) -> Void) {
        RestServices.shared.getFlowDefinition(flowUuid: flowUuid, completion: completion)
    }

    // Fetches and returns asynchronously all Push flows from contact from no longer than one month prior
    open class func getFlowRuns(contactId: String, completion: @escaping ([FCMChannelFlowRun]?, _ error: Error?) -> Void) {
        RestServices.shared.getFlowRuns(contactId: contactId, completion: completion)
    }

    // MARK: - Messages

    // Sends a message through the handler url from the user with the urn sent
    open class func sendReceivedMessage(urn: String, token: String, message: String, completion: @escaping (_ error: Error?) -> Void) {
        RestServices.shared.sendReceivedMessage(urn: urn, token: token, message: message, completion: completion)
    }

    // Fetches and returns asynchronously all messsages between the user with contactId and the channel
    open class func loadMessages(contactId: String, completion: @escaping (_ messages: [FCMChannelMessage]?, _ error: Error?) -> Void ) {
        RestServices.shared.loadMessages(contactId: contactId, completion: completion)
    }

    // Fetches and returns asynchronously the message with the especified messageId
    open class func loadMessageByID(_ messageID: Int, completion: @escaping (_ message: FCMChannelMessage?, _ error: Error?) -> Void) {
        RestServices.shared.loadMessageByID(messageID, completion: completion)
    }

    // MARK: - Contact

    // Fetches and returns asynchronously the message with the especified messageId
    open class func loadContact(fromUrn urn: String, completion: @escaping (_ contact: FCMChannelContact?, _ error: Error?) -> Void) {
        RestServices.shared.loadContact(fromUrn: urn, completion: completion)
    }

    // Fetches and returns asynchronously the contact with the especified uuid
    open class func loadContact(fromUUID uuid: String, completion: @escaping (_ contact: FCMChannelContact?, _ error: Error?) -> Void) {
        RestServices.shared.loadContact(fromUUID: uuid, completion: completion)
    }

    // Fetches and updates the current contact saved
    open class func fetchContact(completion: @escaping (_ error: Error?) -> Void) {
       RestServices.shared.fetchContact(completion: completion)
    }

    // Updates the contact with the especified contactUuid with the given information, or creates a new contact with the information if contactUuid is nil
    open class func registerFCMContact(urn: String, name: String, fcmToken: String, contactUuid: String? = nil, completion: @escaping (_ uuid: String?, _ error: Error?) -> Void) {
        RestServices.shared.registerFCMContact(urn: urn, name: name, fcmToken: fcmToken, contactUuid: contactUuid, completion: completion)
    }

    // MARK: - Language

    // Updates the preferred language in the settings
    open class func savePreferredLanguage(_ language: String) {
        FCMChannelSettings.shared.savePreferedLanguage(language)
    }

    // Returns the language currently set in the settings
    open class func getPreferredLanguage() -> String {
        return FCMChannelSettings.shared.getPreferedLanguage()
    }
}

