//
//  FCMCache.swift
//  fcm-channel-ios
//
//  Created by Alexandre Azevedo on 16/04/20.
//

import Foundation

open class FCMCache {
    private static var messages: [FCMChannelMessage] = []
    
    open class func addMessage(_ message: FCMChannelMessage) {
        guard (message.id == nil || !messages.contains(where: {$0.id == message.id})) else { return }
        messages.append(message)
    }
    
    open class func addMessages(_ messages: [FCMChannelMessage]) {
        for message in messages {
            addMessage(message)
        }
    }
    
    open class func clear() {
        messages = []
    }
    
    open class func getMessages() -> [FCMChannelMessage] {
        return messages
    }
    
    open class func getLastMessage() -> FCMChannelMessage? {
        return messages.last
    }
}
