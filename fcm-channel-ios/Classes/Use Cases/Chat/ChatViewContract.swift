//
//  ChatViewContract.swift
//  Alamofire
//
//  Created by Alexandre Azevedo on 28/03/19.
//

import Foundation

protocol ChatViewContract: AnyObject {
    func setLoading(to active: Bool)
    func addQuickRepliesOptions(_ quickReplies: [FCMChannelQuickReply])
    func update(with models: [ChatCellViewModel])
    func setCurrentRulesets(rulesets: FCMChannelFlowRuleset)
    func scrollToBottom(_ animated: Bool)
}
