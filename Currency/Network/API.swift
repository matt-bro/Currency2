//
//  Network.swift
//  Currency
//
//  Created by Matt on 19.05.21.
//

import Foundation
import Combine

protocol APIProtocol {
    func list(_ database: Database?, _ defaults: UserDefaults?) -> AnyPublisher<CurrencyResponse, Error>
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

    func list(_ database: Database? = nil, _ defaults: UserDefaults? = nil) -> AnyPublisher<CurrencyResponse, Error> {
        let url = Endpoint.live.url
        return URLSession.shared.dataTaskPublisher(for: url)
            .delay(for: 3, scheduler: RunLoop.main)
            .handleEvents(receiveSubscription: { _ in
                self.networkActivityPublisher.send(true)
                        }, receiveCompletion: { _ in
                            self.networkActivityPublisher.send(false)
                        }, receiveCancel: {
                            self.networkActivityPublisher.send(false)
                        })
            .map(\.data)
            .decode(type: CurrencyResponse.self, decoder: JSONDecoder())
            .handleEvents(receiveOutput: {
                database?.saveQuotes(quotes: $0.quotes)
                defaults?.lastMetaDataDate = Date()
            })
            .eraseToAnyPublisher()
    }
}
