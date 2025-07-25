//
//  Mood.swift
//  DreamAI
//
//  Created by Shaxzod on 14/06/25.
//

import SwiftUI

struct Mood: Equatable, Hashable, Identifiable {
    let id: UUID = UUID()
    let title: String
    let emoji: String
    let isDefault: Bool
    
    var displayName: String {
        return isDefault ? NSLocalizedString(title, comment: "") : title
    }
    
    static let happy = Mood(title: "happy", emoji: "😊", isDefault: true)
    static let calm = Mood(title: "calm", emoji: "😌", isDefault: true)
    static let anxious = Mood(title: "anxious", emoji: "😌", isDefault: true)
    static let angry = Mood(title: "angry", emoji: "😠", isDefault: true)
    static let sad = Mood(title: "sad", emoji: "😢", isDefault: true)
    static let inLove = Mood(title: "inLove", emoji: "😍", isDefault: true)
    static let stressed = Mood(title: "stressed", emoji: "😵‍💫", isDefault: true)
    
    static let predefined: [Mood] = [.happy, .calm, .anxious, .angry, .sad, .inLove, .stressed]
    
    init(
        title: String,
        emoji: String,
        isDefault: Bool = false
    ) {
        self.title = title
        self.emoji = emoji
        self.isDefault = isDefault
    }
    
    // MARK: - CoreData
    init(from entity: MoodEntity) {
        self.emoji = entity.emoji ?? "💤"
        self.title = entity.title ?? ""
        self.isDefault = entity.isDefault
    }
}
