//
// AppGradients.swift
//
// Created by Cesare on 25.06.2025 on Earth.
// 


import SwiftUI

enum AppGradients {
    static let purpleToBlack = LinearGradient(
        gradient: Gradient(
            colors: [
                Color(.sRGB, red: 38/255, green: 18/255, blue: 44/255, opacity: 1),
                Color.black
            ]
        ),
        startPoint: .top,
        endPoint: .bottom
    )
    
    static let buttonPurple = RadialGradient(
        gradient: Gradient(colors: [
            Color.appPurpleGradient1,
            Color.appPurpleGradient2
        ]),
        center: .center,
        startRadius: 0,
        endRadius: 160
    )
}
