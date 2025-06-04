//
//  DreamEx.swift
//  AIDream
//
//  Created by Александра Тажибай on 28.05.2025.
//
import Foundation
import CoreData

extension DreamEntry {
    var interpretationValue: DreamInterpretation? {
        guard let json = interpretation,
              let data = json.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(DreamInterpretation.self, from: data)
    }
    
    func setInterpretation(_ value: DreamInterpretation?) {
        if let value = value, let data = try? JSONEncoder().encode(value) {
            interpretation = String(data: data, encoding: .utf8)
        } else {
            interpretation = nil
        }
    }
}
