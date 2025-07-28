//
// SkipStyle.swift
//
// Created by Cesare on 22.07.2025 on Earth.
// 


import SwiftUI

struct SkipStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.bold())
            .foregroundStyle(Color.appPurpleLight)
            .padding(.horizontal, 20)
            .frame(height: 20)
            .onChange(of: configuration.isPressed) {
                if configuration.isPressed {
                    UIImpactFeedbackGenerator(style: .light)
                        .impactOccurred()
                }
            }
    }
}
