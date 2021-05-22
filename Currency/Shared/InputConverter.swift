//
//  InputConverter.swift
//  Currency
//
//  Created by Matt on 19.05.21.
//

import Foundation

class Converter {

    ///Convert to USD by a custom quote
    /// - Parameters:
    ///     - amount
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
