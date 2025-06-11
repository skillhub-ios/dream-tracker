//
//  Dream.swift
//  DreamAI
//
//  Created by Shaxzod on 11/06/25.
//

import SwiftUI

struct Dream: Identifiable {
    let id = UUID()
    let emoji: String
    let emojiBackground: Color
    let title: String
    let tags: [Tags]
    let date: Date
}
