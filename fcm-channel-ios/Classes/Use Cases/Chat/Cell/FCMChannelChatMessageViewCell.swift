//
//  FCMChannelChatMessageView.swift
//  Pods
//
//  Created by Daniel Amaral on 08/06/16.
//
//

import UIKit
import MDHTMLLabel

open class FCMChannelChatMessageViewCell: UITableViewCell, MDHTMLLabelDelegate {
    
    @IBOutlet public var baloonView: UIView!
    @IBOutlet var lbMessage: MDHTMLLabel!
    @IBOutlet var imgUser: UIImageView?
    @IBOutlet var lbUserName: UILabel?
    @IBOutlet var lbSentTime: UILabel!
    @IBOutlet public var contentMediaView: UIView!
    
//    var msgColor: UIColor!
//    var bubbleColor: UIColor!
//    var parentViewController: UIViewController!

    override open func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        baloonView.layer.cornerRadius = 20
        contentMediaView.layer.borderColor = self.baloonView.backgroundColor?.cgColor
        contentMediaView.layer.borderWidth = 3
    }
    
    func setupCellWithPlayerMediaView() {
//        let playMediaView = CCPlayMediaView(parentViewController: parentViewController, parseMedia: parseMedia, frame: CGRect(x: 0, y: 0, width: contentMediaView.frame.size.width, height: contentMediaView.frame.size.height))
//        self.contentMediaView.addSubview(playMediaView)
    }
    
    open func setupCell(with model: ChatCellViewModel) {
        
        lbMessage.htmlText = model.text
        lbUserName?.text = model.userName

        contentMediaView.isHidden = true
        baloonView.isHidden = false

        baloonView.backgroundColor = model.bubbleColor
        lbMessage.textColor = model.msgColor
    }
    
    //MARK: MDHTMLLabelDelegate
    
    open func htmlLabel(_ label: MDHTMLLabel!, didSelectLinkWith URL: Foundation.URL!) {
        UIApplication.shared.open(URL, options: [:], completionHandler: nil)
    }
}
