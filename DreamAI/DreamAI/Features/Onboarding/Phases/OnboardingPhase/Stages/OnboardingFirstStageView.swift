//
// OnboardingFirstStageView.swift
//
// Created by Cesare on 21.07.2025 on Earth.
// 


import SwiftUI

struct OnboardingFirstStageView: View {
    var body: some View {
        VStack {
            VStack(spacing: 4) {
                Text("onboardingFirstStageTitle")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.white)
                VStack(spacing: .zero) {
                    Text("onboardingFirstStageSubtitle")
                    Text("onboardingFirstStageSubtitle2")
                }
                .font(.subheadline)
                .foregroundStyle(Color.appPurpleLight.opacity(0.65))
            }
            .multilineTextAlignment(.center)
        }
        .frame(maxHeight: .infinity, alignment: .top)
    }
}

#Preview {
    OnboardingFirstStageView()
}
