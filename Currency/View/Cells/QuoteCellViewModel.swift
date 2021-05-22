//
//  QuoteCellViewModel.swift
//  Currency
//
//  Created by Matt on 20.05.21.
//
import UIKit

final class QuoteCellViewModel {
    //currency code
    let code: String
    //main title
    var title: String?
    //currency image
    var image: UIImage?
    //amount
    let value: Double
    // currency sign
    var sign: String?

    //displayed amount for our quote should be in format e.g. $ 10.00
    //this is the formatted amount 
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
