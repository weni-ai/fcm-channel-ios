//
//
//  UILabelExtension.swift
//  fcm-channel-ios
//
// Created by Yves Bastos on 05/10/18.
// Copyright © 2018 Ilhasoft. All rights reserved.
//

import UIKit

/**
 Returns the correct height for a label with the string passed as parameter.
 */
func getHeightForCell(withString string: String,
                      usingFont font: UIFont,
                      maxWidth: CGFloat) -> CGFloat {
    return ceil(getSizeForCell(withString: string,
                               usingFont: font,
                               maxWidth: maxWidth).height)
}

/**
 Returns the correct width for a label with the string passed as parameter.
 */
func getWidthForCell(withString string: String,
                     usingFont font: UIFont,
                     maxWidth: CGFloat) -> CGFloat {
    return ceil(getSizeForCell(withString: string,
                               usingFont: font,
                               maxWidth: maxWidth).width)
}

/**
 Calculates the bounding rect of a label using the correct settings for a chat cell (including the fonts, bold text etc.)
 */
func getSizeForCell(withString string: String,
                            usingFont font: UIFont,
                            maxWidth: CGFloat) -> CGRect {
    
    let attributedStringBody = NSMutableAttributedString(string: string)
    attributedStringBody.addAttributes([.font: font],
                                       range: NSRange(location: 0, length: (string as NSString).length))
    let maxSize = CGSize(width: maxWidth, height: 0)
    let labelSize = attributedStringBody.boundingRect(
        with: maxSize,
        options: .usesLineFragmentOrigin,
        context: nil
    )
    return labelSize
}
