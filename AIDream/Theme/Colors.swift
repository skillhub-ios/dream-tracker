import SwiftUI

extension Color {
    static let dreamPrimary = Color("Primary")
    static let dreamSecondary = Color("Secondary")
    static let dreamBackground = Color(.systemBackground)
    static let dreamSecondaryBackground = Color(.secondarySystemBackground)
    static let dreamTertiaryBackground = Color(.tertiarySystemBackground)
    
    static let dreamText = Color(.label)
    static let dreamSecondaryText = Color(.secondaryLabel)
    static let dreamTertiaryText = Color(.tertiaryLabel)
    
    static let dreamAccent = Color.accentColor
    static let dreamAccentSecondary = Color.accentColor.opacity(0.8)
    static let dreamAccentTertiary = Color.accentColor.opacity(0.6)
    
    static let dreamSuccess = Color.green
    static let dreamWarning = Color.orange
    static let dreamError = Color.red
    
    static let dreamBorder = Color(.separator)
    static let dreamShadow = Color.black.opacity(0.1)
    
    // Настроения
//    static let moodHappy = Color("MoodHappy")
//    static let moodSad = Color("MoodSad")
//    static let moodNeutral = Color("MoodNeutral")
//    static let moodAnxious = Color("MoodAnxious")
//    static let moodExcited = Color("MoodExcited")
    
    static let dreamHappy = Color.yellow
    static let dreamSad = Color.blue
    static let dreamScared = Color.purple
    static let dreamAngry = Color.red
    static let dreamNeutral = Color.gray
}

// Добавьте эти цвета в Assets.xcassets:
/*
 Primary: #6B4EFF (основной цвет приложения)
 Secondary: #FF6B6B (вторичный цвет)
 Background: #F8F9FA (фон)
 Text: #1A1A1A (основной текст)
 Accent: #4ECDC4 (акцентный цвет)

 MoodHappy: #FFD93D
 MoodSad: #6C5CE7
 MoodNeutral: #A8A8A8
 MoodAnxious: #FF6B6B
 MoodExcited: #4ECDC4
 */ 
