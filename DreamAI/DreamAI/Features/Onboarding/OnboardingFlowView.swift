//
// OnboardingFlowView.swift
//
// Created by Cesare on 21.07.2025 on Earth.
//


import SwiftUI

struct OnboardingFlowView: View {
    
    @StateObject private var onboardingViewModel = OnboardingFlowViewModel()
    
    var body: some View {
        NavigationStack(path: $onboardingViewModel.path) {
            IntroScreenView()
                .navigationDestination(for: OnboardingStep.self) { step in
                    stepView(for: step)
                }
        }
        .environmentObject(onboardingViewModel)
    }
}

private extension OnboardingFlowView {
    @ViewBuilder
    private func stepView(for step: OnboardingStep) -> some View {
        switch step {
        case .onboarding: OnboardingPhaseView()
        case .permissions: PermissionsView()
        case .setup:
            Text("setup")
                .onTapGesture {
                    onboardingViewModel.path.removeAll()
                }
                .navigationBarHidden(true)
        }
    }
}

#Preview {
    OnboardingFlowView()
        .environmentObject(OnboardingFlowViewModel())
}
