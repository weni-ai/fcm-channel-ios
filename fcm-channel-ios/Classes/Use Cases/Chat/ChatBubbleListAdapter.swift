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

        guard let model = self.model else {
            return UICollectionViewCell()
        }

        let nibName = model.fromUser
            ? FCMChannelOutgoingChatMessageViewCell.nibName
            : FCMChannelIncomingChatMessageViewCell.nibName

        let bundle = Bundle(for: (model.fromUser
            ? FCMChannelOutgoingChatMessageViewCell.self
            : FCMChannelIncomingChatMessageViewCell.self).classForCoder())

        guard let cell = collectionContext?.dequeueReusableCell(withNibName: nibName,
                                                                bundle: bundle,
                                                                for: self,
                                                                at: index) else {
                                                                    fatalError("Cell not configured")
        }

        (cell as? FCMChannelChatMessageViewCell)?.setupCell(with: model)
        return cell
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
