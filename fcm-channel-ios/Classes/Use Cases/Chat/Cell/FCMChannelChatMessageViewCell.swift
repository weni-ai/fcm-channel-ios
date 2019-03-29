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
    
    var msgColor:UIColor!
    var bubbleColor:UIColor!
    
    var parentViewController:UIViewController!
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        baloonView.layer.cornerRadius = 20
        self.contentMediaView.layer.borderColor = self.baloonView.backgroundColor?.cgColor
        self.contentMediaView.layer.borderWidth = 3
    }
    
    func setupCellWithPlayerMediaView() {
//        let playMediaView = CCPlayMediaView(parentViewController: parentViewController, parseMedia: parseMedia, frame: CGRect(x: 0, y: 0, width: contentMediaView.frame.size.width, height: contentMediaView.frame.size.height))
//        self.contentMediaView.addSubview(playMediaView)
    }
    
    open func setupCell(with model: ChatCellViewModel) {
        
        lbMessage.htmlText = model.text

        if let userName = model.userName {
            lbUserName?.text = userName
        }

        self.contentMediaView.isHidden = true
        self.baloonView.isHidden = false

        self.baloonView.backgroundColor = model.bubbleColor
        self.lbMessage.textColor = model.msgColor
    }
    
    //MARK: MDHTMLLabelDelegate
    
    open func htmlLabel(_ label: MDHTMLLabel!, didSelectLinkWith URL: Foundation.URL!) {
        UIApplication.shared.openURL(URL)
    }
}
