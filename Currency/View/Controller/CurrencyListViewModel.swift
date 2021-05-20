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
    private var subscriptions = Set<AnyCancellable>()

    struct Input {
        let amountValueText: AnyPublisher<String, Never>
        let selectedCountry: UIControl.EventPublisher
        let selectedCurrency = PassthroughSubject<String, Never>()
    }

    struct Output {
        let isInputValid: AnyPublisher<Bool, Never>
        let quotes: AnyPublisher<[QuoteCellViewModel], Never>
    }

    struct Dependencies {
        let api: APIProtocol
        let db: DatabaseProtocol
    }

    private let dependencies: Dependencies
    var apiNetworkActivitySubscriber: AnyCancellable?

    @Published var quotes: [Currency] = []
    @Published var amount: Double = 1
    @Published var currency: String = "USD"
    @Published var quote: Double = 1
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }

    func transform(input: Input) -> Output {
        input.amountValueText.sink(receiveValue: {
            print($0)
        })
        .store(in: &subscriptions)

        input.amountValueText
            .sink(receiveValue: {
                if $0.numberFromString != nil {
                    self.amount = $0.numberFromString!
                }
            })
            .store(in: &subscriptions)

        let isInputValid = input.amountValueText
            .map({
                    return ($0.numberFromString != nil || $0.isEmpty)
            })
            .eraseToAnyPublisher()

        let quotes = Publishers.CombineLatest3($amount, $quotes, $quote).map({ amount, quotes, quote in
            quotes.map({
                QuoteCellViewModel(code: $0.id ?? "", title: $0.country, image: $0.image, value: $0.value * Converter.toUSD(amount: amount, quote: quote), sign: $0.sign)
            })
        }).eraseToAnyPublisher()

        self.quotes = dependencies.db.getQuotes()

        self.$amount.sink(receiveValue: {
            print("Amount: \($0)")
        }).store(in: &subscriptions)

        self.$currency.sink(receiveValue: { value in
            self.quote = self.quotes.filter({
                        quote in quote.country! == value

            }).first?.value ?? 1
        }).store(in: &subscriptions)


        input.selectedCurrency.assign(to: \.currency, on: self).store(in: &subscriptions)

//        apiNetworkActivitySubscriber = API.shared.networkActivityPublisher
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
            }).store(in: &subscriptions)

        return Output(isInputValid: isInputValid, quotes: quotes)
    }

}
