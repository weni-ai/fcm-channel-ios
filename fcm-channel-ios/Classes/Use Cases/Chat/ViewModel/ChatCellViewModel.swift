//
//  ChatCellViewModel.swift
//  fcm-channel-ios
//
//  Created by Alexandre Azevedo on 29/03/19.
//

import Foundation
import IGListKit

open class ChatCellViewModel: ListDiffable {
    public func diffIdentifier() -> NSObjectProtocol {
        return key as NSObjectProtocol
    }

    public func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        return key == (object as? ChatCellViewModel)?.key
    }

    let key: Int
    let msgColor: UIColor
    let bubbleColor: UIColor
    let userName: String?
    let text: String?
    let fromUser: Bool

    public init(key: Int,
                msgColor: UIColor,
                bubbleColor: UIColor,
                userName: String?,
                text: String?,
                fromUser: Bool) {
        self.msgColor = msgColor
        self.bubbleColor = bubbleColor
        self.userName = userName
        self.text = text
        self.fromUser = fromUser
    }
}
