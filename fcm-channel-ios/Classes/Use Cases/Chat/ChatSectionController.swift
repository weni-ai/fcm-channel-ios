//
//  ChatBubbleListAdapter.swift
//  fcm-channel-ios
//
//  Created by Alexandre Azevedo on 04/04/19.
//

import Foundation
import IGListKit

class ChatSectionController: ListSectionController {

    private var model: ChatCellViewModel?
    private var size: CGSize?

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
        (cell as? FCMChannelChatMessageViewCell)?.setBubbleWidth(to: size?.width ?? 0)
        return cell
    }

    override func sizeForItem(at index: Int) -> CGSize {

        guard let model = self.model else {
            return CGSize.zero
        }

        let size = FCMChannelChatMessageViewCell.size(for: model)
        self.size = size
        return CGSize(width: UIScreen.main.bounds.width, height: size.height)
    }

    override func didUpdate(to object: Any) {
        self.model = object as? ChatCellViewModel
    }
}
