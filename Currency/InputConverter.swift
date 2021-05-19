//
//  InputConverter.swift
//  Currency
//
//  Created by Matt on 19.05.21.
//

import Foundation

class InputConverter {

    static func numberFromString(string: String?) -> Double? {
        guard let string = string else {
            return nil
        }
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.numberStyle = .decimal
        let number = formatter.number(from: string)
        return number?.doubleValue
    }
}
