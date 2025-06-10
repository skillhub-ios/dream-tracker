//
//  DreamFeeling.swift
//  DreamAI
//
//  Created by Shaxzod on 19/04/25
//

import Foundation

struct DreamFeeling: Identifiable, Hashable {
    let id: UUID = UUID()
    let title: String
    let systemImage: String?
    
    static let all: [DreamFeeling] = [
        DreamFeeling(title: "Vivid", systemImage: nil),
        DreamFeeling(title: "Weird", systemImage: nil),
        DreamFeeling(title: "Emotional", systemImage: nil),
        DreamFeeling(title: "Spiritual", systemImage: nil),
        DreamFeeling(title: "Dark", systemImage: nil),
        DreamFeeling(title: "Symbolic", systemImage: nil),
        DreamFeeling(title: "Lucid", systemImage: nil),
        DreamFeeling(title: "Realistic", systemImage: nil)
    ]
} 