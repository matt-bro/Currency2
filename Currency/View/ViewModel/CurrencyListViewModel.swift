//
//  CurrencyListViewModel.swift
//  Currency
//
//  Created by Matt on 19.05.21.
//

import Foundation
import UIKit
import Combine

final class CurrencyListVCViewModel {

    struct Input {
        //Amount Input textfield text
        let amountValueText: AnyPublisher<String, Never>
        //Opened currency selection
        let selectedCurrency = PassthroughSubject<String, Never>()
        //Refresh our data
        let refresh: PassthroughSubject<Bool, Never>
    }

    struct Output {
        //Is our input valid
        let isInputValid: AnyPublisher<Bool, Never>
        //The quotes that we will display in table
        let quotes: AnyPublisher<[QuoteCellViewModel], Never>
        //after we selected currency
        let currencySelection: AnyPublisher<(String?, Data?), Never>
        //Last update text
        let metdataText: AnyPublisher<String, Never>
        //Our loading state
        let loadingState: AnyPublisher<State, Never>
    }

    struct Dependencies {
        let api: APIProtocol
        let db: Database
    }

    private var subscriptions = Set<AnyCancellable>()
    private let dependencies: Dependencies
    private var apiNetworkActivitySubscriber: AnyCancellable?

    // watch the change for currency selection, new data, new amount
    @Published private var quotes: [Currency] = []
    @Published private var amount: Double = 1
    @Published private var quote: Double = 1

    //Date of our data
    @Published private var metadataDate: Date?
    //Network loading state
    @Published private var loadingState: State = .finished
    //Our initial currency is USD
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
                QuoteCellViewModel(code: $0.id ?? "", title: $0.country, image: $0.image, value: Converter.fromUSDToOther(amount: Converter.toUSD(amount: amount, quote: quote), targetQuote: $0.value), sign: $0.sign)
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

        let metadataText = $metadataDate.map({
            String("\("currency.data".ll) \($0?.string ?? "")")
        }).eraseToAnyPublisher()

        input.refresh.map({ force -> AnyPublisher<CurrencyResponse, Error>  in
            self.loadingState = .loading
            return self.dependencies.api.list(self.dependencies.db, UserDefaults.standard, force)
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

    // This is our network state which we use to display an error text or loading indicator
    enum State {
        case loading
        case finished
        case error(Error)
    }
}
