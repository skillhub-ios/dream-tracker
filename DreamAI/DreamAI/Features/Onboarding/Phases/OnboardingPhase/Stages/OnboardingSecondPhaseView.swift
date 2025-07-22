//
// OnboardingSecondPhaseView.swift
//
// Created by Cesare on 21.07.2025 on Earth.
// 


import SwiftUI

struct OnboardingSecondPhaseView: View {
    var body: some View {
        VStack(spacing: 24) {
            OnboardingPhaseTitleView(
                title: "onboardingSecondStageTitle",
                subtitle: "onboardingSecondStageSubtitle",
                subtitle2: "onboardingSecondStageSubtitle2")
            infoView
            OnboardingPhaseInterpretationView()
        }
    }
}

private extension OnboardingSecondPhaseView {    
    var infoView: some View {
        Text("onboardingSecondStageInfo")
            .font(.body)
            .foregroundStyle(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 18)
            .background {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.appGray10)
            }
    }
}

#Preview {
    OnboardingSecondPhaseView()
}
