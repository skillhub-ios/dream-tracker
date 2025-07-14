//
// Date.swift
//
// Created by Cesare on 10.07.2025 on Earth.
//

import Foundation

extension Date {
    var dayMonthYear: String {
        formatted(.dateTime.day().month(.twoDigits).year())
    }
    
    var dateTimeWithSeparator: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short
        
        return "\(dateFormatter.string(from: self)) • \(timeFormatter.string(from: self))"
    }
    
    func formattedWithSpace() -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short
        
        return "\(dateFormatter.string(from: self)) \n\(timeFormatter.string(from: self))"
    }
}
