//
// LinearGradient.swift
//
// Created by Cesare on 16.07.2025 on Earth.
//

import SwiftUI

extension LinearGradient {
    static var appPurpleHorizontal: LinearGradient {
        LinearGradient(
            colors: [.appPurpleGradient4, .appPurpleGradient3],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    static var darkPurpleToBlack: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(.sRGB, red: 38/255, green: 18/255, blue: 44/255, opacity: 1),
                Color.black
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
    }
}
