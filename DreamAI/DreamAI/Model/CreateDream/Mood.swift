//
//  Mood.swift
//  DreamAI
//
//  Created by Shaxzod on 14/06/25.
//

import Foundation

struct Mood: Equatable, Hashable, Identifiable {
    
    let id: UUID = UUID()
    let title: String
    let emoji: String
    
    static let happy = Mood(title: "Happy", emoji: "😊")
    static let calm = Mood(title: "Calm", emoji: "😌")
    static let anxious = Mood(title: "Anxious", emoji: "😌")
    static let angry = Mood(title: "Angry", emoji: "😠")
    static let sad = Mood(title: "Sad", emoji: "😢")
    static let inLove = Mood(title: "In Love", emoji: "😍")
    static let stressed = Mood(title: "Stressed", emoji: "😵‍💫")
    
    static let predefined: [Mood] = [.happy, .calm, .anxious, .angry, .sad, .inLove, .stressed]
    
}
