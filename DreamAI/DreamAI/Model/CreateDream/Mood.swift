//
//  Mood.swift
//  DreamAI
//
//  Created by Shaxzod on 14/06/25.
//

import Foundation

enum Mood: String, CaseIterable {
    case happy = "Happy"
    case calm = "Calm"
    case anxious = "Anxious"
    case angry = "Angry"
    case sad = "Sad"
    case inLove = "In Love"
    case stressed = "Stressed"
    
    var emoji: String {
        return switch self {
        case .happy: "😊"
        case .calm: "😌"
        case .anxious: "😰"
        case .angry: "😠"
        case .sad: "😢"
        case .inLove: "😍"
        case .stressed: "😵‍💫"
        }
    }
    
    init?(emoji: String) {
        if let mood = Mood.allCases.first(where: { $0.emoji == emoji }) {
            self = mood
        } else {
            return nil
        }
    }
}
