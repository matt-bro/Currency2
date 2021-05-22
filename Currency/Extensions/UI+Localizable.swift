//
//  UI+Localizable.swift
//  One
//
//  Created by Matt on 17.05.21.
//  Copyright © 2021 Fresenius Netcare GmbH. All rights reserved.
//

import UIKit

//Extension for easier localization via storyboards

/// Extend IB to let us localize via strings
extension UILabel {
    @IBInspectable var localizableText: String? {
        get { return text }
        set(value) {
            if value != nil {
                text = value?.ll
            }
        }
    }
}

/// Extend IB to let us localize via strings
extension UIButton {
    @IBInspectable var localizableText: String? {
        get { return nil }
        set(value) {
            if value != nil {
                setTitle(value?.ll, for: .normal)
            }
        }
   }
}
