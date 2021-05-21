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

enum ServiceError: Error {
    case url(URLError)
    case urlRequest
    case decode
    case statusCode
    case tooEarly
}

class API: APIProtocol {
    #warning("fix this")
    enum Endpoint: String {
        static let baseUrl = URL(string: "http://api.currencylayer.com/")!
        private static let accessKey = "access_key=6c16635ecdf56ac38045dded167ee369"
        case live = "http://api.currencylayer.com/live"

        var url: URL {
                    switch self {
                    case .live:
                        return URL(string:"\(Endpoint.baseUrl.absoluteString)live?\(Endpoint.accessKey)")!

                }
        }
    }

    static let shared = API()
    let networkActivityPublisher = PassthroughSubject<Bool, Never>()

    func list(_ database: DatabaseSavable? = nil, _ defaults: UserDefaults? = nil, _ force: Bool = false) -> AnyPublisher<CurrencyResponse, Error> {

        //check if we are allowed to query
        //is the last update older than 30 min? then don't update
        //if the user pressed refresh then ignore the timing
        if let shouldUpdate = defaults?.shouldUpdateMetaData(), shouldUpdate == false {
            return Fail(error: ServiceError.tooEarly).eraseToAnyPublisher()
        }


        let url = Endpoint.live.url
        return URLSession.shared.dataTaskPublisher(for: url)
            .delay(for: 2, scheduler: RunLoop.main)
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
            .decode(type: CurrencyResponse.self, decoder: JSONDecoder())
            .handleEvents(receiveOutput: {
                database?.saveQuotes(quotes: $0.quotes)
                defaults?.lastMetaDataDate = $0.timestamp
            })
            .eraseToAnyPublisher()
    }
}
