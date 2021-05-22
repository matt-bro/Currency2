//
//  Response.swift
//  Currency
//
//  Created by Matt on 19.05.21.
//

import Foundation

struct CurrencyResponse: Decodable {
    var success: Bool
    var terms: String?
    var privacy: String?
    var timestamp: Date?
    var source: String
    var quotes: [String: Double] = [:]
}
