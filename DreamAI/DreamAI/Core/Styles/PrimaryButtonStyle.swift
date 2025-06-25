//
// PrimaryButtonStyle.swift
//
// Created by Cesare on 25.06.2025 on Earth.
//


import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.title3.bold())
            .foregroundStyle(.white)
            .frame(height: 50)
            .frame(maxWidth: .infinity)
            .background(AppGradients.buttonPurple)
            .clipShape(RoundedRectangle(cornerRadius: 13))
            .overlay {
                RoundedRectangle(cornerRadius: 13)
                    .stroke(Color.appGray9.opacity(0.65), lineWidth: 1.5)
            }
    }
    
}

#Preview {
    Button("Log In") {}
        .buttonStyle(PrimaryButtonStyle())
        .padding()
}
