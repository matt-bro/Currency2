//
//  Network.swift
//  Currency
//
//  Created by Matt on 19.05.21.
//

import Foundation
import Combine


protocol APIProtocol {
    func list(_ database: DatabaseSavable?, _ defaults: UserDefaults?, _ force: Bool) -> AnyPublisher<CurrencyResponse, Error>
}

// We handle any network errors with this enum
enum ServiceError: Error, Equatable {
    case url(URLError)
    case urlRequest
    case decode
    case statusCode
    case tooEarly
}

class API: APIProtocol {

    /// Endpoint for our service
    /// Get the urls for our endpoint
    enum Endpoint: String {
        private static let baseUrl = URL(string: "http://api.currencylayer.com/")!
        //access key
        private static let accessKey = "6c16635ecdf56ac38045dded167ee369"

        //live list with all quotes
        case live = "live"

        var url: URL {
            switch self {
            case .live:
                return Endpoint.baseUrl.appendingPathComponent(self.rawValue).appendAccesKey(key: Endpoint.accessKey)
            }
        }
    }

    static let shared = API()
    let networkActivityPublisher = PassthroughSubject<Bool, Never>()

    /// Get a list of quotes from the live service
    ///
    /// - Parameters:
    ///     - database: if provided saves quotes directly to database
    ///     - defaults: if provided saves last update date to defaults
    ///     - force: usually a request can only be performed every 30 min, we can ignore it by force true
    /// - Returns:
    ///     - Decoded quotes or an error

    func list(_ database: DatabaseSavable? = nil, _ defaults: UserDefaults? = nil, _ force: Bool = false) -> AnyPublisher<CurrencyResponse, Error> {

        //check if we are allowed to query
        //is the last update older than 30 min? then don't update
        //if the user pressed refresh then ignore the timing
        if let shouldUpdate = defaults?.shouldUpdateMetaData(), shouldUpdate == false, force == false {
            return Fail(error: ServiceError.tooEarly).eraseToAnyPublisher()
        }

        let url = Endpoint.live.url

        //special encoding for timestamp
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970

        return URLSession.shared.dataTaskPublisher(for: url)
            //wait for 2 secs on purpose just so we see the loading screen
            .delay(for: 2, scheduler: RunLoop.main)
            //inform about network activity
            .handleEvents(receiveSubscription: { _ in
                self.networkActivityPublisher.send(true)
                        }, receiveCompletion: { _ in
                            self.networkActivityPublisher.send(false)
                        }, receiveCancel: {
                            self.networkActivityPublisher.send(false)
                        })
            .tryMap { output in
                guard let response = output.response as? HTTPURLResponse, response.statusCode == 200 else {
                    throw ServiceError.statusCode
                }
                return output.data
            }
            .decode(type: CurrencyResponse.self, decoder: decoder)
            .handleEvents(receiveOutput: {
                database?.saveQuotes(quotes: $0.quotes)
                defaults?.lastMetaDataDate = $0.timestamp
            })
            .eraseToAnyPublisher()
    }
}

