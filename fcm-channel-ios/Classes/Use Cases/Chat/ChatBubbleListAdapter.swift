//
//  ChatBubbleListAdapter.swift
//  fcm-channel-ios
//
//  Created by Alexandre Azevedo on 04/04/19.
//

import Foundation
import IGListKit

class ChatBubbleListAdapter: ListSectionController {

    private var model: ChatCellViewModel?

    init(model: ChatCellViewModel) {
        super.init()
        self.model = model
    }

    override func cellForItem(at index: Int) -> UICollectionViewCell {

        var cell: FCMChannelChatMessageViewCell?

        guard let model = self.model else {
            return UICollectionViewCell()
        }

        if model.fromUser {
            cell = collectionContext?.dequeueReusableCell(withNibName: FCMChannelOutgoingChatMessageViewCell.nibName,
                                                          bundle: nil,
                                                          for: self,
                                                          at: index) as? FCMChannelOutgoingChatMessageViewCell

        } else {
            cell = collectionContext?.dequeueReusableCell(withNibName: FCMChannelIncomingChatMessageViewCell.nibName,
                                                          bundle: nil,
                                                          for: self,
                                                          at: index) as? FCMChannelIncomingChatMessageViewCell
        }

        cell?.setupCell(with: model)
        return cell ?? UICollectionViewCell()
    }

    override func sizeForItem(at index: Int) -> CGSize {

        guard let model = self.model else {
            return CGSize.zero
        }

        let height = FCMChannelChatMessageViewCell.height(for: model)
        return CGSize(width: UIScreen.main.bounds.width, height: height)
    }

    override func didUpdate(to object: Any) {
        self.model = object as? ChatCellViewModel
    }
}
