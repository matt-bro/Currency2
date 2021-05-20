//
//  QuoteCellViewModel.swift
//  Currency
//
//  Created by Matt on 20.05.21.
//

import Foundation
import UIKit

final class QuoteCellViewModel {
    let code: String
    var title: String?
    var image: UIImage?
    let value: Double
    var sign: String?

    var amount: String {
        return "\(sign ?? "") \(String(format: "%.02f", value))"
    }

    init(code: String, title:String?, image: Data?, value:Double, sign: String?) {
        self.code = code
        self.title = title
        if let data = image {
            self.image = UIImage(data: data)
        }
        self.value = value
        self.sign = sign
    }
}
