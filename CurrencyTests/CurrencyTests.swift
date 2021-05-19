//
//  CurrencyTests.swift
//  CurrencyTests
//
//  Created by Matt on 19.05.21.
//

import XCTest
@testable import Currency

class CurrencyTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

    func testStringConversion() throws {
        let textInput = "10.00"
        let target = 10.0
        //let quote = 0.821925

        let convertedVal = InputConverter.numberFromString(string: textInput)
        XCTAssertNotNil(convertedVal)
        XCTAssert(target == convertedVal!)
    }

    func testQuoteConversion() throws {
        let amount = 10.0
        let eurQuote = 0.821925
        let result1 = Converter.toUSD(amount: amount, quote: eurQuote)
        XCTAssert(result1 == 12.16656)

        let jpyQuote = 109.13502
        let result2 = jpyQuote*result1
        XCTAssert(result2 == 1327.7978)

    }

}
