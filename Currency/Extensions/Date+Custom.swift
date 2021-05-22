//
//  Date+Custom.swift
//  Currency
//
//  Created by Matt on 19.05.21.
//

import Foundation

extension Date {

    ///Standard formatter for our date in locale long format
    var string: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        formatter.locale = Locale.current
        let dateString = formatter.string(from: self)
        return dateString
    }
}
