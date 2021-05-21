//
//  CurrencyViewModelTests.swift
//  Currency
//
//  Created by Matt on 21.05.21.
//

import Foundation
import XCTest
import Combine

@testable import Currency

class CurrencyListViewModelTests: XCTestCase {
    
    private var cancellables: Set<AnyCancellable>!

    var textInputPublisher: AnyPublisher<String, Never> {
        textSubject.eraseToAnyPublisher()
    }
    private let textSubject = PassthroughSubject<String, Never>()


    override func setUp() {
        super.setUp()
        cancellables = []
    }

    func testViewModel() {
        let dependencies = CurrencyViewModel.Dependencies(api: API.shared, db: Database.shared)
        let vm =  CurrencyViewModel(dependencies: dependencies)

        let selectedCountry = UIButton().tapPublisher
        let refresh = PassthroughSubject<Bool, Never>()

        let input = CurrencyViewModel.Input(amountValueText: textInputPublisher, selectedCountry: selectedCountry, refresh: refresh)
        let output = vm.transform(input: input)

        let refreshSuccess = self.expectation(description: "refresh triggered")
        output.loadingState.sink(receiveValue: { _ in
            refreshSuccess.fulfill()
        }).store(in: &cancellables)


        let validInput = self.expectation(description: "valid text input")
        output.isInputValid.sink(receiveValue: { isValid in
            XCTAssertTrue(isValid)
            validInput.fulfill()
        }).store(in: &cancellables)
        textSubject.send("1")

        wait(for: [refreshSuccess, validInput], timeout: 10.0)
    }


}
