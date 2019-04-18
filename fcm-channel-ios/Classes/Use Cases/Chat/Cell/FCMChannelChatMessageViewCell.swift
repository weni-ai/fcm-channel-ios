//
//  FCMChannelChatMessageView.swift
//  Pods
//
//  Created by Daniel Amaral on 08/06/16.
//
//

import UIKit
import Atributika
import Reusable

open class FCMChannelChatMessageViewCell: UICollectionViewCell, NibReusable {
    
    @IBOutlet public weak var baloonView: UIView!
    @IBOutlet weak var lbMessage: AttributedLabel!
    @IBOutlet weak var lbUserName: UILabel?
    @IBOutlet public weak var contentMediaView: UIView!
    @IBOutlet weak var bubbleWidthConstraint: NSLayoutConstraint!

    override open func awakeFromNib() {
        super.awakeFromNib()
        baloonView.layer.cornerRadius = 20
        contentMediaView.layer.borderColor = self.baloonView.backgroundColor?.cgColor
        contentMediaView.layer.borderWidth = 3
        lbMessage.numberOfLines = 0
        lbMessage.lineBreakMode = .byTruncatingTail
        lbMessage.font = UIFont(name: "HelveticaNeue", size: 15) ?? UIFont.systemFont(ofSize: 15)
        lbMessage.onClick = didSelect
    }

    func setupCellWithPlayerMediaView() {
//        let playMediaView = CCPlayMediaView(parentViewController: parentViewController, parseMedia: parseMedia, frame: CGRect(x: 0, y: 0, width: contentMediaView.frame.size.width, height: contentMediaView.frame.size.height))
//        self.contentMediaView.addSubview(playMediaView)
    }
    
    open func setupCell(with model: ChatCellViewModel) {

        lbMessage.attributedText = model.text?
            .style(tags: [.foregroundColor(model.msgColor, .normal),
                          .foregroundColor(model.linkColor, .highlighted)])
            .styleLinks(Style
                .foregroundColor(model.linkColor)
                .underlineStyle(.single)
        )

        lbUserName?.text = model.userName
        contentMediaView.isHidden = true
        baloonView.isHidden = false
        baloonView.backgroundColor = model.bubbleColor

    }

    private func didSelect(label: AttributedLabel, detection: Detection) {
        switch detection.type {
        case .link(let url):
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        default:
            break
        }
    }

    func setBubbleWidth(to width: CGFloat) {
        bubbleWidthConstraint.constant = width
        layoutIfNeeded()
    }

    static func size(for model: ChatCellViewModel) -> CGSize {
        let totalCellWidth = UIScreen.main.bounds.width
        let topMargin: CGFloat = 38
        let leftMargin: CGFloat = 27                                                                                                                                                                                                                                                                                               
        let bottomMargin: CGFloat = 34
        let rightMargin: CGFloat = 97
        let contentMaxWidth = totalCellWidth - leftMargin - rightMargin

        let font = UIFont(name: "HelveticaNeue", size: 15)
        let size = getSizeForCell(withString: model.text ?? "",
                                    usingFont: font ?? UIFont.systemFont(ofSize: 15),
                                    maxWidth: contentMaxWidth)

        var height: CGFloat = 0
        height += topMargin
        height += ceil(size.height)
        height += bottomMargin
        return CGSize(width: size.width + leftMargin + rightMargin, height: height)
    }
}
