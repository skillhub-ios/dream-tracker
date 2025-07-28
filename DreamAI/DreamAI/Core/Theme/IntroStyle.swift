//
// IntroStyle.swift
//
// Created by Cesare on 21.07.2025 on Earth.
// 


import SwiftUI

struct IntroStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.title3.bold())
            .foregroundStyle(.white)
            .frame(height: 50)
            .frame(maxWidth: .infinity)
            .background(Color.darkPurple)
            .clipShape(RoundedRectangle(cornerRadius: 13))
            .overlay {
                RoundedRectangle(cornerRadius: 13)
                    .stroke(Color.lightPurple, lineWidth: 1.5)
            }
            .onChange(of: configuration.isPressed) {
                if configuration.isPressed {
                    UIImpactFeedbackGenerator(style: .light)
                        .impactOccurred()
                }
            }
    }
}
