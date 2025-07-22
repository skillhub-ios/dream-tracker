//
// OnboardingPhaseTitleView.swift
//
// Created by Cesare on 22.07.2025 on Earth.
// 


import SwiftUI

struct OnboardingPhaseTitleView: View {
    
    private let title: LocalizedStringKey
    private let subtitle: LocalizedStringKey?
    private let subtitle2: LocalizedStringKey?
    
    init(
        title: LocalizedStringKey,
        subtitle: LocalizedStringKey? = nil,
        subtitle2: LocalizedStringKey? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.subtitle2 = subtitle2
    }
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.largeTitle.bold())
                .foregroundStyle(.white)
            VStack(spacing: .zero) {
                if let subtitle = subtitle {
                    Text(subtitle)
                }
                if let subtitle2 = subtitle2 {
                    Text(subtitle2)
                }
            }
            .font(.subheadline)
            .foregroundStyle(Color.appPurpleLight.opacity(0.65))
        }
        .multilineTextAlignment(.center)
    }
}
