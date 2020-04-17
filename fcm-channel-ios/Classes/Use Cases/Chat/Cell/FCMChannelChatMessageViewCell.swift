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
    
    @IBOutlet weak public var baloonView: UIView!
    @IBOutlet weak var lbMessage: MDHTMLLabel!
    @IBOutlet weak var imgUser: UIImageView?
    @IBOutlet weak var lbUserName: UILabel?
    @IBOutlet weak var lbSentTime: UILabel!
    @IBOutlet weak public var contentMediaView: UIView!
    @IBOutlet weak var imgUserWidth: NSLayoutConstraint?
    
    private let imageSize: CGFloat = 44
    
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
        
        if let image = model.image {
            imgUser?.layer.cornerRadius = (imgUser?.frame.width ?? 0)/2
            imgUser?.image = image
            imgUserWidth?.constant = imageSize
            imgUser?.isHidden = false
        } else {
            imgUserWidth?.constant = 0
            imgUser?.isHidden = true
        }
    }
    
    //MARK: MDHTMLLabelDelegate
    
    open func htmlLabel(_ label: MDHTMLLabel!, didSelectLinkWith URL: Foundation.URL!) {
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(URL, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(URL)
        }
    }
}
