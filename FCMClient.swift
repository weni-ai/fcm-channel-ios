//
//  FCMClient.swift
//  ureport
//
//  Created by Daniel Amaral on 10/09/15.
//  Copyright (c) 2015 ilhasoft. All rights reserved.
//

import UIKit


open class FCMClient: NSObject {

    static var sendingAnswers: Bool = false

    open class func setup(_ token:String,
                      channel:String,
                      url: String = "https://push.ilhasoft.mobi/api/") {
        FCMChannelSettings.setup(token, channel: channel, url: url)
    }

    // MARK: - Flow
    open class func getFlowDefinition(_ flowUuid: String, completion: @escaping (FCMChannelFlowDefinition?) -> Void) {
        RestServices.shared.getFlowDefinition(flowUuid, completion: completion)
    }

    open class func getFlowRuns(_ contact: FCMChannelContact, completion: @escaping ([FCMChannelFlowRun]?) -> Void) {
        RestServices.shared.getFlowRuns(contact, completion: completion)
    }

    // MARK: - Messages
    open class func sendReceivedMessage(_ contact: FCMChannelContact, message: String, completion: @escaping (_ success: Bool) -> Void) {
         RestServices.shared.sendReceivedMessage(contact, message: message, completion: completion)
    }

    open class func loadMessages(contact: FCMChannelContact, completion: @escaping (_ messages:[FCMChannelMessage]?) -> Void ) {
        RestServices.shared.loadMessages(contact: contact, completion: completion)
    }

    open class func loadMessageByID(_ messageID: Int, completion: @escaping (_ message: FCMChannelMessage?) -> Void ) {
        RestServices.shared.loadMessageByID(messageID, completion: completion)
    }

    // MARK: - Contact
    open class func loadContact(fromUrn urn: String, completion: @escaping (_ contact: FCMChannelContact?) -> Void) {
        RestServices.shared.loadContact(fromUrn: urn, completion: completion)
    }

    open class func fetchContact(completion: @escaping (_ success: Bool, _ error: Error?) -> Void) {
       RestServices.shared.fetchContact(completion: completion)
    }

    open class func registerFCMContact(_ contact: FCMChannelContact, completion: @escaping (_ uuid: String?, _ error: Error?) -> Void) {
        RestServices.shared.registerFCMContact(contact, completion: completion)
    }

    open class func savePreferedLanguage(_ language:String) {
        FCMChannelSettings.shared.savePreferedLanguage(language)
    }

    open class func getPreferedLanguage() -> String {
        return FCMChannelSettings.shared.getPreferedLanguage()
    }
}

