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
        let refresh: PassthroughSubject<Bool, Never>
    }

    struct Output {
        let isInputValid: AnyPublisher<Bool, Never>
        let quotes: AnyPublisher<[QuoteCellViewModel], Never>
        let currencySelection: AnyPublisher<(String?, Data?), Never>
        let metdataText: AnyPublisher<String, Never>
        let loadingState: AnyPublisher<State, Never>
    }

    struct Dependencies {
        let api: APIProtocol
        let db: DatabaseReadable
    }

    private var subscriptions = Set<AnyCancellable>()
    private let dependencies: Dependencies
    private var apiNetworkActivitySubscriber: AnyCancellable?

    @Published private var quotes: [Currency] = []
    @Published private var amount: Double = 1
    @Published private var quote: Double = 1
    @Published private var metadataDate: Date?
    @Published private var loadingState: State = .finished
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

//        self.dependencies.api.list(Database.shared, UserDefaults.standard)
//            .subscribe(on: DispatchQueue.main)
//            .sink(receiveCompletion: { _ in }, receiveValue: { [unowned self] _ in
//                self.quotes = dependencies.db.getQuotes()
//                self.metadataDate = UserDefaults.standard.lastMetaDataDate
//            }).store(in: &subscriptions)


        let metadataText = $metadataDate.map({
            String("\("currency.data".ll) \($0?.string ?? "")")
        }).eraseToAnyPublisher()


        input.refresh.map({ force -> AnyPublisher<CurrencyResponse, Error>  in
            self.loadingState = .loading
            return self.dependencies.api.list(Database.shared, UserDefaults.standard, force)
        })
        .switchToLatest()
        .sink(receiveCompletion: { [weak self] completion in
            print(completion)
            switch completion {
            case .failure(let error):
                if let tooEarly = error as? ServiceError {
                    self?.loadingState = (tooEarly == .tooEarly) ? .finished : .error(error)
                } else {
                    self?.loadingState = .error(error)
                }
            case .finished: self?.loadingState = .finished
            }
        }, receiveValue: { [unowned self] _ in
            self.quotes = dependencies.db.getQuotes()
            self.metadataDate = UserDefaults.standard.lastMetaDataDate
            self.loadingState = .finished
        }).store(in: &subscriptions)

        //input.refresh.send(false)

        let loadingState = $loadingState.eraseToAnyPublisher()

        return Output(isInputValid: isInputValid, quotes: quotes, currencySelection: currencySelection, metdataText: metadataText, loadingState: loadingState)
    }

    enum State {
        case loading
        case finished
        case error(Error)
    }
}
