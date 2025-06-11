//
//  Tags.swift
//  DreamAI
//
//  Created by Shaxzod on 11/06/25.
//

import SwiftUI

enum Tags: String, CaseIterable {
    case daydream = "Daydream"
    case epicDream = "Epic Dream"
    case continuousDream = "Continuous Dream"
    case propheticDream = "Prophetic Dream"
    case nightmare = "Nightmare"
    case nightTerror = "Night Terror"
    case lucidDream = "Lucid Dream"
    case falseAwakening = "False Awakening"
    case supernaturalDream = "Supernatural Dream"
    case telepathicDream = "Telepathic Dream"
    case creativeDream = "Creative Dream"
    case healingDream = "Healing Dream"
    case sleepParalysis = "Sleep Paralysis"
    
    var icon: ImageResource {
        return switch self {
        case .daydream: .daydream
        case .epicDream: .epicDream
        case .continuousDream: .continuousDream
        case .propheticDream: .propheticDream
        case .nightmare: .nightmare
        case .nightTerror: .nightTerror
        case .lucidDream: .lucidDream
        case .falseAwakening: .falseAwakening
        case .supernaturalDream: .supernaturalDream
        case .telepathicDream: .telepathicDream
        case .creativeDream: .creativeDream
        case .healingDream: .healingDream
        case .sleepParalysis: .sleepParalysis
        }
    }
}
