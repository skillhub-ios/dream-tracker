//
//  ResonanceOption.swift
//  DreamAI
//
//  Created by Shaxzod on 15/06/25.
//

import Foundation

enum ResonanceOption: String, CaseIterable, Identifiable {
    var id: String { self.rawValue }
    
    case yes = "🥲 Yes"
    case aBit = "😐 A bit"
    case notReally = "😶‍🌫️ Not really"
}
