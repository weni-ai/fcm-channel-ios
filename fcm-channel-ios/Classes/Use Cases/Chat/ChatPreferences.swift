//
//  ChatPreferences.swift
//  fcm-channel-ios
//
//  Created by Alexandre Azevedo on 18/04/19.
//

import Foundation
import UIKit

open class ChatPreferences {
    open var incomingBubleMsgColor: UIColor = UIColor(with: "#2F97F8")
    open var outgoingBubleMsgColor: UIColor = .groupTableViewBackground
    open var incomingLabelMsgColor: UIColor = .white
    open var outgoingLabelMsgColor: UIColor = .gray
    open var choiceAnswerButtonColor: UIColor = .white
    open var choiceAnswerBorderColor: CGColor = UIColor.clear.cgColor
    open var buttonHeight: CGFloat = CGFloat(20)
    open var incomingLinkColor: UIColor = .black
    open var outgoingLinkColor: UIColor = .white
    open var buttonTitleColor: UIColor = .gray

    open class func defaultPreferences() -> ChatPreferences {
        return ChatPreferences()
    }
}
