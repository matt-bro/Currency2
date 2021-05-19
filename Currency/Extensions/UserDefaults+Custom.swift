//
//  UserDefaults+Custom.swift
//  Currency
//
//  Created by Matt on 19.05.21.
//

import Foundation

extension UserDefaults {
    var lastMetaDataDate: Date? {
        get {
            return UserDefaults.standard.object(forKey: "lastMetaDataDate") as? Date
        }
        set(newValue) {
            UserDefaults.standard.set(newValue, forKey: "lastMetaDataDate")
        }
    }

    func shouldUpdateMetaData() -> Bool {
        guard let metaDataDate = lastMetaDataDate else {
            return true
        }
        return metaDataDate < Date().addingTimeInterval(-(30*60))
    }
}
