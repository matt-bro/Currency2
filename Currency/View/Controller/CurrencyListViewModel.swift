//
//  CurrencyListViewModel.swift
//  Currency
//
//  Created by Matt on 19.05.21.
//

import Foundation
import UIKit
import Combine

final class CurrencyViewModel {
    struct Input {
        let amountValueText: AnyPublisher<String, Never>
        let selectedCountry: UIControl.EventPublisher
        let selectedCurrency = PassthroughSubject<String, Never>()
    }

    struct Output {
        let isInputValid: AnyPublisher<Bool, Never>
        let quotes: AnyPublisher<[QuoteCellViewModel], Never>
        let currencySelection: AnyPublisher<(String?, Data?), Never>
        let metdataText: AnyPublisher<String, Never>
    }

    struct Dependencies {
        let api: APIProtocol
        let db: DatabaseProtocol
    }

    private var subscriptions = Set<AnyCancellable>()
    private let dependencies: Dependencies
    private var apiNetworkActivitySubscriber: AnyCancellable?

    @Published private var quotes: [Currency] = []
    @Published private var amount: Double = 1
    @Published private var quote: Double = 1
    @Published private var metadataDate: Date?
    @Published var currency: String = "USD"

    init(dependencies: Dependencies) {
        self.dependencies = dependencies
        self.metadataDate = UserDefaults.standard.lastMetaDataDate
    }

    func transform(input: Input) -> Output {
        input.amountValueText.sink(receiveValue: {
            print($0)
        })
        .store(in: &subscriptions)

        //lets initialize with base data
        self.quotes = dependencies.db.getQuotes()

        //convert the textinput string to a sensible double value
        input.amountValueText
            .sink(receiveValue: {
                if let amount = $0.numberFromString {
                    self.amount = amount
                }
            })
            .store(in: &subscriptions)

        //we want to highlight the textfield if the input is weird e.g. '3,2,.3'
        let isInputValid = input.amountValueText
            .map({
                    return ($0.numberFromString != nil || $0.isEmpty)
            })
            .eraseToAnyPublisher()

        //any change in amount, quote or the quotes array will lead to a recalculation
        let quotes = Publishers.CombineLatest3($amount, $quotes, $quote).map({ amount, quotes, quote in
            quotes.map({
                QuoteCellViewModel(code: $0.id ?? "", title: $0.country, image: $0.image, value: $0.value * Converter.toUSD(amount: amount, quote: quote), sign: $0.sign)
            })
        }).eraseToAnyPublisher()

        //get the quote for selected currency string
        self.$currency.sink(receiveValue: { value in
            self.quote = self.quotes.filter({
                        quote in quote.country! == value
            }).first?.value ?? 1
        }).store(in: &subscriptions)



        input.selectedCurrency
            .assign(to: \.currency, on: self)
            .store(in: &subscriptions)

        //change image and text of selected currency button
        let currencySelection = $currency.map({ value -> (String?, Data?) in
            let q = self.quotes.filter({
                        quote in quote.country! == value
            }).first
            return (q?.country, q?.image)
        }).eraseToAnyPublisher()

//        apiNetworkActivitySubscriber = api.shared.networkActivityPublisher
//                    .receive(on: RunLoop.main)
//                    .sink { doingSomethingNow in
//                        if (doingSomethingNow) {
//                            self.loading.startAnimating()
//                        } else {
//                            self.loading.stopAnimating()
//                        }
//                    }

        self.dependencies.api.list(Database.shared, UserDefaults.standard)
            .subscribe(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in }, receiveValue: { [unowned self] _ in
                self.quotes = dependencies.db.getQuotes()
                self.metadataDate = UserDefaults.standard.lastMetaDataDate
            }).store(in: &subscriptions)


        let metadataText = $metadataDate.map({
            String("\("currency.data".ll) \($0?.string ?? "")")
        }).eraseToAnyPublisher()

        return Output(isInputValid: isInputValid, quotes: quotes, currencySelection: currencySelection, metdataText: metadataText)
    }
}
