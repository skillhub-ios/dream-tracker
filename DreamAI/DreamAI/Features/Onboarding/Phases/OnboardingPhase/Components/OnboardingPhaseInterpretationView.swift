//
// OnboardingPhaseInterpretationView.swift
//
// Created by Cesare on 22.07.2025 on Earth.
// 


import SwiftUI

struct OnboardingPhaseInterpretationView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("🧠")
                Text("interpretation")
            }
            .font(.headline)
            Text("onboardingSecondStageInterpretation")
                .font(.subheadline)
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 16)
        .padding(.vertical, 18)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.appPurpleDarkBackground.opacity(0.75))
                .stroke(LinearGradient.appPurpleHorizontal, lineWidth: 1)
        }
    }
}

#Preview {
    OnboardingPhaseInterpretationView()
}
