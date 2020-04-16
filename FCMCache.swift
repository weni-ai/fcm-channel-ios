//
//  FCMCache.swift
//  fcm-channel-ios
//
//  Created by Alexandre Azevedo on 16/04/20.
//

import Foundation

class FCMCache {
    private static var messages: [FCMChannelMessage] = []
    private static var lastMessage: FCMChannelMessage?
    
    static func addMessage(_ message: FCMChannelMessage) {
        messages.append(message)
    }
    
    static func addMessages(_ messages: [FCMChannelMessage]) {
        FCMCache.messages.append(contentsOf: messages)
    }
    
    static func clear() {
        messages = []
        lastMessage = nil
    }
    
    static func getMessages() -> [FCMChannelMessage] {
        return messages
    }
    
    static func addLastMessage(_ message: FCMChannelMessage) {
        lastMessage = message
    }
    
    static func getLastMessage() -> FCMChannelMessage? {
        return lastMessage
    }
}
