//
//  URStringExtension.swift
//  ureport
//
//  Created by Daniel Amaral on 03/11/15.
//  Copyright © 2015 ilhasoft. All rights reserved.
//

import UIKit

extension String {

    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }

    init(htmlEncodedString: String) {
        let encodedData = htmlEncodedString.data(using: String.Encoding.utf8)!
        let attributedOptions : [NSAttributedString.DocumentReadingOptionKey: AnyObject] = [
            NSAttributedString.DocumentReadingOptionKey(rawValue: NSAttributedString.DocumentAttributeKey.documentType.rawValue): NSAttributedString.DocumentType.html as AnyObject,
            NSAttributedString.DocumentReadingOptionKey(rawValue: NSAttributedString.DocumentAttributeKey.characterEncoding.rawValue): String.Encoding.utf8 as AnyObject
        ]
        do {
            let attributedString = try NSAttributedString(data: encodedData, options: attributedOptions, documentAttributes: nil)
            self.init(attributedString.string)
            
        }catch {
            self.init()
        }
    }
}
