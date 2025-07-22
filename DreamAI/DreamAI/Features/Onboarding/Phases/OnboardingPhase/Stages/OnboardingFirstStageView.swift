//
// OnboardingFirstStageView.swift
//
// Created by Cesare on 21.07.2025 on Earth.
// 


import SwiftUI

struct OnboardingFirstStageView: View {
    var body: some View {
        VStack(spacing: 60) {
            OnboardingPhaseTitleView(
                title: "onboardingFirstStageTitle",
                subtitle: "onboardingFirstStageSubtitle",
                subtitle2: "onboardingFirstStageSubtitle2")
            Image(.dreamAreNotRandom)
        }
        .frame(maxHeight: .infinity, alignment: .top)
    }
}

#Preview {
    OnboardingFirstStageView()
}
