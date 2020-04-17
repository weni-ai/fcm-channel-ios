//
//  FCMCache.swift
//  fcm-channel-ios
//
//  Created by Alexandre Azevedo on 16/04/20.
//

import Foundation

open class FCMCache {
    private static var messages: [FCMChannelMessage] = []
    private static var lastMessage: FCMChannelMessage?
    
    open class func addMessage(_ message: FCMChannelMessage) {
        messages.append(message)
    }
    
    open class func addMessages(_ messages: [FCMChannelMessage]) {
        FCMCache.messages.append(contentsOf: messages)
    }
    
    open class func clear() {
        messages = []
        lastMessage = nil
    }
    
    open class func getMessages() -> [FCMChannelMessage] {
        return messages
    }
    
    open class func addLastMessage(_ message: FCMChannelMessage) {
        lastMessage = message
    }
    
    open class func getLastMessage() -> FCMChannelMessage? {
        return lastMessage
    }
}
