//
//  DataStore.swift
//  Currency
//
//  Created by Matt on 19.05.21.
//

import Foundation

protocol Store {
    func update()
}

class DataStore: Store {
    @Published var quotes: [Currency] = []

    var selectedCurrency = ("EUR", 0.821925);

    var amount:Double = 1
    var amountUSD:Double {
        Converter.toUSD(amount: amount, quote: selectedCurrency.1)
    }

    @Published var lastUpdate:Date?

    func update() {
        //perform network request
        //write to database
        //get relevant data

        let quotes = Database.shared.getQuotes()
        self.quotes = quotes

        self.lastUpdate = UserDefaults.standard.lastMetaDataDate
    }
}

class DummyStore: Store {
    func update() {
        //simulate network request
        //write to dummy db
        //get relevant data
    }
}


extension Currency {
    func quote(amount: Double) -> Double {
        return value * amount
    }

    func toUSD(amount: Double) -> Double {
        amount/value
    }
}


class Converter {
    static func toUSD(amount: Double, quote: Double) -> Double {
        amount/quote
    }
}
