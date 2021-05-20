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

        let quotes = self.$amount.combineLatest($quotes).map({ amount, quotes in
            quotes.map({
                QuoteCellViewModel(code: $0.id ?? "", title: $0.country, image: $0.image, value: $0.value * amount, sign: $0.sign)
            })
        }).eraseToAnyPublisher()

        self.quotes = dependencies.db.getQuotes()

        self.$amount.sink(receiveValue: {
            print("Amount: \($0)")
        }).store(in: &subscriptions)

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
