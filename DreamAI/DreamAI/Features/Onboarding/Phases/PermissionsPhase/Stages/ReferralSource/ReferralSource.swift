//
//  ReferralSource.swift
//  DreamAI
//
//  Created by Shaxzod on 19/04/25
//

import SwiftUI

enum ReferralSource: CaseIterable, Identifiable, Hashable {
    case instagram
    case facebook
    case tiktok
    case youtube
    case google
    case friendOrFamily
    case telegram
    case other

    var id: Self { self }

    var displayName: LocalizedStringKey {
        switch self {
        case .instagram: return "Instagram"
        case .facebook: return "Facebook"
        case .tiktok: return "TikTok"
        case .youtube: return "YouTube"
        case .google: return "Google"
        case .friendOrFamily: return "friend_or_family"
        case .telegram: return "Telegram"
        case .other: return "other"
        }
    }
}

