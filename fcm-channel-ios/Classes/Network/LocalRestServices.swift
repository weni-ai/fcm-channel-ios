//
//  LocalRestServices.swift
//  fcm-channel-ios
//
//  Created by Alexandre Azevedo on 30/08/19.
//

import Foundation

class LocalRestServices: RestServices {

    static var localShared = LocalRestServices()
    private var messages: [FCMChannelMessage] = []

    override init() {
        super.init()

        for index in 0..<50 {
            let message = FCMChannelMessage(msg: "\(index) sdiufhdfhidshf")
            message.id = index
            message.direction = Bool.random() ? FCMChannelMessageDirection.In.rawValue : FCMChannelMessageDirection.Out.rawValue
            messages.insert(message, at: 0)
        }
    }

    override func loadMessages(contactId: String, pageToken: String? = nil, completion: @escaping (_ messages: APIResponse<FCMChannelMessage>?, _ error: Error?) -> Void ) {

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2, execute: {

            guard Double.random(in: 0...1) >= 0.05 else {
                completion(nil, FCMChannelError.defaultError(message: "Erro ao carregar mensagens"))
                return
            }

            let token = Int(pageToken ?? "") ?? 0

            var messages: [FCMChannelMessage] = []

            if token < 10 {
                messages = Array(self.messages[token*5..<(token+1)*5])
            }

            let response = APIResponse<FCMChannelMessage>(results: messages)
            response.next = (token < 10) ? String(token+1) : nil
            completion(response, nil)
        })
    }
}
