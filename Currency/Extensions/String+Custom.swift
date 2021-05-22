//
//  String+Custom.swift
//  Currency
//
//  Created by Matt on 19.05.21.
//

import Foundation

extension String {
    subscript (bounds: CountableClosedRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start...end])
    }

    subscript (bounds: CountableRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start..<end])
    }

    ///Convert a currency amount string e.g. 30.00 to a double value
    var numberFromString: Double? {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.numberStyle = .decimal
        let number = formatter.number(from: self)
        return number?.doubleValue
    }

    //short property to localize strings
    var ll: String {
        return NSLocalizedString(self, comment: "")
    }
}
