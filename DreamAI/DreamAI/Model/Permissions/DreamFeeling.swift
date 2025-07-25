//
//  DreamFeeling.swift
//  DreamAI
//
//  Created by Shaxzod on 19/04/25
//

import SwiftUI

enum DreamFeeling: String, CaseIterable, Identifiable, Hashable {
    case vivid
    case weird
    case emotional
    case spiritual
    case dark
    case symbolic
    case lucid
    case realistic
    
    var id: Self { self }
    
    var displayName: LocalizedStringKey {
        switch self {
        case .vivid:      return "vivid"
        case .weird:      return "weird"
        case .emotional:  return "emotional"
        case .spiritual:  return "spiritual"
        case .dark:       return "dark"
        case .symbolic:   return "symbolic"
        case .lucid:      return "lucid"
        case .realistic:  return "realistic"
        }
    }
}
