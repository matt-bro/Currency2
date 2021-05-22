//
//  UserDefaults+Custom.swift
//  Currency
//
//  Created by Matt on 19.05.21.
//

import Foundation

extension UserDefaults {

    ///Tells us about the last quotes update date
    var lastMetaDataDate: Date? {
        get {
            return UserDefaults.standard.object(forKey: "lastMetaDataDate") as? Date
        }
        set(newValue) {
            UserDefaults.standard.set(newValue, forKey: "lastMetaDataDate")
        }
    }

    ///Did already more than 30 min pass since last update?
    func shouldUpdateMetaData() -> Bool {
        guard let metaDataDate = lastMetaDataDate else {
            return true
        }
        return metaDataDate < Date().addingTimeInterval(-(30*60))
    }
}
