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

class Converter {
    static func toUSD(amount: Double, quote: Double) -> Double {
        guard amount > 0, quote > 0 else {
            return 0
        }
        return amount/quote
    }

    static func fromUSDToOther(amount: Double, targetQuote quote: Double) -> Double {
        guard amount > 0, quote > 0 else {
            return 0
        }
        return amount*quote
    }
}
