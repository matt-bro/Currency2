//
//  URL+Custom.swift
//  Currency
//
//  Created by Matt on 21.05.21.
//

import Foundation

extension URL {
    ///easiliy append key to url
    func appendAccesKey(key: String) -> URL {
        return self.appending("access_key", value: key)
    }
    ///append query items to url
    func appending(_ queryItem: String, value: String?) -> URL {
        guard var urlComponents = URLComponents(string: absoluteString) else { return absoluteURL }
        var queryItems: [URLQueryItem] = urlComponents.queryItems ??  []
        let queryItem = URLQueryItem(name: queryItem, value: value)
        queryItems.append(queryItem)
        urlComponents.queryItems = queryItems
        return urlComponents.url!
    }
}
