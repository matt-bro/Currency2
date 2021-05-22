//
//  MockAPI.swift
//  Currency
//
//  Created by Matt on 22.05.21.
//

import Foundation
import Combine

class MockAPI: APIProtocol {
    func list(_ database: DatabaseSavable?, _ defaults: UserDefaults?, _ force: Bool) -> AnyPublisher<CurrencyResponse, Error> {
        let  jsonPath = Bundle.main.path(forResource: "initial-data", ofType: "json")

        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .secondsSince1970
            let data = try Data(contentsOf: URL(fileURLWithPath: jsonPath!), options: .mappedIfSafe)
            let jsonResult = try decoder.decode(CurrencyResponse.self, from: data)
            defaults?.lastMetaDataDate = Date()
            return Just(jsonResult).setFailureType(to: Error.self).eraseToAnyPublisher()
        } catch {
            fatalError("could not load")
        }
    }

}
