//
//  CurrencySelectionTVCViewModel.swift
//  Currency
//
//  Created by Matt on 21.05.21.
//

import Foundation
import Combine

final class CurrencySelectionTVCViewModel {

    @Published var selectedCurrency: String? = nil

    struct Dependencies {
        let db: DatabaseReadable
    }
    struct Input {
        let pressedCancel: PassthroughSubject<Void, Never>
    }
    struct Output {
        let quotes: [QuoteCellViewModel]
        let pressedCancel: AnyPublisher<(), Never>
    }

    private let dependencies: Dependencies

    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }

    func transform(input: Input) -> Output {
        let quotes = dependencies.db.getQuotes().map({
            QuoteCellViewModel(code: $0.id ?? "", title: $0.country, image: $0.image, value: $0.value, sign: $0.sign)
        })
        let pressedCancel = input.pressedCancel.eraseToAnyPublisher()

        return Output(quotes: quotes, pressedCancel: pressedCancel)
    }

    func didSelectCurrency(code: String) {
        selectedCurrency = code
    }
}
