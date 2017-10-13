//
//  F2NChatMessageCell.swift
//  Fight2Night
//
//  Created by Dielson Sales on 21/10/16.
//  Copyright © 2016 Ilhasoft. All rights reserved.
//

import UIKit

open class FCMChannelIncomingChatMessageViewCell: FCMChannelChatMessageViewCell {

    override open func awakeFromNib() {
        super.awakeFromNib()
        self.contentMediaView.layer.borderColor = self.baloonView.backgroundColor?.cgColor
        self.contentMediaView.layer.borderWidth = 3
    }
}
