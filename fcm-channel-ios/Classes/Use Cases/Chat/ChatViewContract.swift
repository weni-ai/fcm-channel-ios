//
//  ChatViewContract.swift
//  Alamofire
//
//  Created by Alexandre Azevedo on 28/03/19.
//

import Foundation

protocol ChatViewContract: AnyObject {
    func addRow()
    func addRow(scroll: Bool?)
    func setLoading(to active: Bool)
    func addQuickRepliesOptions(_ quickReplies: [FCMChannelQuickReply])
    func update(with models: [ChatCellViewModel])
    func setCurrentRulesets(rulesets: FCMChannelFlowRuleset)
}
