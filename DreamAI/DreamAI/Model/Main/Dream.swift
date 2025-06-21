//
//  Dream.swift
//  DreamAI
//
//  Created by Shaxzod on 11/06/25.
//

import SwiftUI

enum RequestStatus: Equatable {
    case idle
    case loading(progress: Double)
    case success
    case error
}

struct Dream: Identifiable {
    let id = UUID()
    let emoji: String
    let emojiBackground: Color
    let title: String
    let tags: [Tags]
    let date: Date
    var requestStatus: RequestStatus = .idle
}
